//
//  LocalNotificationService.swift
//  Yibby
//
//  Created by Prabhdeep Singh on 8/2/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import Foundation
import UserNotifications
import CocoaLumberjack

class LocalNotificationService{
   
    static func sendNotification(title:String, subtitle:String, body:String){
        let notification = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        notification.title = title
        notification.subtitle = subtitle
        notification.body = body
        notification.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: "Notification", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
}
