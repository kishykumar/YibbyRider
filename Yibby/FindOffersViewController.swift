//
//  findOffersViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

class FindOffersViewController: UIViewController {

    // MARK: Properties

    var offerTimer = NSTimer()
    var timerCount = 0.0
    
    let OFFER_TIMER_INTERVAL = 35.0 // TODO: Change this to 30 seconds
    let OFFER_TIMER_EXPIRE_MSG_TITLE = "No offers received."
    let OFFER_TIMER_EXPIRE_MSG_CONTENT = "Reason: Drivers didn't respond."

    // MARK: Setup Functions

    func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        // start the timer
        startOfferTimer()
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
        offerTimer.invalidate()
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
            Util.displayAlert(OFFER_TIMER_EXPIRE_MSG_TITLE, message: OFFER_TIMER_EXPIRE_MSG_CONTENT)
        }
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
