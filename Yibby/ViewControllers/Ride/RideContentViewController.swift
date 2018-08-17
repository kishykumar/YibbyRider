//
//  RideContentViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 12/15/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import GoogleMaps
import ISHPullUp
import ActionSheetPicker_3_0

class RideContentViewController: BaseYibbyViewController {

    // MARK: - Properties
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var nextButtonOutlet: YibbyButton1!
    
    weak var pullUpController: RideViewController? // weak reference to not create a strong reference cycle
    
    fileprivate var driverLocMarker: GMSMarker?
    fileprivate var curDriverMarkerStatusDescription: String = DriverStateDescription.driverEnRoute.rawValue
    
    fileprivate var pickupMarker: GMSMarker?
    fileprivate var dropoffMarker: GMSMarker?
    fileprivate var lastETAUpdateTime = Date(timeIntervalSinceReferenceDate: 0)
    
    fileprivate var bid: Bid!
    
    fileprivate var driverLocationObserver: NotificationObserver?

    fileprivate let GMS_DEFAULT_CAMERA_ZOOM: Float = 14.0
    fileprivate let DRIVER_ETA_UPDATE_THRESH: TimeInterval = (60)  // 60 seconds

    // MARK: - Actions

    @IBAction func onNextButtonClick(_ sender: YibbyButton1) {
        
        if (MockMain.isMocked) {
            if let puVC = pullUpController {
                let state: RideViewControllerState = puVC.controllerState
                switch (state) {
                case .driverEnRoute:
                    MockMain.shared.notifyDriverArrived()

                case .driverArrived:
                    MockMain.shared.notifyRideStart()
                    
                case .rideStart:
                    MockMain.shared.notifyRideEnd()
                }
            }
        }
    }
    
    // MARK: - Setup functions
    
    func initProperties() {
        self.bid = (YBClient.sharedInstance().bid)!
    }
    
    fileprivate func rideSetup() {
        
        if let ride = YBClient.sharedInstance().ride, let puVC = pullUpController {
            
            let state: RideViewControllerState = puVC.controllerState
            var driverMarkerStatus: DriverStateDescription = DriverStateDescription.driverEnRoute
            
            switch (state) {
            case .driverEnRoute:
                
                setPickupMarker(self.bid.pickupLocation!)
                driverMarkerStatus = DriverStateDescription.driverEnRoute
                break
                
            case .driverArrived:
                
                setDropoffMarker(self.bid.dropoffLocation!)
                driverMarkerStatus = DriverStateDescription.driverArrived
                break
                
            case .rideStart:
                setDropoffMarker(self.bid.dropoffLocation!)
                driverMarkerStatus = DriverStateDescription.rideStarted
                break
                
            }
            
            if let driverLoc = ride.driverLocation?.coordinate() {
                updateDriverLocation(driverLoc,
                                     status: driverMarkerStatus.rawValue)
            }
        }
    }
    
    fileprivate func setupUI () {
        
        gmsMapViewOutlet.isMyLocationEnabled = true

        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        nextButtonOutlet.layer.cornerRadius = 10.0
        
        if (MockMain.isMocked) {
            nextButtonOutlet.isHidden = false

            nextButtonOutlet.layer.borderColor = UIColor.blue.cgColor
            nextButtonOutlet.tintColor = UIColor.red
            nextButtonOutlet.setTitle("Next", for: .normal)
        } else {
            nextButtonOutlet.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initProperties()
        setupUI()
        rideSetup()
    }
    
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
        setupNotificationObservers()
    }
    
