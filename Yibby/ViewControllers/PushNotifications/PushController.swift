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
    func receiveRemoteNotification(_ application: UIApplication, notification:[AnyHashable: Any])
}

open class PushController: NSObject, PushControllerProtocol {
    
    let OFFER_MESSAGE_TYPE = "OFFER"
    let NO_OFFERS_MESSAGE_TYPE = "NO_OFFERS"
    let RIDE_START_MESSAGE_TYPE = "RIDE_START"
    let RIDE_END_MESSAGE_TYPE = "RIDE_END"
    let DRIVER_EN_ROUTE_MESSAGE_TYPE = "DRIVER_EN_ROUTE"

    let MESSAGE_JSON_FIELD_NAME = "message"
    let CUSTOM_JSON_FIELD_NAME = "custom"
    let BID_JSON_FIELD_NAME = "bid"
    let RIDE_JSON_FIELD_NAME = "ride"
    let ID_JSON_FIELD_NAME = "id"
    let BID_ID_JSON_FIELD_NAME = "bidId"
    let GCM_MSG_ID_JSON_FIELD_NAME = "gcm.message_id"
    
    var savedNotification: [AnyHashable: Any]?
    var mLastGCMMsgId: String?

    public override init() {
        super.init()
    }

    //MARK: Receiving remote notification
    open func receiveRemoteNotification(_ application: UIApplication, notification: [AnyHashable: Any]) {

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if (!appDelegate.initialized) {
          return;
        }
        
        if application.applicationState == .background {
            //opened from a push notification when the app was on background
            DDLogDebug("App in BG")
            handleBgNotification(notification)
        }
        else if (application.applicationState == .inactive) {
            // ignore the BID message
            DDLogDebug ("App in inactive state")
            handleBgNotification(notification)
        }
        else { // App in foreground
            DDLogDebug("App in FG")
            handleFgNotification(notification)
        }
    }
    
    
    func handleBgNotification (_ notification: [AnyHashable: Any]) {
        DDLogDebug("Setting recent push msg from \(savedNotification) to \(notification)")

        if (YBClient.sharedInstance().isOngoingBid()) {
            
            DDLogDebug("Setting got response")
            
            disableTimeoutCode()
            
            // save the most recent push message
            savedNotification = [AnyHashable: Any]()
            savedNotification = notification // copies over the dictionary
        }
    }
    
    func handleFgNotification (_ notification: [AnyHashable: Any]) {
        // show the message if it's not late
        processNotification(notification)
    }
    
    
    func processSavedNotification() {
        DDLogDebug("Called")
        
        if let notification = savedNotification {
            DDLogDebug("Processing saved notification: \(notification)")

            processNotification(notification)
            
            // remove the savedNotification
            savedNotification = nil
        } else {
            DDLogDebug("No saved notification found")
        }
    }
    
