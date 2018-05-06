//
//  AlertUtil.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import GoogleMaps
import BaasBoxSDK
import CocoaLumberjack

public typealias AlertUtilCompletionCallback = () -> Void

open class AlertUtil {
    
    static func displayAlertOnVC(_ vc: UIViewController, title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .cancel, handler: { (action) -> Void in
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func displayAlertOnVC(_ vc: UIViewController, title: String, message: String,
                                 completionBlock: @escaping AlertUtilCompletionCallback) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .cancel, handler: { (action) -> Void in
            completionBlock()
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func displayAlertOnVC(_ vc: UIViewController, title: String, message: String,
                                 action1: String,
                                 style1: UIAlertActionStyle,
                                 action2: String,
                                 style2: UIAlertActionStyle,
                                 completionBlock: @escaping AlertUtilCompletionCallback) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // Add action1
        alert.addAction(UIAlertAction(title: action1,
                                      style: style1,
                                      handler: { (action) -> Void in
                                        completionBlock()
        }))
        
        // Add action2
        alert.addAction(UIAlertAction(title: action2, style: style2,
                                      handler: { (action) -> Void in
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
//    static func displayAlert(_ title: String,
//                             message: String) {
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .cancel, handler: { (action) -> Void in
//        }))
//
//        if let vvc = appDelegate.window?.visibleViewController {
//            vvc.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    static func displayAlert(_ title: String,
//                             message: String,
//                             completionBlock: @escaping AlertUtilCompletionCallback) {
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .cancel, handler: { (action) -> Void in
//            completionBlock()
//        }))
//
//        if let vvc = appDelegate.window?.visibleViewController {
//            vvc.present(alert, animated: true, completion: nil)
//        }
//    }

    // An alert that shows an action and cancel with completionBlock
    static func displayChoiceAlertOnVC(_ vc: UIViewController, title: String, message: String,
                                       completionActionString: String,
                                       completionBlock: @escaping AlertUtilCompletionCallback) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        // Add OK
        alert.addAction(UIAlertAction(title: completionActionString,
                                    style: .default,
                                    handler: { (action) -> Void in
            completionBlock()
        }))

        // Add Cancel
        alert.addAction(UIAlertAction(title: InterfaceString.Cancel, style: .cancel,
                                    handler: { (action) -> Void in
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func displaySettingsAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

        // Add Settings
        alert.addAction(UIAlertAction(title: InterfaceString.SettingsAction, style: .default, handler: { (action) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        // Add OK
        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .cancel, handler: { (action) -> Void in
        }))
        
        if let vvc = appDelegate.window?.visibleViewController {
            vvc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func displayLocationAlert () {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined, .restricted, .denied:
                AlertUtil.displaySettingsAlert("Location services disabled", message: "Please provide Yibby access to location services in the Settings -> Privacy -> Location Services")
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        } else {
            AlertUtil.displaySettingsAlert("Location services disabled", message: "Please turn on location services in the Settings -> Privacy -> Location Services")
        }
    }
}