    deinit {
        DDLogVerbose("Fired deinit")
        removeNotificationObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDelegates() {
//        gmsMapViewOutlet.delegate = self
    }
    
    // MARK: GoogleMap functions
    
    fileprivate func adjustGMSCameraFocus(marker1: GMSMarker?, marker2: GMSMarker?) {
        
        guard let marker1 = marker1 else {
            
            if let marker2 = marker2 {
                let update = GMSCameraUpdate.setTarget((marker2.position),
                                                       zoom: GMS_DEFAULT_CAMERA_ZOOM)
                gmsMapViewOutlet.moveCamera(update)
            }
            return
        }
        
        guard let marker2 = marker2 else {
            
            let update = GMSCameraUpdate.setTarget((marker1.position),
                                                   zoom: GMS_DEFAULT_CAMERA_ZOOM)
            gmsMapViewOutlet.moveCamera(update)
            return
        }
        
        let heightInset = (marker2.icon?.size.height.isLess(than: (marker1.icon?.size.height)!))! ? marker1.icon?.size.height : marker2.icon?.size.height
        
        let widthInset = (marker2.icon?.size.width.isLess(than: (marker1.icon?.size.width)!))! ? marker1.icon?.size.width : marker2.icon?.size.width
        
        let screenSize: CGRect = UIScreen.main.bounds
        let pullupViewTargetHeight = RideBottomViewController.PULLUP_VIEW_PERCENT_OF_SCREEN * screenSize.height
        
        let insets = UIEdgeInsets(top: self.topLayoutGuide.length + (heightInset!) + 10.0,
                                  left: (widthInset!/2) + 10.0,
                                  bottom: pullupViewTargetHeight + 10.0,
                                  right: (widthInset!/2) + 10.0)
        
        mapFitCoordinates(coordinate1: marker1.position, coordinate2: marker2.position, insets: insets)
        
//        let zoom = gmsMapViewOutlet.camera.zoom
//            
//        if zoom < 4.0 {
//            gmsMapViewOutlet.animate(toZoom: 4.0)
//        }
    }
    
    fileprivate func mapCenterAndZoom(coordinate: CLLocationCoordinate2D, zoom: Float)
    {
        let update = GMSCameraUpdate.setTarget(coordinate,
                                               zoom: GMS_DEFAULT_CAMERA_ZOOM)
        
        gmsMapViewOutlet.animate(with: update)
    }
    
    fileprivate func mapFitCoordinates(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D, insets: UIEdgeInsets?) {
        let bounds = GMSCoordinateBounds(coordinate: (coordinate1),
                                         coordinate: (coordinate2))
        
        let update: GMSCameraUpdate?
        
        if let insets = insets {
            update = GMSCameraUpdate.fit(bounds, with: insets)
        } else {
            update = GMSCameraUpdate.fit(bounds)
        }
        
        gmsMapViewOutlet.animate(with: update!)
    }
    
    // MARK: Notifications
    
    fileprivate func setupNotificationObservers() {
        
        driverLocationObserver = NotificationObserver(notification: DriverLocationNotifications.newDriverLocation) { [unowned self] loc in
            
            self.updateDriverLocation(loc, status: self.curDriverMarkerStatusDescription)
        }
    }
    
    fileprivate func removeNotificationObservers() {
        driverLocationObserver?.removeObserver()
    }
    
    // MARK: - Ride Callbacks
    
    // This callback is called from 2 places:
    // 1. Ride start notification
    // 2. Sync codepath
    public func rideStartCallback() {
        
        // When the ride starts, we want to create the new dropoff marker if it's not there
        if (self.dropoffMarker == nil) {
            setDropoffMarker(self.bid.dropoffLocation!)
        }
        
        // Update the driver location marker.
        // It's unnecessary here because the driver location is being updated in the background by the location notification observer.
        // But, we have the folllowing code just to make the update right away!
        if let latLng = driverLocMarker?.position {
            updateDriverLocation(latLng, status: DriverStateDescription.rideStarted.rawValue)
        }
    }
    
    public func driverArrivedCallback() {

        // When the driver arrives, we want to clear the pickup marker and add the dropoff marker.
        clearPickupMarker()
        
        setDropoffMarker(self.bid.dropoffLocation!)
        
        // Update the driver location marker
        // It's unnecessary here because the driver location is being updated in the background by the location notification observer.
        // But, we have the folllowing code just to make the update right away!
        if let latLng = driverLocMarker?.position {
            updateDriverLocation(latLng, status: DriverStateDescription.driverArrived.rawValue)
        }
    }
    
    public func centerMarkers() {
        adjustGMSCameraFocus(marker1: pickupMarker ?? dropoffMarker, marker2: driverLocMarker)
    }
    
    // MARK: - Helpers
    
    fileprivate func clearPickupMarker() {
        pickupMarker?.map = nil
        pickupMarker = nil
    }
    
    fileprivate func setPickupMarker (_ location: YBLocation) {
        
        pickupMarker?.map = nil
        
        let pumarker = GMSMarker(position: location.coordinate())
        pumarker.map = gmsMapViewOutlet
        pumarker.icon = YibbyMapMarker.annotationImageWithMarker(pumarker,
                                                                  title: location.name!,
                                                                  type: .pickup, isShowArrow: false)
        
        pickupMarker = pumarker
    }
    
    fileprivate func setDropoffMarker (_ location: YBLocation) {
        
        dropoffMarker?.map = nil
        
        let domarker = GMSMarker(position: location.coordinate())
        domarker.map = gmsMapViewOutlet
        domarker.icon = YibbyMapMarker.annotationImageWithMarker(domarker,
                                                                 title: location.name!,
                                                                 type: .dropoff, isShowArrow: false)
        
        dropoffMarker = domarker
    }
    
    fileprivate func updateDriverLocation (_ loc: CLLocationCoordinate2D, status: String) {
        
        if (self.viewIfLoaded == nil) {
            return;
        }
        
        // If marker hasn't been created yet, create it.
        //     OR
        // Marker already existed.
        // If the marker states are different, create a new marker.
        
        if (driverLocMarker == nil || (self.curDriverMarkerStatusDescription != status)) {
            driverLocMarker?.map = nil
            
            let dlmarker = GMSMarker(position: loc)
            dlmarker.map = gmsMapViewOutlet
            
            dlmarker.icon = YibbyMapMarker.driverCarImageWithMarker(dlmarker,
                                                                    title: status,
                                                                    type: .driver)
            
            driverLocMarker = dlmarker
            
        } else {
            
            // If it's the same status and different location, apply the animation update
            if let driverLocMarker = self.driverLocMarker { // marker should be initialized here.
                
                if ((driverLocMarker.position.latitude != loc.latitude) ||
                    (driverLocMarker.position.longitude != loc.longitude)) {
                    
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(LocationService.DRIVER_LOC_FETCH_TIMER_INTERVAL)
                    driverLocMarker.position = loc
                    CATransaction.commit()
                    
                }
            }
        }

        self.curDriverMarkerStatusDescription = status
        
        // update ETA every DRIVER_ETA_UPDATE_THRESH minutes
        if (TimeUtil.diffFromCurTime(lastETAUpdateTime) > DRIVER_ETA_UPDATE_THRESH) {
            
            let status = YBClient.sharedInstance().status
            var toLoc = self.bid.pickupLocation!.coordinate()
            if (status != .driverEnRoute) {
                toLoc = self.bid.dropoffLocation!.coordinate()
            }

            DirectionsService.shared.getEta(from: loc, to: toLoc,
                                            completionBlock: { (etaSeconds, distanceMeters) -> Void in
                                              
                // TODO: Show the ETA on the UI
                
                
                self.lastETAUpdateTime = Date()
            })
            
            // TODO: adjust the map only if the distance between the driver and the rider is too less.
            // Today, we adjust it every one minute
            adjustGMSCameraFocus(marker1: pickupMarker ?? dropoffMarker, marker2: driverLocMarker)
        }
    }
}