    func processNotification (_ notification: [AnyHashable: Any]) {
        DDLogVerbose("Called")

        // handle offer
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

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

        if (appDelegate.centerContainer == nil) {
            // this might happen during startup
            DDLogDebug("Discarded the notification because centerContainer nil")
            return;
        }
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            
//            if (!YBClient.sharedInstance().isOngoingBid()) {
//                DDLogDebug("No ongoingBid. Discarded: \(notification[MESSAGE_JSON_FIELD_NAME] as! String)")
//                return;
//            }
            
            let jsonCustom = notification[CUSTOM_JSON_FIELD_NAME]
            
            guard let jsonCustomString = jsonCustom as? String else {
                DDLogVerbose("Returning because of JSON custom string: \(jsonCustom)")
                return;
            }
            
            let messageType = (notification[MESSAGE_JSON_FIELD_NAME] as! String)
            
            if (messageType == OFFER_MESSAGE_TYPE ||
                messageType == NO_OFFERS_MESSAGE_TYPE) {
                
                let bid = Bid(JSONString: jsonCustomString)!
                if (!YBClient.sharedInstance().isSameAsOngoingBid(bidId: bid.id)) {
                    DDLogDebug("Not same as ongoingBid. Discarded: \(notification[MESSAGE_JSON_FIELD_NAME] as! String)")
                    DDLogDebug("Ongoingbid is: \(YBClient.sharedInstance().getBid())")
                    return;
                }
                
                switch messageType {
                    
                case OFFER_MESSAGE_TYPE:
                    
                    // -- THIS CODEPATH IS NOT EXECUTED --
                    assert(false)
                    
                    DDLogDebug("OFFER RCVD")
                    
                    let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
                    
                    let confirmRideViewController = biddingStoryboard.instantiateViewController(withIdentifier: "ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
                    mmnvc.pushViewController(confirmRideViewController, animated: true)
                    
                case NO_OFFERS_MESSAGE_TYPE:
                    DDLogDebug("NOOFFERS RCVD")
                    
                    // delete the saved state bid
                    YBClient.sharedInstance().resetBid()
                    
                    disableTimeoutCode()
                    
                    mmnvc.popViewController(animated: true)
                    AlertUtil.displayAlert("No offers from drivers.", message: "Your bid was not accepted by any driver")
                    
                default:
                    DDLogError("Weird message received during Bid1: \(messageType)")
                    break
                }
            } else if (messageType == DRIVER_EN_ROUTE_MESSAGE_TYPE ||
                        messageType == RIDE_START_MESSAGE_TYPE ||
                        messageType == RIDE_END_MESSAGE_TYPE) {
                
                let ride = Ride(JSONString: jsonCustomString)!
                
                if (!YBClient.sharedInstance().isSameAsOngoingBid(bidId: ride.bidId)) {
                    
                    if let ongoingBid = YBClient.sharedInstance().getBid() {
                        DDLogDebug("Ongoingbid is: \(ongoingBid.id). Incoming is \(ride.bidId)")
                    } else {
                        DDLogDebug("Ongoingbid is: nil. Incoming is \(ride.bidId)")
                    }
                    
                    return;
                }
                
                switch messageType {

                case DRIVER_EN_ROUTE_MESSAGE_TYPE:
                    DDLogDebug("DRIVER_EN_ROUTE_MESSAGE_TYPE")
                    
                    disableTimeoutCode()
                    
                    let driverEnRouteStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.DriverEnRoute, bundle: nil)
                    
                    let driverEnRouteViewController = driverEnRouteStoryboard.instantiateViewController(withIdentifier: "DriverEnRouteViewControllerIdentifier") as! DriverEnRouteViewController
                    mmnvc.pushViewController(driverEnRouteViewController, animated: true)
                    
                case RIDE_START_MESSAGE_TYPE:
                    DDLogDebug("RIDE_START_MESSAGE_TYPE")
                    
                    let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
                    
                    let tripViewController = rideStoryboard.instantiateViewController(withIdentifier: "TripViewControllerIdentifier") as! TripViewController
                    mmnvc.pushViewController(tripViewController, animated: true)
                    
                case RIDE_END_MESSAGE_TYPE:
                    DDLogDebug("RIDE_END_MESSAGE_TYPE")
                    
                    let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
                    
                    let rideEndViewController = rideStoryboard.instantiateViewController(withIdentifier: "RideEndViewControllerIdentifier") as! RideEndViewController
                    mmnvc.pushViewController(rideEndViewController, animated: true)
                    
                default:
                    DDLogError("Weird message received during Bid2: \(messageType)")
                    break
                }
            } else {
                DDLogError("Weird message received \(messageType)")
            }
        }
    }

    func disableTimeoutCode () {
        // stop the timer if findOffersVC is up
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if let vvc = appDelegate.window!.visibleViewController as? FindOffersViewController {
            DDLogVerbose("Stopping the timer")
            vvc.stopOfferTimer()
        }
    }
    
    //MARK: APNS Token
    open func didRegisterForRemoteNotificationsWithDeviceToken(_ data:Data) {
        
    }

    //MARK: Utility
    
    open static func registerForPushNotifications() {
        
        let application: UIApplication = UIApplication.shared
        
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
    }
}
