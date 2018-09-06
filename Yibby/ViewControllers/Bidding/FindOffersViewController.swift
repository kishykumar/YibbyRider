//
//  findOffersViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import LTMorphingLabel
import M13ProgressSuite
import BaasBoxSDK
import ObjectMapper

class FindOffersViewController: BaseYibbyViewController, LTMorphingLabelDelegate {

    // MARK: - Properties
    @IBOutlet weak var morphingLabelOutlet: LTMorphingLabel!
    @IBOutlet weak var progressBarOutlet: M13ProgressViewBar!
    @IBOutlet weak var progressImageOutlet: M13ProgressViewImage!
    
    fileprivate var morphingLabelTextArrayIndex = 0
    
    fileprivate var morphingLabelTextArray = [
        "Finding the cheapest ride",
        "Hang on tight!",
        "Ride in less than 30 seconds",
        "Top Rated drivers",
        "Reliable",
        "You save, drivers save!"
    ]
    
    fileprivate var morphingLabelText: String {
        morphingLabelTextArrayIndex =
            morphingLabelTextArrayIndex >= (morphingLabelTextArray.count - 1) ?
                                            0 :
                                            (morphingLabelTextArrayIndex + 1)
        
        return morphingLabelTextArray[morphingLabelTextArrayIndex]
    }
    
    fileprivate var offerTimer: Timer?
    fileprivate var progressTimer: Timer?
    
    fileprivate let OFFER_TIMER_INTERVAL = 5.0 // Timer fires every 5 seconds
    fileprivate let OFFER_TIMER_EXPIRE_MSG_TITLE = "No offers received."
    fileprivate let OFFER_TIMER_EXPIRE_MSG_CONTENT = "Reason: Drivers didn't respond."

    fileprivate let PROGRESS_TIMER_INTERVAL: Float = 0.3 // this is the default image progress view animation time

    fileprivate var offerTimeSum: Int = 0
    fileprivate var sampleProgress: Int = 1
    fileprivate var progressTimeSum: Int = 0
    fileprivate var logoImageProgress: Int = 1
    fileprivate var logoImageProgressDirection: Bool = true
    
    fileprivate var offerObserver: NotificationObserver?
    fileprivate var rideObserver: NotificationObserver?
    
