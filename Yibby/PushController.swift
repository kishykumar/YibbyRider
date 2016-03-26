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

@objc public protocol PushControllerProtocol {
    func receiveRemoteNotification(notification:[NSObject:AnyObject])
}

public class PushController: NSObject, PushControllerProtocol {
    
    let OFFER_MESSAGE_TYPE = "OFFER"
    let NO_OFFERS_MESSAGE_TYPE = "NO_OFFERS"
    let RIDE_START_MESSAGE_TYPE = "RIDE_START"
    let DRIVER_EN_ROUTE_MESSAGE_TYPE = "DRIVER_EN_ROUTE"

    let MESSAGE_FIELD_NAME = "message"
    let CUSTOM_FIELD_NAME = "custom"
    
    public override init() {
        super.init()
    }

    //MARK: Receiving remote notification
    public func receiveRemoteNotification(notification: [NSObject : AnyObject]) {
        
        print(notification)
        
        // handle offer
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mmdc : MMDrawerController = appDelegate.window?.rootViewController as! MMDrawerController

        switch notification[MESSAGE_FIELD_NAME] as! String {
            
        case OFFER_MESSAGE_TYPE:
            print("OFFER RCVD")
            // present the view controller and pass the data
            if let mmnvc = mmdc.centerViewController as? UINavigationController {

                // get the storyboard to instantiate the viewcontroller
                let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                // parse the notification to get the bid data
                let jsonCustom = notification[CUSTOM_FIELD_NAME]
                if let data = jsonCustom!.dataUsingEncoding(NSUTF8StringEncoding) {
                    let topJson = JSON(data: data)
                    let offerJson = topJson["bid"]
                    
                    print("my offer json \(offerJson)")
                    
                    let confirmRideViewController = mainstoryboard.instantiateViewControllerWithIdentifier("ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
                    mmnvc.pushViewController(confirmRideViewController, animated: true)
//                        rootVC.presentViewController(confirmRideViewController, animated: true, completion: nil)
                }
            }
        
        case NO_OFFERS_MESSAGE_TYPE:
            print("NOOFFERS RCVD")
            
            
            if let mmnvc = mmdc.centerViewController as? UINavigationController {
                mmnvc.popViewControllerAnimated(true)
                Util.displayAlert(mmnvc.visibleViewController!, title: "No offers from drivers.", message: "Your bid was not accepted by any driver")
            }

        default: break
            
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