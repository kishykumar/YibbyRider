//
//  Util.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import BaasBoxSDK
import CocoaLumberjack

public typealias AlertUtilCompletionCallback = () -> Void

open class AlertUtil {
    
    static func displayAlertOnVC(_ vc: UIViewController, title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .default, handler: { (action) -> Void in
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func displayAlert(_ title: String,
                             message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .default, handler: { (action) -> Void in
        }))
        
        if let vvc = appDelegate.window?.visibleViewController {
            vvc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func displayAlert(_ title: String,
                             message: String,
                             completionBlock: @escaping AlertUtilCompletionCallback) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .default, handler: { (action) -> Void in
            completionBlock()
        }))
        
        if let vvc = appDelegate.window?.visibleViewController {
            vvc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func displayChoiceAlert(_ title: String, message: String,
                                   completionActionString: String,
                                   completionBlock: @escaping AlertUtilCompletionCallback) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // Add OK
        alert.addAction(UIAlertAction(title: completionActionString,
                                    style: .default,
                                    handler: { (action) -> Void in
            completionBlock()
        }))
        
        // Add Cancel
        alert.addAction(UIAlertAction(title: InterfaceString.Cancel, style: .default,
                                    handler: { (action) -> Void in
        }))
        
        if let vvc = appDelegate.window?.visibleViewController {
            vvc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func displaySettingsAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

        // Add Settings
        alert.addAction(UIAlertAction(title: InterfaceString.SettingsAction, style: .default, handler: { (action) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        // Add OK
        alert.addAction(UIAlertAction(title: InterfaceString.OK, style: .default, handler: { (action) -> Void in
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
