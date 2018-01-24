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
    
    var offerTimer: Timer?
    var progressTimer: Timer?
    
    let OFFER_TIMER_INTERVAL = 35.0 // TODO: Change this to 30 seconds
    let OFFER_TIMER_EXPIRE_MSG_TITLE = "No offers received."
    let OFFER_TIMER_EXPIRE_MSG_CONTENT = "Reason: Drivers didn't respond."

    let PROGRESS_TIMER_INTERVAL: Float = 0.3 // this is the default image progress view animation time

    var sampleProgress: Int = 1
    var progressTimeSum: Int = 0
    var logoImageProgress: Int = 1
    var logoImageProgressDirection: Bool = true
    
//    var savedBgTimestamp: Date?

    // MARK: - Setup Functions

    func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        progressBarOutlet.progressDirection = M13ProgressViewBarProgressDirectionLeftToRight
        progressBarOutlet.showPercentage = false
        progressBarOutlet.indeterminate = true

        let screenSize: CGRect = UIScreen.main.bounds
        
        progressImageOutlet.progressImage = UIImage(named: "green-yibby-logo.png")
        progressImageOutlet.progressDirection = M13ProgressViewImageProgressDirectionLeftToRight
        progressImageOutlet.drawGreyscaleBackground = true
    }
    
    func setupDelegates() {
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
    
    // MARK: - Helper
    
    func startOfferTimer() {
        offerTimer = Timer.scheduledTimer(timeInterval: OFFER_TIMER_INTERVAL,
                                                            target: self,
                                                            selector: #selector(FindOffersViewController.bidWaitTimeoutCb),
                                                            userInfo: nil,
                                                            repeats: false)
    }
    
    func stopOfferTimer() {
        if let offerTimer = self.offerTimer {
            offerTimer.invalidate()
        }
        
        // today, we stop the progress timer along with offer timer
        stopProgressTimer()
    }
    
    func bidWaitTimeoutCb() {
        DDLogVerbose("Called")

        // TODO: Rather than aborting the bid, query the webserver for bidDetails and show the result
        
        DDLogDebug("Resetting the bidState in bidWaitTimeoutCb")
        
        // delete the saved state bid
        YBClient.sharedInstance().bid = nil
        
        // pop the view controller
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            mmnvc.popViewController(animated: true)
            AlertUtil.displayAlert(OFFER_TIMER_EXPIRE_MSG_TITLE, message: OFFER_TIMER_EXPIRE_MSG_CONTENT)
        }
    }

    // MARK: Progress view functions
    
    func startProgressTimer () {
        progressTimer = Timer.scheduledTimer(timeInterval: TimeInterval(PROGRESS_TIMER_INTERVAL), target: self,
                                             selector: #selector(FindOffersViewController.progress),
                                             userInfo: nil, repeats: true)
    }
    
    func stopProgressTimer() {
        if let progressTimer = self.progressTimer {
            progressTimer.invalidate()
        }
    }
    
//    func saveProgressTimer () {
//        DDLogVerbose("Called")
//        
//        // if there is an active bid, save the current time
//        if (YBClient.sharedInstance().isOngoingBid()) {
//            let curTime = Date()
//            DDLogDebug("Setting bgtime \(curTime))")
//            savedBgTimestamp = curTime
//        }
//    }
//    
//    func restoreProgressTimer () {
//        DDLogVerbose("Called")
//        
//        if (YBClient.sharedInstance().isOngoingBid()) {
//            
//            if let appBackgroundedTime = savedBgTimestamp {
//                
//                let elapsedTime = TimeInterval(Int(TimeUtil.diffFromCurTime(appBackgroundedTime))) // seconds
//                
//                DDLogDebug("bgtime \(appBackgroundedTime) bumpUpTime \(elapsedTime))")
//                
//                var progress: Float = self.progressView.progress
//                if progress < 1.0 {
//                    progress += Float(1.0 / (OFFER_TIMER_INTERVAL / elapsedTime))
//                    
//                    if progress > 1.0 {
//                       progress = 1.0
//                    }
//                    
//                    self.progressView.setProgress(progress, animated: true)
//                }
//                savedBgTimestamp = nil
//            }
//        }
//    }

    func progress() {
        
        progressTimeSum += 3 // sum by 0.3s
        
        // called every 3 seconds
        if (progressTimeSum % 30 == 0) {
            morphingLabelOutlet.text = morphingLabelText
        }
        
        // A Bad NOTE:
        // Lot of hard coded variables have been used here! :(
        // This is to avoid floating point computations.
        // Can you believe I was getting (0.1 < 0.1) is true?
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
    
//    func progressView(_ progressView: ASProgressPopUpView, stringForProgress progress: Float) -> String? {
//        var s: String?
//        if progress < 0.2 {
//            s = "Drivers got your bid"
//        }
//        else if progress > 0.4 && progress < 0.6 {
//            s = "We are negotiating heavily"
//        }
//        else if progress > 0.75 && progress < 1.0 {
//            s = "Almost there"
//        }
//        else if progress >= 1.0 {
//            s = "Done"
//        }
//        
//        return s;
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
