//
//  PushController.swift
//  YibbyPartner
//
//  Created by Kishy Kumar on 3/9/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc public protocol PushControllerProtocol {
    func receiveRemoteNotification(notification:[NSObject:AnyObject])
}

public class PushController: NSObject, PushControllerProtocol {
    
    let OFFER_MESSAGE_TYPE = "OFFER"
    let RIDE_START_MESSAGE_TYPE = "RIDE_START"
    let MESSAGE_FIELD_NAME = "message"
    let CUSTOM_FIELD_NAME = "custom"
    
    public override init() {
        super.init()
    }

    //MARK: Receiving remote notification
    public func receiveRemoteNotification(notification: [NSObject : AnyObject]) {

        if (notification[MESSAGE_FIELD_NAME] as! String == OFFER_MESSAGE_TYPE) {
            
            print(notification)
            
            // handle offer
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            // present the view controller and pass the data
            let currentVC = appDelegate.window?.rootViewController
            
            if (currentVC != nil) {
                let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

                let jsonCustom = notification[CUSTOM_FIELD_NAME]
                if let data = jsonCustom!.dataUsingEncoding(NSUTF8StringEncoding) {
                    let topJson = JSON(data: data)
                    let offerJson = topJson["bid"]
                    
                    print("my offer json \(offerJson)")
                    
                    let confirmRideViewController = mainstoryboard.instantiateViewControllerWithIdentifier("ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
                    currentVC!.presentViewController(confirmRideViewController, animated: true, completion: nil)
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