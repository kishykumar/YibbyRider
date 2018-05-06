//
//  DriverEnRouteViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/26/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import GoogleMaps
import ISHPullUp

public enum RideViewControllerState: Int {
    case driverEnRoute = 0
    case driverArrived
    case rideStart
}

public enum DriverStateDescription: String {
    case driverEnRoute = "En Route"
    case driverArrived = "Driver Arrived"
    case rideStarted = "Ride Started"
}

class RideViewController: ISHPullUpViewController {
    
    // MARK: - Properties

    fileprivate var rideStartObserver: NotificationObserver?
    fileprivate var rideEndObserver: NotificationObserver?
    fileprivate var driverArrivedObserver: NotificationObserver?
    
    public var controllerState: RideViewControllerState = .driverEnRoute
    
    // MARK: - Actions
    
    
    // MARK: - Setup functions
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        
        DDLogVerbose("Fired init")
        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
        
        let contentVC = rideStoryboard.instantiateViewController(withIdentifier: "RideContentViewControllerIdentifier") as! RideContentViewController
        
        let bottomVC = rideStoryboard.instantiateViewController(withIdentifier: "RideBottomViewControllerIdentifier") as! RideBottomViewController
        
        self.contentViewController = contentVC
        self.bottomViewController = bottomVC
        dimmingColor = nil
        
        contentVC.pullUpController = self
        bottomVC.pullUpController = self
        
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
        
        setupNotificationObservers()
//        contentDelegate = contentVC
    }

    deinit {
        DDLogVerbose("Fired deinit")
        removeNotificationObservers()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }

//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        DDLogVerbose("KKDBG_RVC disappear")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuButton()
        LocationService.sharedInstance().startFetchingDriverLocation()
        
        if (controllerState == .driverEnRoute) {
            ToastUtil.displayToastOnVC(self,
                                       title: "Bid Accepted!",
                                       body: "Your driver is on his way.",
                                       theme: .success,
                                       presentationStyle: .center,
                                       duration: .forever,
                                       windowLevel: UIWindowLevelNormal)
        }
    }
    
    // MARK: Notifications
    
    fileprivate func setupNotificationObservers() {

        DDLogVerbose("setup notifications observers")
        
        rideStartObserver = NotificationObserver(notification: RideNotifications.rideStart) { [unowned self] comment in
            DDLogVerbose("NotificationObserver rideStart: \(comment)")
            
            YBClient.sharedInstance().status = .onRide
            self.updateControllerState(state: .rideStart)
        }
        
        rideEndObserver = NotificationObserver(notification: RideNotifications.rideEnd) { [unowned self] comment in
            DDLogVerbose("NotificationObserver rideEnd: \(comment)")
            
            YBClient.sharedInstance().status = .pendingRating
            self.rideEndCallback()
        }
        
        driverArrivedObserver = NotificationObserver(notification: RideNotifications.driverArrived) { [unowned self] comment in
            DDLogVerbose("NotificationObserver driverArrived: \(comment)")
            
            YBClient.sharedInstance().status = .driverArrived
            self.updateControllerState(state: .driverArrived)
        }
    }
    
    fileprivate func removeNotificationObservers() {
        DDLogVerbose("removing notifications observers")

        rideStartObserver?.removeObserver()
        rideEndObserver?.removeObserver()
    }
    
    // MARK: - Helpers

    fileprivate func updateControllerState(state: RideViewControllerState) {
        
        self.controllerState = state
        
        switch (state) {
        case .driverArrived:
            driverArrivedCallback()
            
        case .rideStart:
            rideStartCallback()
            
        default:
            break;
        }
    }
    
    func centerMarkers() {
        if let contentVC = contentViewController as? RideContentViewController {
            contentVC.centerMarkers()
        }
    }
    
    fileprivate func rideStartCallback() {
        
        if let contentVC = contentViewController as? RideContentViewController,
            let bottomVC = bottomViewController as? RideBottomViewController {
            
            contentVC.rideStartCallback()
            bottomVC.rideStartCallback()
            
            ToastUtil.displayToastOnVC(self,
                                       title: "Ride Started!",
                                       body: "Your driver has started the ride.",
                                       theme: .success,
                                       presentationStyle: .center,
                                       duration: .forever,
                                       windowLevel: UIWindowLevelNormal)
        }
    }
    
    fileprivate func driverArrivedCallback() {

        if let contentVC = contentViewController as? RideContentViewController,
            let bottomVC = bottomViewController as? RideBottomViewController {
            
            contentVC.driverArrivedCallback()
            bottomVC.driverArrivedCallback()
            
            ToastUtil.displayToastOnVC(self,
                                       title: "Driver Arrived!",
                                       body: "Your driver is waiting at pickup location.",
                                       theme: .success,
                                       presentationStyle: .center,
                                       duration: .forever,
                                       windowLevel: UIWindowLevelNormal)
        }
    }
    
    fileprivate func rideEndCallback() {

        LocationService.sharedInstance().stopFetchingDriverLocation()
        
        let rideEndStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.RideEnd, bundle: nil)

        let rideEndViewController = rideEndStoryboard.instantiateViewController(withIdentifier: "RideEndViewControllerIdentifier") as! RideEndViewController
        self.navigationController?.pushViewController(rideEndViewController, animated: true)
    }
}
