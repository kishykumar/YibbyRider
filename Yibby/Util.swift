//
//  Util.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import SVProgressHUD
import BaasBoxSDK

public class Util {
    static func enableActivityIndicator (view: UIView, tag: Int) {
        // Initiate the activity Indicator
//        let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
//        activityIndicator.center = view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//        activityIndicator.tag = tag
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
        SVProgressHUD.show();
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    static func disableActivityIndicator (view: UIView, tag: Int) {
//        let activityIndicator: UIActivityIndicatorView = view.viewWithTag(tag) as! UIActivityIndicatorView
//        activityIndicator.stopAnimating()
//        activityIndicator.removeFromSuperview()
        
        SVProgressHUD.dismiss();
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    static func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            mmnvc.visibleViewController!.presentViewController(alert, animated: true, completion: nil)
        }
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
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            mmnvc.visibleViewController!.presentViewController(alert, animated: true, completion: nil)
        }
//        appDelegate.window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
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
    
    static func makeWebRequestAndHandleError (vc: UIViewController, webRequest:(errorBlock: (BAAObjectResultBlock)) -> Void) {
        
        webRequest(errorBlock: { (success, error) -> Void in
                        if (error.domain == BaasBox.errorDomain() && error.code == MainViewController.BAASBOX_AUTHENTICATION_ERROR) {
                            // check for authentication error and redirect the user to Login page
                            
                            if let loginViewController = vc.storyboard?.instantiateViewControllerWithIdentifier("LoginViewControllerIdentifier") as? LoginViewController
                            {
                                loginViewController.onStartup = false
                                vc.presentViewController(loginViewController, animated: true, completion: nil)
                            }
                        }
                        else {
                            Util.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                        }
                   })
    }
}
