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
    case rideEnd
}

class RideViewController: ISHPullUpViewController {
    
    fileprivate var rideStartObserver: NotificationObserver?
    fileprivate var rideEndObserver: NotificationObserver?
    fileprivate var driverArrivedObserver: NotificationObserver?
    
    // MARK: - Properties
    public var controllerState: RideViewControllerState!
    
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
        controllerState = .driverEnRoute
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        setupMenuButton()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Notifications
    
    fileprivate func setupNotificationObservers() {

        rideStartObserver = NotificationObserver(notification: RideNotifications.rideStart) { [unowned self] comment in
            DDLogVerbose("NotificationObserver rideStart: \(comment)")
            
            self.updateControllerState(RideViewControllerState.rideStart)
        }
        
        rideEndObserver = NotificationObserver(notification: RideNotifications.rideEnd) { [unowned self] comment in
            DDLogVerbose("NotificationObserver rideEnd: \(comment)")
            
            self.updateControllerState(RideViewControllerState.rideEnd)
        }
        
        driverArrivedObserver = NotificationObserver(notification: RideNotifications.driverArrived) { [unowned self] comment in
            DDLogVerbose("NotificationObserver driverArrived: \(comment)")
            
            self.updateControllerState(RideViewControllerState.driverArrived)
        }
    }
    
    fileprivate func removeNotificationObservers() {
        rideStartObserver?.removeObserver()
        rideEndObserver?.removeObserver()
    }
    
    // MARK: - Helpers

    func updateControllerState(_ state: RideViewControllerState) {
        
        switch (state) {
        case .driverArrived:
            driverArrivedCallback()
            
        case .rideEnd:
            rideEndCallback()
            
        case .rideStart:
            rideStartCallback()
            
        default:
            assert(false)
        }
    }
    
    func rideStartCallback() {
        controllerState = .rideStart
        
        if let contentVC = contentViewController as? RideContentViewController,
            let bottomVC = bottomViewController as? RideBottomViewController {
            
            contentVC.rideStartCallback()
            bottomVC.rideStartCallback()
            
        }
    }
    
    func driverArrivedCallback() {
        controllerState = .driverArrived

        if let contentVC = contentViewController as? RideContentViewController,
            let bottomVC = bottomViewController as? RideBottomViewController {
            
            contentVC.driverArrivedCallback()
            bottomVC.driverArrivedCallback()
            
        }
    }
    
    func rideEndCallback() {
        controllerState = .rideEnd

        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)

        let rideEndViewController = rideStoryboard.instantiateViewController(withIdentifier: "RideEndViewControllerIdentifier") as! RideEndViewController
        self.navigationController?.pushViewController(rideEndViewController, animated: true)
    }
}
