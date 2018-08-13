//
//  PushController.swift
//  YibbyPartner
//
//  Created by Kishy Kumar on 3/9/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import SwiftyJSON
import MMDrawerController
import CocoaLumberjack
import UserNotifications

@objc public protocol PushControllerProtocol {
    func receiveRemoteNotification(_ application: UIApplication, notification:[AnyHashable: Any])
}

enum YBMessageType: String {
    case counterOffer = "COUNTER_OFFER"
    case noOffers = "NO_OFFERS"
    case rideStart = "RIDE_START"
    case driverArrived = "DRIVER_ARRIVED"
    case rideEnd = "RIDE_END"
    case driverEnRoute = "DRIVER_EN_ROUTE"
    case rideCancelled = "RIDE_CANCELLED"
}

open class PushController: NSObject, PushControllerProtocol, UNUserNotificationCenterDelegate {
    
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
            DDLogVerbose("Notification returned. App not initialized.")
          return;
        }
        
        if application.applicationState == .background {
            //opened from a push notification when the app was on background
            DDLogDebug("App in BG")
            handleBgNotification(notification)
        }
        else if (application.applicationState == .inactive) {
            DDLogDebug ("App in inactive state")
            handleBgNotification(notification)
        }
        else { // App in foreground
            DDLogDebug("App in FG")
            handleFgNotification(notification)
        }
    }
    
    func handleBgNotification (_ notification: [AnyHashable: Any]) {
        
        DDLogDebug("Setting recent push msg from \(String(describing: savedNotification)) to \(notification)")
        if (YBClient.sharedInstance().isOngoingBid()) {
            // save the most recent push message
            savedNotification = [AnyHashable: Any]()
            savedNotification = notification // copies over the dictionary
            // it displays local notification when app is in background
            processNotification(savedNotification!, isForeground: false)
        }
    }
    
    func handleFgNotification (_ notification: [AnyHashable: Any]) {
        // show the message if it's not late
        processNotification(notification, isForeground: true)
    }
    
    func processSavedNotification() {
        DDLogDebug("Called")
        
        if let notification = savedNotification {
            DDLogDebug("Processing saved notification: \(notification)")

            processNotification(notification, isForeground: true)
            
            // remove the savedNotification
            savedNotification = nil
        } else {
            DDLogDebug("No saved notification found")
        }
    }
    
    func processNotification (_ notification: [AnyHashable: Any], isForeground:Bool) {
        DDLogVerbose("Called")
        
        // handle offer
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

        if notification[MESSAGE_JSON_FIELD_NAME] == nil {
            DDLogDebug("No notification message found")
            return;
        }
        
        // check if we have already processed this push message
        guard let lastGCMMsgId = notification[GCM_MSG_ID_JSON_FIELD_NAME] as? String else {
            DDLogDebug("Exiting because lastGCMMsgId is nil: \(notification)")
            return;
        }

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
        
        let jsonCustom = notification[CUSTOM_JSON_FIELD_NAME]

        guard let jsonCustomString = jsonCustom as? String else {
            DDLogVerbose("Returning because of JSON custom string: \(String(describing: jsonCustom))")
            return;
        }
        
        let messageTypeStr = (notification[MESSAGE_JSON_FIELD_NAME] as! String)
        let messageType: YBMessageType = YBMessageType(rawValue: messageTypeStr)!
        
        if (messageType == YBMessageType.counterOffer ||
            messageType == YBMessageType.noOffers) {
            
            let bid = Bid(JSONString: jsonCustomString)!
            if (!YBClient.sharedInstance().isSameAsOngoingBid(bidId: bid.id)) {
                DDLogDebug("Not same as ongoingBid. Discarded: \(notification[MESSAGE_JSON_FIELD_NAME] as! String)")
                
                if let ongoingBid = YBClient.sharedInstance().bid {
                    DDLogDebug("Ongoingbid is: \(String(describing: ongoingBid.id)). Incoming is \(String(describing: bid.id))")
                } else {
                    DDLogDebug("Ongoingbid is: nil. Incoming is \(String(describing: bid.id))")
                }
                return;
            }
            
            switch messageType {
                
            case YBMessageType.counterOffer:
                DDLogDebug("COUNTER OFFER RCVD")
                // -- THIS CODEPATH IS NOT EXECUTED --
                assert(false)
                
            case YBMessageType.noOffers:

                DDLogDebug("NOOFFERS RCVD")
                if isForeground == true{
                    postNotification(BidNotifications.noOffers, value: bid)
                    DDLogDebug("FG No_Offer \(YBMessageType.noOffers)")
                }
                else{
                   LocalNotificationService.sendNotification(title: YBMessageType.noOffers.rawValue, subtitle: "", body: "Your Bid was not accepted by any driver")
                      DDLogDebug("BG No_Offer \(YBMessageType.noOffers)")
                }
            default:
                DDLogError("Weird message received during Bid1: \(messageType)")
                break
            }
        } else if (messageType == YBMessageType.driverEnRoute ||
                    messageType == YBMessageType.rideStart ||
                    messageType == YBMessageType.driverArrived ||
                    messageType == YBMessageType.rideEnd ||
                    messageType == YBMessageType.rideCancelled) {
            
            let ride = Ride(JSONString: jsonCustomString)!

            if (!YBClient.sharedInstance().isSameAsOngoingBid(bidId: ride.bidId)) {
                
                if let ongoingBid = YBClient.sharedInstance().bid {
                    DDLogDebug("Ongoingbid is: \(String(describing: ongoingBid.id)). Incoming is \(String(describing: ride.bidId))")
                } else {
                    DDLogDebug("Ongoingbid is: nil. Incoming is \(String(describing: ride.bidId))")
                }
                return;
            }

            switch messageType {

            case YBMessageType.driverEnRoute:
                
                if (YBClient.sharedInstance().status == .ongoingBid) {
                    if isForeground == true {
                        postNotification(RideNotifications.driverEnRoute, value: ride)
                        DDLogDebug("FG driver enroute \(YBMessageType.driverEnRoute)")
                    }
                    else{
                        LocalNotificationService.sendNotification(title: YBMessageType.driverEnRoute.rawValue, subtitle: "", body: "Your driver is on his way.")
                        DDLogDebug("BG driver enroute \(YBMessageType.driverEnRoute)")
                    }
                }
                
            case .rideStart:
                DDLogDebug("RIDE_START_MESSAGE_TYPE")

                // Publish the Ride started notification This will update the driver status in RideViewController.
                if isForeground == true {
                    postNotification(RideNotifications.rideStart, value: "")
                    DDLogDebug("FG \(YBMessageType.rideStart)")
                }
                else{
                    LocalNotificationService.sendNotification(title: YBMessageType.rideStart.rawValue, subtitle: "", body: "Your ride has been started")
                    DDLogDebug("BG \(YBMessageType.rideStart)")
                }
                
            case .driverArrived:
                DDLogDebug("DRIVER_ARRIVED_MESSAGE_TYPE")
                
                // Publish the Driver Arrived notification This will update the driver status in RideViewController.
                if isForeground == true {
                    postNotification(RideNotifications.driverArrived, value: "")
                     DDLogDebug("FG \(YBMessageType.driverArrived)")
                }else{
                    LocalNotificationService.sendNotification(title: YBMessageType.driverArrived.rawValue, subtitle: "", body: "Your Driver has arrived at pick up location")
                     DDLogDebug("BG \(YBMessageType.driverArrived)")
                }

                break
                
            case .rideEnd:
                DDLogDebug("RIDE_END_MESSAGE_TYPE")
                if isForeground == true {
                    postNotification(RideNotifications.rideEnd, value: "")
                     DDLogDebug("FG \(YBMessageType.rideEnd)")
                }
                
            case .rideCancelled:
                DDLogDebug("RIDE_CANCELLED_MESSAGE_TYPE")
                if isForeground == true {
                    postNotification(RideNotifications.rideCancelled, value: "")
                     DDLogDebug("FG \(YBMessageType.rideCancelled)")
                }else{
                   LocalNotificationService.sendNotification(title: YBMessageType.rideCancelled.rawValue, subtitle: "", body: "Your ride was cancelled")
                   DDLogDebug("BG \(YBMessageType.rideCancelled)")
                }

            default:
                DDLogError("Weird message received during Bid2: \(messageType)")
                break
            }
        } else {
            DDLogError("Weird message received \(messageType)")
        }
    }
    
    //MARK: Utility
    
    open static func registerForPushNotifications() {
        
        let application: UIApplication = UIApplication.shared
        let appDelegate: UIApplicationDelegate = UIApplication.shared.delegate  as! AppDelegate
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (bool, error) in
                if let error = error{
                    DDLogVerbose("Error in authorization \(error.localizedDescription)")
                } else {
                    application.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
}
