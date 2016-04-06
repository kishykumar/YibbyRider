//
//  Util.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps

public class Util {
    static func enableActivityIndicator (view: UIView, tag: Int) {
        // Initiate the activity Indicator
        let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.tag = tag
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    static func disableActivityIndicator (view: UIView, tag: Int) {
        let activityIndicator: UIActivityIndicatorView = view.viewWithTag(tag) as! UIActivityIndicatorView
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        activityIndicator.removeFromSuperview()
    }
    
    static func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        appDelegate.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func displaySettingsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Add Settings
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        // Add OK
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        appDelegate.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func displayLocationAlert () {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .NotDetermined, .Restricted, .Denied:
                Util.displaySettingsAlert("Location services disabled", message: "Please provide Yibby access to location services in the Settings -> Privacy -> Location Services")
                break
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                break
            }
        } else {
            Util.displaySettingsAlert("Location services disabled", message: "Please turn on location services in the Settings -> Privacy -> Location Services")
        }
    }
}
