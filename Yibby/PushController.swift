//
//  PushController.swift
//  YibbyPartner
//
//  Created by Kishy Kumar on 3/9/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import SwiftyJSON
import MMDrawerController
import CocoaLumberjack

@objc public protocol PushControllerProtocol {
    func receiveRemoteNotification(application: UIApplication, notification:[NSObject:AnyObject])
}

public class PushController: NSObject, PushControllerProtocol {
    
    let OFFER_MESSAGE_TYPE = "OFFER"
    let NO_OFFERS_MESSAGE_TYPE = "NO_OFFERS"
    let RIDE_START_MESSAGE_TYPE = "RIDE_START"
    let DRIVER_EN_ROUTE_MESSAGE_TYPE = "DRIVER_EN_ROUTE"

    let MESSAGE_JSON_FIELD_NAME = "message"
    let CUSTOM_JSON_FIELD_NAME = "custom"
    let BID_JSON_FIELD_NAME = "bid"
    let RIDE_JSON_FIELD_NAME = "ride"
    let ID_JSON_FIELD_NAME = "id"
    let GCM_MSG_ID_JSON_FIELD_NAME = "gcm.message_id"
    
    let SAVED_PUSH_NOTIFICATION_KEY = "SAVED_PUSH_NOTIFICATION_KEY"
    var mLastGCMMsgId: String?

    public override init() {
        super.init()
    }

    //MARK: Receiving remote notification
    public func receiveRemoteNotification(application: UIApplication, notification: [NSObject : AnyObject]) {
                
        // TODO: Add this code
        //        if (DRIVER IS OFFLINE) {
        //          return;
        //        }
        
        if application.applicationState == .Background {
            //opened from a push notification when the app was on background
            DDLogDebug("App in BG")
            handleBgNotification(notification)
        }
        else if (application.applicationState == .Inactive) {
            // ignore the BID message
            DDLogDebug ("App in inactive state")
            handleBgNotification(notification)
        }
        else { // App in foreground
            DDLogDebug("App in FG")
            handleFgNotification(notification)
        }
    }
    
    
    func handleBgNotification (notification: [NSObject : AnyObject]) {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        DDLogDebug("Setting recent push msg from \(userDefaults.objectForKey(SAVED_PUSH_NOTIFICATION_KEY)) to \(notification)")

        if (BidState.sharedInstance().isOngoingBid()) {
            
            DDLogDebug("Setting got response")
            BidState.sharedInstance().setGotResponse()
            
            // save the most recent push message
            userDefaults.setValue(notification, forKey: SAVED_PUSH_NOTIFICATION_KEY)
        }
    }
    
    func handleFgNotification (notification: [NSObject : AnyObject]) {
        // show the message if it's not late
        processNotification(notification)
    }
    
    
    func processSavedNotification() {
        DDLogDebug("Called")

        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let notification = userDefaults.objectForKey(SAVED_PUSH_NOTIFICATION_KEY) {
            DDLogDebug("Processing saved notification: \(notification)")

            processNotification(notification as! [NSObject : AnyObject])
            
            // remove the key as we have processed the notification
            userDefaults.removeObjectForKey(SAVED_PUSH_NOTIFICATION_KEY)
        } else {
            DDLogDebug("No saved notification found")
        }
    }
    
    func processNotification (notification: [NSObject : AnyObject]) {
        DDLogVerbose("Called")

        // handle offer
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // get the storyboard to instantiate the viewcontroller
        let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if notification[MESSAGE_JSON_FIELD_NAME] == nil {
            DDLogDebug("No notification message found")
            return;
        }
        
        // check if we have already processed this push message
        let lastGCMMsgId: String = notification[GCM_MSG_ID_JSON_FIELD_NAME] as! String
        if (mLastGCMMsgId != nil) && (mLastGCMMsgId == lastGCMMsgId) {
            DDLogDebug("Already processed the push message: \(notification)")
            return;
        }
        mLastGCMMsgId = notification[GCM_MSG_ID_JSON_FIELD_NAME] as? String

        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            
            if (!BidState.sharedInstance().isOngoingBid()) {
                DDLogDebug("No ongoingBid. Discarded: \(notification[MESSAGE_JSON_FIELD_NAME] as! String)")
                return;
            }
            
            let jsonCustom = notification[CUSTOM_JSON_FIELD_NAME]
            if let data = jsonCustom!.dataUsingEncoding(NSUTF8StringEncoding) {
                let topJson = JSON(data: data)
                if let topBidJson = topJson[BID_JSON_FIELD_NAME].string {
                
                    if let bidData = topBidJson.dataUsingEncoding(NSUTF8StringEncoding) {
                        
                        let bidJson = JSON(data: bidData)
                        if (!BidState.sharedInstance().isSameAsOngoingBid(bidJson[ID_JSON_FIELD_NAME].stringValue)) {
                            DDLogDebug("Not same as ongoingBid. Discarded: \(notification[MESSAGE_JSON_FIELD_NAME] as! String)")
                            DDLogDebug("Ongoingbid is: \(BidState.sharedInstance().getOngoingBid())")
                            return;
                        }
                        
                        switch notification[MESSAGE_JSON_FIELD_NAME] as! String {
                            
                        case OFFER_MESSAGE_TYPE:
                            DDLogDebug("OFFER RCVD")
                            
                            let confirmRideViewController = mainstoryboard.instantiateViewControllerWithIdentifier("ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
                            mmnvc.pushViewController(confirmRideViewController, animated: true)
                            
                        case NO_OFFERS_MESSAGE_TYPE:
                            DDLogDebug("NOOFFERS RCVD")
                            
                            mmnvc.popViewControllerAnimated(true)
                            Util.displayAlert("No offers from drivers.", message: "Your bid was not accepted by any driver")

                        default: break
                            
                        }
                        
                        BidState.sharedInstance().setGotResponse()
                    }
                }
                else if let topRideJson = topJson[RIDE_JSON_FIELD_NAME].string {
                    if let rideData = topRideJson.dataUsingEncoding(NSUTF8StringEncoding) {

                        let rideJson = JSON(data: rideData)
                        if (!BidState.sharedInstance().isSameAsOngoingBid(rideJson[BID_JSON_FIELD_NAME][ID_JSON_FIELD_NAME].string)) {
                            
                            DDLogDebug("Not same as ongoingBid. Discarded: \(notification[MESSAGE_JSON_FIELD_NAME] as! String)")
                            DDLogDebug("Ongoingbid is: \(BidState.sharedInstance().getOngoingBid())")
                            
                            return;
                        }
                        
                        switch notification[MESSAGE_JSON_FIELD_NAME] as! String {
                            
                        case DRIVER_EN_ROUTE_MESSAGE_TYPE:
                            DDLogDebug("DRIVER_EN_ROUTE_MESSAGE_TYPE")
                            
                            let driverEnRouteViewController = mainstoryboard.instantiateViewControllerWithIdentifier("DriverEnRouteViewControllerIdentifier") as! DriverEnRouteViewController
                            mmnvc.pushViewController(driverEnRouteViewController, animated: true)
                            
                        default: break
                        }
                    }
                    
                    BidState.sharedInstance().setGotResponse()
                }
            }
        }
    }
    
    //MARK: APNS Token
    public func didRegisterForRemoteNotificationsWithDeviceToken(data:NSData) {
        
    }

    //MARK: Utility
    
    public static func registerForPushNotifications() {
        
        let application: UIApplication = UIApplication.sharedApplication()
        
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
    }
}