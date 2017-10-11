//
//  DriverEnRouteViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/26/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import GoogleMaps
import ISHPullUp

public struct RideNotifications {
    static let rideStart = TypedNotification<String>(name: "com.Yibby.Ride.RideStart")
    static let driverArrived = TypedNotification<String>(name: "com.Yibby.Ride.DriverArrived")
    static let rideEnd = TypedNotification<String>(name: "com.Yibby.Ride.RideEnd")
}

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
        
        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
        
        let contentVC = rideStoryboard.instantiateViewController(withIdentifier: "RideContentViewControllerIdentifier") as! RideContentViewController
        
        let bottomVC = rideStoryboard.instantiateViewController(withIdentifier: "RideBottomViewControllerIdentifier") as! RideBottomViewController
        
        contentViewController = contentVC
        bottomViewController = bottomVC
        dimmingColor = nil
        
        contentVC.pullUpController = self
        bottomVC.pullUpController = self
        
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
        
//        contentDelegate = contentVC
        
        LocationService.sharedInstance().startFetchingDriverLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        setupMenuButton()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    // MARK: Notifications
    
    fileprivate func setupNotificationObservers() {

        rideStartObserver = NotificationObserver(notification: RideNotifications.rideStart) { [unowned self] comment in
            DDLogVerbose("NotificationObserver rideStart: \(comment)")
            
            self.updateControllerState(state: .rideStart)
        }
        
        rideEndObserver = NotificationObserver(notification: RideNotifications.rideEnd) { [unowned self] comment in
            DDLogVerbose("NotificationObserver rideEnd: \(comment)")
            
            self.rideEndCallback()
        }
        
        driverArrivedObserver = NotificationObserver(notification: RideNotifications.driverArrived) { [unowned self] comment in
            DDLogVerbose("NotificationObserver driverArrived: \(comment)")
            
            self.updateControllerState(state: .driverArrived)
        }
    }
    
    fileprivate func removeNotificationObservers() {
        rideStartObserver?.removeObserver()
        rideEndObserver?.removeObserver()
    }
    
    // MARK: - Helpers

    func updateControllerState(state: RideViewControllerState) {
        
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
            
        }
    }
    
    fileprivate func driverArrivedCallback() {

        if let contentVC = contentViewController as? RideContentViewController,
            let bottomVC = bottomViewController as? RideBottomViewController {
            
            contentVC.driverArrivedCallback()
            bottomVC.driverArrivedCallback()
            
        }
    }
    
    fileprivate func rideEndCallback() {

        LocationService.sharedInstance().stopFetchingDriverLocation()
        
        let rideEndStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.RideEnd, bundle: nil)

        let rideEndViewController = rideEndStoryboard.instantiateViewController(withIdentifier: "RideEndViewControllerIdentifier") as! RideEndViewController
        self.navigationController?.pushViewController(rideEndViewController, animated: true)
    }
}
