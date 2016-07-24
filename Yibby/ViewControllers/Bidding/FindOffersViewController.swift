//
//  findOffersViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ASProgressPopUpView

class FindOffersViewController: UIViewController, ASProgressPopUpViewDataSource {

    // MARK: Properties

    @IBOutlet weak var progressView: ASProgressPopUpView!
    
    var offerTimer: NSTimer?
    var progressTimer: NSTimer?
    
    var timerCount = 0.0
    
    let OFFER_TIMER_INTERVAL = 35.0 // TODO: Change this to 30 seconds
    let OFFER_TIMER_EXPIRE_MSG_TITLE = "No offers received."
    let OFFER_TIMER_EXPIRE_MSG_CONTENT = "Reason: Drivers didn't respond."

    let PROGRESS_TIMER_INTERVAL = 0.5
    
    var savedBgTimestamp: NSDate?

    // MARK: Setup Functions

    func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // progress view
        self.progressView.dataSource = self
        self.progressView.showPopUpViewAnimated(true)
        self.progressView.progress = 0.0;
        self.progressView.font = UIFont(name: "Futura-CondensedExtraBold", size: 16)
        self.progressView.popUpViewAnimatedColors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.greenColor()]

//        self.progressView.popUpViewCornerRadius = 12.0;
//        self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:28];
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        // start the timer
        startOfferTimer()
        
        // start the progress bar
        startProgressTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Helper
    
    func startOfferTimer() {
        offerTimer = NSTimer.scheduledTimerWithTimeInterval(OFFER_TIMER_INTERVAL,
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
        BidState.sharedInstance().resetOngoingBid()
        
        // pop the view controller
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            mmnvc.popViewControllerAnimated(true)
            AlertUtil.displayAlert(OFFER_TIMER_EXPIRE_MSG_TITLE, message: OFFER_TIMER_EXPIRE_MSG_CONTENT)
        }
    }

    // MARK: Progress view functions
    
    func startProgressTimer () {
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(PROGRESS_TIMER_INTERVAL, target: self,
                                               selector: #selector(FindOffersViewController.progress),
                                               userInfo: nil, repeats: true)
    }
    
    func stopProgressTimer() {
        if let progressTimer = self.progressTimer {
            progressTimer.invalidate()
        }
    }
    
    func saveProgressTimer () {
        DDLogVerbose("Called")
        
        // if there is an active bid, save the current time
        if (BidState.sharedInstance().isOngoingBid()) {
            let curTime = NSDate()
            DDLogDebug("Setting bgtime \(curTime))")
            savedBgTimestamp = curTime
        }
    }
    
    func restoreProgressTimer () {
        DDLogVerbose("Called")
        
        if (BidState.sharedInstance().isOngoingBid()) {
            
            if let appBackgroundedTime = savedBgTimestamp {
                
                let elapsedTime = NSTimeInterval(Int(TimeUtil.diffFromCurTime(appBackgroundedTime))) // seconds
                
                DDLogDebug("bgtime \(appBackgroundedTime) bumpUpTime \(elapsedTime))")
                
                var progress: Float = self.progressView.progress
                if progress < 1.0 {
                    progress += Float(1.0 / (OFFER_TIMER_INTERVAL / elapsedTime))
                    
                    if progress > 1.0 {
                       progress = 1.0
                    }
                    
                    self.progressView.setProgress(progress, animated: true)
                }
                savedBgTimestamp = nil
            }
        }
    }

    func progress() {

        var progress: Float = self.progressView.progress
        if progress < 1.0 {
            progress += Float(1.0 / (OFFER_TIMER_INTERVAL / PROGRESS_TIMER_INTERVAL))
            
            if progress > 1.0 {
                progress = 1.0
            }
            
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    // <ASProgressPopUpViewDataSource> is entirely optional
    // it allows you to supply custom NSStrings to ASProgressPopUpView
    func progressView(progressView: ASProgressPopUpView, stringForProgress progress: Float) -> String? {
        var s: String?
        if progress < 0.2 {
            s = "Drivers got your bid"
        }
        else if progress > 0.4 && progress < 0.6 {
            s = "We are negotiating heavily"
        }
        else if progress > 0.75 && progress < 1.0 {
            s = "Almost there"
        }
        else if progress >= 1.0 {
            s = "Done"
        }
        
        return s;
    }
    
    // by default ASProgressPopUpView precalculates the largest popUpView size needed
    // it then uses this size for all values and maintains a consistent size
    // if you want the popUpView size to adapt as values change then return 'NO'
    
    func progressViewShouldPreCalculatePopUpViewSize(progressView: ASProgressPopUpView) -> Bool {
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