    // MARK: - Setup Functions

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        DDLogVerbose("Fired init")
        setupNotificationObservers()
    }
    
    deinit {
        DDLogVerbose("Fired deinit")
        stopOfferTimer()
        removeNotificationObservers()
    }
    
    fileprivate func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        progressBarOutlet.progressDirection = M13ProgressViewBarProgressDirectionLeftToRight
        progressBarOutlet.showPercentage = false
        progressBarOutlet.indeterminate = true

        //let screenSize: CGRect = UIScreen.main.bounds
        
        progressImageOutlet.progressImage = UIImage(named: "green-yibby-logo.png")
        progressImageOutlet.progressDirection = M13ProgressViewImageProgressDirectionLeftToRight
        progressImageOutlet.drawGreyscaleBackground = true
    }
    
    fileprivate func setupDelegates() {
        morphingLabelOutlet.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
     
        setupDelegates()

        // start the timer
        startOfferTimer()
        
        // start the progress bar
        startProgressTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications
    
    fileprivate func removeNotificationObservers() {
        
        offerObserver?.removeObserver()
        rideObserver?.removeObserver()
    }
    
    fileprivate func setupNotificationObservers() {
        
        offerObserver = NotificationObserver(notification: BidNotifications.noOffers) { [unowned self] bid in
            DDLogVerbose("Stopped offer timer")
            self.stopOfferTimer()
        }
        
        rideObserver = NotificationObserver(notification: RideNotifications.driverEnRoute) { [unowned self] ride in
            DDLogVerbose("Stopped offer timer")
            self.stopOfferTimer()
        }
    }
    
    // MARK: - Helpers
    
    // MARK: - OfferTimer functions
    
    fileprivate func startOfferTimer() {
        offerTimer = Timer.scheduledTimer(timeInterval: OFFER_TIMER_INTERVAL,
                            target: self,
                            selector: #selector(FindOffersViewController.bidWaitTimeoutCallback),
                            userInfo: nil,
                            repeats: true)
    }
    
    fileprivate func stopOfferTimer() {
        if let offerTimer = self.offerTimer {
            offerTimer.invalidate()
        }
        
        // today, we stop the progress timer along with offer timer
        stopProgressTimer()
    }
    
    @objc fileprivate func bidWaitTimeoutCallback() {
        
        // called every 5 seconds
        offerTimeSum += 5
        DDLogVerbose("Incremented timer \(offerTimeSum)")
        
        // check if it's more than 35 seconds
        if (offerTimeSum >= 35 && offerTimeSum < 120) {
        
            DDLogVerbose("Fired")
            let bidId = YBClient.sharedInstance().bid!.id
            
            let client: BAAClient = BAAClient.shared()
            client.syncClient(BAASBOX_RIDER_STRING, bidId: bidId, completion: { (success, error) -> Void in
                
                if (YBClient.sharedInstance().status != .ongoingBid) {
                    return;
                }
                
                if let success = success {
                    let syncModel = Mapper<YBSync>().map(JSONObject: success)
                    if let syncData = syncModel {
                        
                        DDLogVerbose("syncApp syncdata for bidId: \(String(describing: bidId))")
                        dump(syncData)
                        
                        // Sync the local client
                        YBClient.sharedInstance().syncClient(syncData)
                        
                        switch (YBClient.sharedInstance().status) {

                        // TODO: Fix me! Bug when driver reaches ride_end, driver_Arrived etc, and rider opens the app at the end, then the state is messed up and we just open driver en route controller.
                        case .onRide:
                            fallthrough
                        case .driverArrived:
                            fallthrough
                        case .pendingRating:
                            fallthrough
                        case .driverEnRoute:
                            self.stopOfferTimer()
                            postNotification(RideNotifications.driverEnRoute, value: YBClient.sharedInstance().ride!)
                            
                        case .failedHighOffers:
                            fallthrough
                        case .failedNoOffers:

                            self.stopOfferTimer()
                            postNotification(BidNotifications.noOffers, value: YBClient.sharedInstance().bid!)

                            break
                            
                        case .ongoingBid:
                            // We have to continue with the timer
                            
                            break
                        default:
                            break
                        }
                    }
                }
            })
        } else if (offerTimeSum >= 120) {

            self.stopOfferTimer()
            
            // if (timeout is more than 2 minutes, cancel the ride)
            DDLogDebug("Resetting the bidState in bidWaitTimeoutCb")
            postNotification(BidNotifications.noOffers, value: YBClient.sharedInstance().bid!)
        }
    }

    // MARK: Progress view functions
    
    fileprivate func startProgressTimer () {
        progressTimer = Timer.scheduledTimer(timeInterval: TimeInterval(PROGRESS_TIMER_INTERVAL), target: self,
                                             selector: #selector(FindOffersViewController.progress),
                                             userInfo: nil, repeats: true)
    }
    
    fileprivate func stopProgressTimer() {
        if let progressTimer = self.progressTimer {
            progressTimer.invalidate()
        }
    }

    @objc fileprivate func progress() {
        
        progressTimeSum += 3 // sum by 0.3s
        
        // called every 3 seconds
        if (progressTimeSum % 30 == 0) {
            morphingLabelOutlet.text = morphingLabelText
        }
        
        // A Bad NOTE:
        // Lot of hard coded variables have been used here! :(
        // This is to avoid floating point computations.
        // Can you believe I was getting (0.1 < 0.1 = true)?
        //
        // 0.3s is the animation time for the logo image view and
        // I have chosen that to be the progress timer interval to
        // make the math easy. 3 seconds is the total animation time
        // for the logo image.
        //
        // Every interval we increment the overall progress by 1 (or 0.1s),
        // which is the progress for a single sample.
        // Total samples will be 10.
        // 0 to 10 go left to right
        // 10 to 0 go right to left
        
        if (logoImageProgressDirection) {
            progressImageOutlet.progressDirection = M13ProgressViewImageProgressDirectionLeftToRight
            
            progressImageOutlet.setProgress(CGFloat(Float(logoImageProgress)/10.0), animated: true)
            logoImageProgress = logoImageProgress + sampleProgress
            
            let maxProgress: Int = 10
            
            if (maxProgress < logoImageProgress) {
                logoImageProgress = 1
                logoImageProgressDirection = false
            }
        } else {
            let maxProgress: Int = 10
            progressImageOutlet.progressDirection = M13ProgressViewImageProgressDirectionRightToLeft
            progressImageOutlet.setProgress(CGFloat(Float(10 - logoImageProgress) / 10.0), animated: true)
            logoImageProgress = logoImageProgress + sampleProgress
            
            if (maxProgress < logoImageProgress) {
                logoImageProgress = 1
                logoImageProgressDirection = true
            }
        }
    }
}
