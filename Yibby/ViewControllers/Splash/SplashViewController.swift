//
//  SplashViewController.swift
//  YibbyPartner
//
//  Created by Kishy Kumar on 5/19/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import LaunchScreen
import BaasBoxSDK
import MMDrawerController

public struct AppInitNotifications {
    static let pushStatus = TypedNotification<Bool>(name: "com.Yibby.SplashViewController.pushSuccess")
}

class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    static let SPLASH_SCREEN_TAG = 10
    
    let APP_FIRST_RUN = "FIRST_RUN"
    let ERROR_TEXTVIEW_TAG = 100
    
    var launchScreenVC: LaunchScreenViewController?
    var snapshot: UIImage?
    var imageView: UIImageView?
    fileprivate var pushStatusObserver: NotificationObserver?

//    var syncAPIResponseArrived: Bool = false
//    var paymentsSetupCompleted: Bool = false
//    static var pushRegisterResponseArrived: Bool = false
//    static var pushSuccessful: Bool = false
    
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSplash()
        setupNotificationObservers()
    }
    
    deinit {
        DDLogVerbose("SplashViewController Deinit")
        removeNotificationObservers()
    }
    
    fileprivate func setupNotificationObservers() {
        
        pushStatusObserver = NotificationObserver(notification: AppInitNotifications.pushStatus) { [unowned self] success in
            DDLogVerbose("pushStatusObserver status: \(success)")
            
            if (success) {
                self.pushRegistrationSuccessCallback()
            } else {
                self.pushRegistrationErrorCallback()
            }
        }
    }
    
    fileprivate func removeNotificationObservers() {
        pushStatusObserver?.removeObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doSetup () {
        DDLogVerbose("Called");
        
        ///////////////////////////////////////////////////////////////////////////
        // We do the app's initialization in viewDidAppear().
        // 1. Setup Splash Screen
        // 2. Register for remote notifications
        // 3. Sync the app with the webserver by making the http call
        // 4. Segue to the appropriate view controller one all initialization is done
        ///////////////////////////////////////////////////////////////////////////
        
        // Do any additional setup after loading the view.
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // show the launch screen
        showLaunchScreen()
        
        // Clear keychain on first run in case of reinstallation
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: APP_FIRST_RUN) == nil {
            // Delete values from keychain here
            userDefaults.setValue(APP_FIRST_RUN, forKey: APP_FIRST_RUN)
            LoginViewController.removeLoginKeyChainKeys()
        }
        
        let client: BAAClient = BAAClient.shared()

        if client.isAuthenticated() {
            DDLogVerbose("User already authenticated");
            
            appDelegate.initializeApp()
            
        } else {
            DDLogVerbose("User NOT authenticated");
            
            let signupStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.SignUp,
                                                              bundle: nil)
            
            self.present(signupStoryboard.instantiateInitialViewController()!, animated: false, completion: nil)
            
            removeSplash()
        }
    }
    
    // MARK: - Helpers
    
    func showLaunchScreen() {
        let v: UIView = self.launchScreenVC!.view!
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // add the view to window
        appDelegate.window?.addSubview(v)
    }
    
    func dismissSplashSnapshot() {
        imageView!.removeFromSuperview()
        imageView = nil
    }
    
    func initSplash () {
        DDLogVerbose("Adding the splash screen snapshot");
        
        // Instantiate a LaunchScreenViewController which will insert the UIView contained in our Launch Screen XIB
        // as a subview of it's view.
        self.launchScreenVC = LaunchScreenViewController.init(from: self.storyboard)
        
        // Take a snapshot of the launch screen. You could do this at any time you like.
        //        self.snapshot = self.launchScreenVC!.snapshot()
        let v: UIView = self.launchScreenVC!.view!
        
        // To avoid the glitch, add the image during viewDidLoad and remove it when viewDidAppear
        //        imageView = UIImageView(image: snapshot)
        //        imageView!.userInteractionEnabled = true
        //        imageView!.frame = self.view.bounds
        view!.addSubview(v)
    }
    
    func removeSplash () {
        let v: UIView = self.launchScreenVC!.view!
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut,
                       animations: {() -> Void in
                        v.alpha = 0.0
        },
            completion: {(finished: Bool) -> Void in
                DDLogVerbose("Removing the splash screen");
                v.removeFromSuperview()
            }
        )
    }

    func pushRegistrationSuccessCallback() {
        DDLogDebug("pushRegistrationSuccessCallback Called")

//        BraintreePaymentService.sharedInstance().setupConfiguration({ (error: NSError?) -> Void in
//            if (error == nil) {
//            } else {
//            }
//        })
//
//        // wait for requests to finish
//        let timeoutDate: Date = Date(timeIntervalSinceNow: 10.0)
//        
//        while (self.syncAPIResponseArrived == false ||
//            self.paymentsSetupCompleted == false ||
//            SplashViewController.pushRegisterResponseArrived == false) &&
//            (timeoutDate.timeIntervalSinceNow > 0) {
//                
//                CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.1, false)
//        }
        removeSplash()
    }

    func pushRegistrationErrorCallback() {

        let v: UIView = self.launchScreenVC!.view!
        let label: UITextView = v.viewWithTag(ERROR_TEXTVIEW_TAG) as! UITextView
        label.isHidden = false
        
        // earlier we were removing the splash, now just showing the error
        //        removeSplash()
    }
}
