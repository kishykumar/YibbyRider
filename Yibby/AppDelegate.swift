//
//  AppDelegate.swift
//  Yibby
//
//  Created by Kishy Kumar on 1/9/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import MMDrawerController
import GoogleMaps
import BaasBoxSDK
import CocoaLumberjack
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import FBSDKCoreKit
import FBSDKLoginKit
import FoldingCell
import GooglePlaces
import ObjectMapper
import KSCrash
import OHHTTPStubs

// TODO:
// 1. Bug: Remove the 35 seconds timeout code to make a sync call to webserver
// 2. Bug: Fix the SVProgressHUD (singleton) issue where pressing back button and then Trips again pops off the HUD early. 
// 3. Segue freezing in iOS9. Test using static data instead of dynamic.
// 4: **** Check for "TODO:" in the entire project ****
// 5: Need to rethink the Initial Setup. For eg. when to send push token to webserver. Why to enable push if user is not authenticated?
// 6: Add the swipe down code using IQKeyboardManagerSwift
// 7: Integrate KSCrash

var stringSocial = String ()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate,GIDSignInDelegate,GIDSignInUIDelegate {

    // MARK: - Properties
    var window: UIWindow?

    fileprivate var isSandbox = true
    
    fileprivate var connectedToGCM = false
    fileprivate var subscribedToTopic = false
    fileprivate var gcmSenderID: String?
    fileprivate var registrationToken: String?
    fileprivate var registrationOptions = [String: AnyObject]()
    
    fileprivate let registrationKey = "onRegistrationCompleted"
    fileprivate let messageKey = "onMessageReceived"
    fileprivate let subscriptionTopic = "/topics/global"
    fileprivate let APP_FIRST_RUN = "FIRST_RUN"

    fileprivate let GOOGLE_API_KEY_IOS = "AIzaSyAYFgM-PEhhVdXjO3jm0dWhkhHirSXKu9s"
    
    fileprivate let GMS_Places_API_KEY_IOS = "AIzaSyAWERnbH-gsqbtz3fXE7WEUH3tNGJTpRLI"
    fileprivate let BAASBOX_APPCODE = "1234567890"
    //fileprivate let BAASBOX_URL = "http://custom-env.cjamdz6ejx.us-west-1.elasticbeanstalk.com"
    fileprivate let BAASBOX_URL = "http://3e67cdcf.ngrok.io"

    var pushController: PushController =  PushController()
    
    // App initialization variables
    fileprivate var appInitDispatchGroup: DispatchGroup?
    fileprivate var pushError: Error? = nil
    fileprivate var syncError: Error? = nil
    fileprivate var loginError: Error? = nil
    fileprivate var handlePushStatusCodeBlock: ((_ isSuccess: Bool, _ error: Error?) -> Void)?
    
    var initialized: Bool = false
    var centerContainer: MMDrawerController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])

        // Configure Baasbox
        BaasBox.setBaseURL(BAASBOX_URL, appCode: BAASBOX_APPCODE)

        setupLogger()
        setupKeyboardManager()
        
        let kSCrashInstallationEmail = KSCrashInstallationEmail.sharedInstance()
        kSCrashInstallationEmail?.recipients = ["kishykumar@gmail.com"]
        
        DDLogDebug("LaunchOptions \(String(describing: launchOptions))");
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GOOGLE_API_KEY_IOS)
        GMSPlacesClient.provideAPIKey(GMS_Places_API_KEY_IOS)
        
        // [START_EXCLUDE]
        // Configure the Google context: parses the GoogleService-Info.plist, and initializes
        // the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)

        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        // [END_EXCLUDE]
        
        // [START start_gcm_service]
        let gcmConfig = GCMConfig.default()
        gcmConfig?.receiverDelegate = self
        GCMService.sharedInstance().start(with: gcmConfig)
        // [END start_gcm_service]
        
        // Init facebook login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Init Google signIn
        GIDSignIn.sharedInstance().delegate = self

        return true
    }

    fileprivate func setupLogger() {
        
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

    fileprivate func setupKeyboardManager() {
        
        // Setup IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
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
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    // [END disconnect_handler]
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        
        if stringSocial == "facebook"
        {
            if #available(iOS 9.0, *) {
                return FBSDKApplicationDelegate.sharedInstance().application(
                    application,
                    open: url as URL!,
                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                    annotation: options[UIApplicationOpenURLOptionsKey.annotation]
                )
            } else {
                // Fallback on earlier versions
            }
            
        }
        else{
            if #available(iOS 9.0, *) {
                return GIDSignIn.sharedInstance().handle(url,
                                                         sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                         annotation: options[UIApplicationOpenURLOptionsKey.annotation])
                
            } else {
                
                // Fallback on earlier versions
            }
        }
               return true
    }
    
    public func application(_ application: UIApplication, open url1: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url1 as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        DDLogDebug("Called");

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
//        if let vvc = window!.visibleViewController as? FindOffersViewController {
//            DDLogDebug("Saving the timer")
//            vvc.saveProgressTimer()
//        }
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

        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.default()
        instanceIDConfig?.delegate = self
        
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        
        GGLInstanceID.sharedInstance().start(with: instanceIDConfig)

        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject,
            kGGLInstanceIDAPNSServerTypeSandboxOption: isSandbox as AnyObject]

        sendGCMTokenToServer()

        // [END get_gcm_reg_token]
    }
    
    // [START receive_apns_token_error]
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: Error ) {
        DDLogWarn("Registration for remote notification failed with error: \(error.localizedDescription)")
        
        // [END receive_apns_token_error]
        //        let userInfo = ["error": error.localizedDescription]
        //        NSNotificationCenter.defaultCenter().postNotificationName(
        //            registrationKey, object: nil, userInfo: userInfo)
        
        self.pushStatusCallback(isSuccess: false, error: error)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        DDLogVerbose("User gave notificationSettings: \(notificationSettings)")
    }
    
    fileprivate func enablePushNotificationsFromServer (_ gcmToken: String) {
        let client: BAAClient = BAAClient.shared();

        client.enablePushNotifications(forGCM: gcmToken, completion: { (success, error) -> Void in
            if (success) {
                DDLogVerbose("enabled push notifications: Success")
                
                self.pushStatusCallback(isSuccess: true, error: nil)
            }
            else {
                DDLogWarn("Error: enabling push notifications: \(String(describing: error))")
                
                self.pushStatusCallback(isSuccess: false, error: error)
            }
        })
    }
    
    fileprivate func pushStatusCallback(isSuccess: Bool, error: Error?) {
        
        DispatchQueue.main.async {
        
            if (self.handlePushStatusCodeBlock != nil) {
                
                if let codeBlock = self.handlePushStatusCodeBlock {
                    codeBlock(isSuccess, error)
                }
                
                self.appInitDispatchGroup?.leave()
            }
            
            // This callback should be called just once.
            // There's a bug in iOS 10 that push registration callback is called twice.
            self.handlePushStatusCodeBlock = nil
        }
    }

    // GCM Registration Handler
    func registrationHandler(_ registrationToken: String?, error: Error?) {

        if let registrationToken = registrationToken {
            self.registrationToken = registrationToken

            // enable push notification
            enablePushNotificationsFromServer(registrationToken)

            DDLogDebug("Registration Token: \(registrationToken) \(Thread.isMainThread)")
            //            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
        } else {
            DDLogWarn("Registration to GCM failed with error: \(String(describing: (error as NSError?)?.localizedDescription))")
            if let ns_error = error {
                let userInfo = ["error": (ns_error as NSError).localizedDescription]
                NotificationCenter.default.post(
                    name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
                
                self.pushStatusCallback(isSuccess: false, error: error)
            }
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        DDLogInfo("The GCM registration token needs to be changed.")
        sendGCMTokenToServer()
    }
    
    fileprivate func sendGCMTokenToServer() {
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
    
    // MARK: - App initialization
    
    func initializeApp(_ doPaymentSetup: Bool) {
        
        // LocationService
        self.setupLocationService()
        
        self.appInitDispatchGroup = DispatchGroup()
        
        if let dispatchGroup = self.appInitDispatchGroup {
            
            self.pushError = nil
            self.syncError = nil
            
            // PushNotifications
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                
                // Initialize a callback to be called just once in response to push success, as
                // there's a bug in iOS 10 that push registration callback is called twice.
                self.handlePushStatusCodeBlock = { (isSuccess: Bool, error: Error?) -> Void in
                    
                    if (isSuccess) {
                        
                    } else {
                        self.pushError = error
                    }
                }
                
                self.registerForPushNotifications()
            }
            
            // Payment,Sync
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                self.setupWebserver(doPaymentSetup)
            }
            
            // Notify the main thread when initialization is done.
            dispatchGroup.notify(queue: .main) {
                
                // Check for errors
                if (self.pushError != nil) {
                    
                    DDLogVerbose("Push Error during init \(String(describing: self.pushError))")
                    self.handleAppInitError(self.pushError)
                    return;
                    
                } else if (self.syncError != nil) {
                    
                    DDLogVerbose("Sync Error during init \(String(describing: self.syncError))")
                    self.handleAppInitError(self.syncError)
                    return;
                    
                }
                
                DDLogVerbose("App Initialization successfully complete")
                
                self.initializeMainViewController()
                if let centerNav = self.centerContainer?.centerViewController as? UINavigationController {
                    var controllers = centerNav.viewControllers
                    
                    switch (YBClient.sharedInstance().status) {
                    case .looking:
                        
                        // Remove the bid if it existed
                        let bidId = YBClient.sharedInstance().getPersistedBidId()
                        if (bidId != nil) {
                            YBClient.sharedInstance().bid = nil
                        }
                        
                        // nothing to do here. MainViewController will be shown.
                        break
                        
                    case .ongoingBid:
                        
                        let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
                        
                        let findOffersViewController = biddingStoryboard.instantiateViewController(withIdentifier: "FindOffersViewControllerIdentifier") as! FindOffersViewController
                        controllers.append(findOffersViewController)
                        break
                        
                    case .driverEnRoute:
                        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
                        
                        let rideViewController = rideStoryboard.instantiateViewController(withIdentifier: "RideViewControllerIdentifier") as! RideViewController
                        
                        rideViewController.controllerState = .driverEnRoute
                        
                        controllers.append(rideViewController)
                        
                        break
                        
                    case .driverArrived:
                        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
                        
                        let rideViewController = rideStoryboard.instantiateViewController(withIdentifier: "RideViewControllerIdentifier") as! RideViewController
                        
                        rideViewController.controllerState = .driverArrived
                        
                        controllers.append(rideViewController)
                        
                        break
                        
                    case .onRide:
                        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
                        
                        let rideViewController = rideStoryboard.instantiateViewController(withIdentifier: "RideViewControllerIdentifier") as! RideViewController
                        
                        rideViewController.controllerState = .rideStart
                        
                        controllers.append(rideViewController)
                        
                        break
                        
                    case .pendingRating:
                        
                        let rideEndStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.RideEnd, bundle: nil)
                        
                        let rideEndViewController = rideEndStoryboard.instantiateViewController(withIdentifier: "RideEndViewControllerIdentifier") as! RideEndViewController
                        controllers.append(rideEndViewController)
                        
                        break
                        
                        
                    case .failedNoOffers:
                        fallthrough
                    case .failedHighOffers:
                        
                        break
                    }
                    
                    centerNav.setViewControllers(controllers, animated: true)
                    self.window!.visibleViewController?.present(self.centerContainer!, animated: true, completion: nil)
                    
                    // Post the notification to the caller View Controller
                    postNotification(AppInitNotifications.initStatus,
                                     value: AppInitReturnCode.success)
                    
                    self.initialized = true
                }
            }
        }
    }
    
    // Register for remote notifications
    fileprivate func registerForPushNotifications () {
        PushController.registerForPushNotifications()
    }
    
    fileprivate func setupLocationService() {
        LocationService.sharedInstance().setupLocationManager()
    }
    
    fileprivate func initializeMainViewController () {
        DDLogVerbose("Initializing MainViewController");
        
        let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
        let centerController = biddingStoryboard.instantiateViewController(withIdentifier: "MainViewControllerIdentifier") as! MainViewController;
        let centerNav = UINavigationController(rootViewController: centerController)
        let drawerStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Drawer, bundle: nil)
        let leftController = drawerStoryboard.instantiateViewController(withIdentifier: "LeftNavDrawerViewControllerIdentifier") as! LeftNavDrawerViewController;
        
        self.centerContainer = MMDrawerController(center: centerNav, leftDrawerViewController: leftController)
        
        self.centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode()
        self.centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.all
    }
    
    fileprivate func setupWebserver(_ doPaymentSetup: Bool) {
        
        let client: BAAClient = BAAClient.shared()
        let syncDispatchGroup: DispatchGroup = DispatchGroup()
        
        if (doPaymentSetup) {
            
            // 1. Braintree.setupConfiguration
            syncDispatchGroup.enter()
            
            // TODO: Do the Braintree setup in the sync call itself to avoid two calls
            BraintreePaymentService.sharedInstance().setupConfiguration({ (error: NSError?) -> Void in
                if (error == nil) {
                    
                } else {
                    DDLogError("Error in Braintree setup: \(String(describing: error))")
                    self.syncError = error
                }
                syncDispatchGroup.leave()
            })
            
            syncDispatchGroup.wait()

            if (self.syncError != nil) {
                self.appInitDispatchGroup?.leave()
                return;
            }
        }
        
        // 2. BAAClient.syncClient
        syncDispatchGroup.enter()

        //YBClient.sharedInstance().bid = nil // do this to remove app's bid state
        let bidId = YBClient.sharedInstance().getPersistedBidId()
        client.syncClient(BAASBOX_RIDER_STRING, bidId: bidId, completion: { (success, error) -> Void in

            if let success = success {
                let syncModel = Mapper<YBSync>().map(JSONObject: success)

                if let syncData = syncModel {

                    DDLogVerbose("syncApp syncdata for bidid: \(String(describing: bidId))")
                    dump(syncData)

                    YBClient.sharedInstance().syncClient(syncData)
                    
                } else {
                    DDLogError("Error in parsing sync data: \(String(describing: error))")
                    self.syncError = error
                }
            } else {
                DDLogVerbose("syncClient failed: \(String(describing: error))")
                self.syncError = error
            }

            syncDispatchGroup.leave()
        })
        
        syncDispatchGroup.wait()
        
        if (self.syncError != nil) {
            self.appInitDispatchGroup?.leave()
            return;
        }
        
        DDLogVerbose("Success in SetupWebserver")
        self.appInitDispatchGroup?.leave()
    }
    
    fileprivate func handleAppInitError(_ error: Error?) {
        
        if let myNSError = error as NSError? {
            
            // If it's authentication error, show the logic view controller
            if (myNSError.domain == BaasBox.errorDomain() &&
                myNSError.code == WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                
                postNotification(AppInitNotifications.initStatus,
                                 value: AppInitReturnCode.loginError)
                
                DDLogVerbose("Error in webRequest1: \(String(describing: error))")
            } else {
                
                // Post the notification that registration was not successful
                postNotification(AppInitNotifications.initStatus,
                                 value: AppInitReturnCode.error)
            }
        }
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
 
 
