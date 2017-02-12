 //
//  AppDelegate.swift
//  Example
//
//  Created by Kishy Kumar on 1/9/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import MMDrawerController
import GoogleMaps
import BaasBoxSDK
import CocoaLumberjack
import Fabric
import Crashlytics
import IQKeyboardManagerSwift

 
// TODO:
// 1. Bug: Remove the 35 seconds timeout code to make a sync call to webserver
// 2. Bug: Fix the SVProgressHUD (singleton) issue where pressing back button and then Trips again pops off the HUD early. 
// 3. Segue freezing in iOS9. Test using static data instead of dynamic.
// 4: Check for "TODO:" in the entire projet
// 5: Need to rethink the Initial Setup. For eg. when to send push token to webserver. Why to enable push if user is not authenticated?
// 6: Add the swipe down code using IQKeyboardManagerSwift
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {
 //-- we have removed this because we are not sending upstream messages via GCM

    // MARK: - Properties
    var window: UIWindow?

    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"
    let APP_FIRST_RUN = "FIRST_RUN"

    let GOOGLE_API_KEY_IOS = "AIzaSyAYFgM-PEhhVdXjO3jm0dWhkhHirSXKu9s"
    let BAASBOX_APPCODE = "1234567890"
    let BAASBOX_URL = "http://custom-env.cjamdz6ejx.us-west-1.elasticbeanstalk.com"
    
    var centerContainer: MMDrawerController?
    
    var pushController: PushController =  PushController()

    var initialized: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // setup Crashlytics
        Fabric.with([Crashlytics.self])
        
        // Configure Baasbox
        BaasBox.setBaseURL(BAASBOX_URL, appCode: BAASBOX_APPCODE)

        setupLogger()
        setupLocationService()
        setupKeyboardManager()

        DDLogDebug("LaunchOptions \(launchOptions)");
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GOOGLE_API_KEY_IOS)
        
        // [START_EXCLUDE]
        // Configure the Google context: parses the GoogleService-Info.plist, and initializes
        // the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        // [END_EXCLUDE]
        
        // [START start_gcm_service]
        let gcmConfig = GCMConfig.default()
        gcmConfig?.receiverDelegate = self
        GCMService.sharedInstance().start(with: gcmConfig)
        // [END start_gcm_service]
        
        return true
    }

    func setupLogger() {
        
        // setup logger
        if #available(iOS 10.0, *) {
            DDLog.add(DDASLLogger.sharedInstance, with: .all) // ASL = Apple System Logs
        } else {
            DDLog.add(DDASLLogger.sharedInstance, with: .all) // ASL = Apple System Logs
            DDLog.add(DDTTYLogger.sharedInstance, with: .all) // TTY = Xcode console
        }
        
        DDTTYLogger.sharedInstance.logFormatter = LogFormatter() // print filename, line#
        DDASLLogger.sharedInstance.logFormatter = LogFormatter() // print filename, line#
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.logFormatter = LogFormatter() // print filename, line#
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    func setupLocationService() {
        // setup LocationService
        LocationService.sharedInstance().setupLocationManager()
    }
    
    func setupKeyboardManager() {
        
        // Setup IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }
    
    func initializeMainViewController () {
        DDLogVerbose("Initializing MainViewController");

        let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)

        let centerController = biddingStoryboard.instantiateViewController(withIdentifier: "MainViewControllerIdentifier") as! MainViewController;
        
        let centerNav = UINavigationController(rootViewController: centerController)
        
        let drawerStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Drawer, bundle: nil)
        
        let leftController = drawerStoryboard.instantiateViewController(withIdentifier: "LeftNavDrawerViewControllerIdentifier") as! LeftNavDrawerViewController;
        
        centerContainer = MMDrawerController(center: centerNav, leftDrawerViewController: leftController)
        
        centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode()
        centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.all
    }
    
    // BaasBox login user
    func loginUser(_ usernamei: String, passwordi: String) {
        let client: BAAClient = BAAClient.shared()
        DDLogVerbose("Logging in user with username \(usernamei)")

        client.authenticateUser(usernamei, password: passwordi, completion: {(success, error) -> Void in
            if (success) {
                DDLogVerbose("logged in automatically in else case: \(success)")
            }
            else {
                DDLogVerbose("error in logging in user automatically\(error)")
            }
        })
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribe(withToken: self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if ((error as! NSError).code == 3001) {
                            DDLogVerbose("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            DDLogVerbose("Subscription failed: \((error as! NSError).localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        DDLogVerbose("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        DDLogDebug("Called");

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        if let vvc = window!.visibleViewController as? FindOffersViewController {
            DDLogDebug("Saving the timer")
            vvc.saveProgressTimer()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        DDLogDebug("Called");

        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        DDLogDebug("Called");

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    // [START connect_gcm_service]
    func applicationDidBecomeActive(_ application: UIApplication) {
        DDLogDebug("Called");
        
        // Connect to the GCM server to receive non-APNS notifications
        
        GCMService.sharedInstance().connect(handler: {
            (error) -> Void in
            if error != nil {
                DDLogWarn("Could not connect to GCM: \((error as! NSError).localizedDescription)")
            } else {
                self.connectedToGCM = true
                DDLogDebug("Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
        
        if let vvc = window!.visibleViewController as? FindOffersViewController {
            DDLogVerbose("Restoring the timer")
            vvc.restoreProgressTimer()
        }
        
        // process a saved notification, if any
        pushController.processSavedNotification()
    }
    // [END connect_gcm_service]

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // [START receive_apns_token]
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data ) {
            DDLogDebug("Application device token \(deviceToken)");

            self.pushController.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)

            // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
            let instanceIDConfig = GGLInstanceIDConfig.default()
            instanceIDConfig?.delegate = self
            
            // Start the GGLInstanceID shared instance with that config and request a registration
            // token to enable reception of notifications
            
            GGLInstanceID.sharedInstance().start(with: instanceIDConfig)
            registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject,
                kGGLInstanceIDAPNSServerTypeSandboxOption:true as AnyObject]
        
            sendGCMTokenToServer()

            // [END get_gcm_reg_token]
    }
    
    fileprivate func enablePushNotificationsFromServer (_ gcmToken: String) {
        let client: BAAClient = BAAClient.shared();

        client.enablePushNotifications(forGCM: gcmToken, completion: { (success, error) -> Void in
            if (success) {
                DDLogVerbose("enabled push notifications: Success")
                SplashViewController.pushSuccessful = true            }
            else {
                DDLogWarn("Error: enabled push notifications: \(error)")
                
                // tell Splash that push registration was not successful
                SplashViewController.pushSuccessful = false
            }
            SplashViewController.pushRegisterResponseArrived = true
        })
    }
    
    // [START receive_apns_token_error]
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: Error ) {
        DDLogWarn("Registration for remote notification failed with error: \(error.localizedDescription)")
        // [END receive_apns_token_error]
//        let userInfo = ["error": error.localizedDescription]
//        NSNotificationCenter.defaultCenter().postNotificationName(
//            registrationKey, object: nil, userInfo: userInfo)
        
        // tell Splash that push registration was not successful
        SplashViewController.pushSuccessful = false
        SplashViewController.pushRegisterResponseArrived = true
    }
    
    
    // GCM Registration Handler
    func registrationHandler(_ registrationToken: String?, error: Error?) {

        if let registrationToken = registrationToken {
            self.registrationToken = registrationToken

            // enable push notification
            enablePushNotificationsFromServer(registrationToken)

            DDLogDebug("Registration Token: \(registrationToken)")
            //            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
        } else {
            DDLogWarn("Registration to GCM failed with error: \((error as? NSError)?.localizedDescription)")
            let userInfo = ["error": (error as? NSError)?.localizedDescription]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
            
            // tell Splash that push registration was not successful
            SplashViewController.pushSuccessful = false
            SplashViewController.pushRegisterResponseArrived = true
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        DDLogInfo("The GCM registration token needs to be changed.")
        sendGCMTokenToServer()
    }
    
    func sendGCMTokenToServer() {
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func application( _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        DDLogDebug("Remote push received1: \(userInfo)")

        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message
        NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
            userInfo: userInfo)

        self.pushController.receiveRemoteNotification(application, notification: userInfo)
    }
    
    func application( _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        DDLogDebug("Remote push received2: \(userInfo)")

        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message

        NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
            userInfo: userInfo)

        self.pushController.receiveRemoteNotification(application, notification: userInfo)

            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            handler(UIBackgroundFetchResult.noData);
    }

    func willSendDataMessage(withID messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessage(withID messageID: String!) {
        // Did successfully send message identified by messageID
    }


    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
}
 
public extension UIWindow {
   public var visibleViewController: UIViewController? {
       return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
   }
    
   public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
       if let nc = vc as? UINavigationController {
           return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
       } else if let tc = vc as? UITabBarController {
           return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
       } else {
           if let pvc = vc?.presentedViewController {
               return UIWindow.getVisibleViewControllerFrom(pvc)
           } else {
               if let mmd = vc as? MMDrawerController {
                   return UIWindow.getVisibleViewControllerFrom(mmd.centerViewController)
               }
               return vc
           }
       }
   }
}
 
extension UIViewController {
   func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
//                                                                action: #selector(UIViewController.dismissKeyboard))
    
//        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
    
//        view.addGestureRecognizer(tap)
//        view.addGestureRecognizer(swipeDown)
   }
   
   func dismissKeyboard() {
       view.endEditing(true)
   }
}
 
 
