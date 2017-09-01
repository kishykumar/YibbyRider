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

class RideContentViewController: BaseYibbyViewController {

    // MARK: - Properties
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var cancelButtonOutlet: YibbyButton1!
    
    weak var pullUpController: RideViewController!
    
    var driverLocLatLng: CLLocationCoordinate2D?
    var driverLocMarker: GMSMarker?
    
    var pickupMarker: GMSMarker?
    var dropoffMarker: GMSMarker?
    
    var bid: Bid!
    
    fileprivate var driverLocationObserver: NotificationObserver?

    let GMS_DEFAULT_CAMERA_ZOOM: Float = 14.0
    
    // MARK: - Actions
    
    @IBAction func onBackButtonImageViewClick(_ sender: Any) {
        _ = pullUpController.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup functions
    
    func initProperties() {
        self.bid = (YBClient.sharedInstance().bid)!
    }
    
    func rideBeginSetup() {
        LocationService.sharedInstance().startFetchingDriverLocation()
        
        // Add marker to the pickup location
        setPickupDetails(bid.pickupLocation!)
        
        if let ride = YBClient.sharedInstance().ride {
            
            let state: RideViewControllerState = pullUpController.controllerState
            var markerStatus: DriverStateDescription = DriverStateDescription.driverEnRoute
            
            switch (state) {
            case .driverEnRoute:
                markerStatus = DriverStateDescription.driverEnRoute
                break
                
            case .driverArrived:
                markerStatus = DriverStateDescription.driverArrived
                break
                
            case .rideStart:
                markerStatus = DriverStateDescription.rideStarted
                break
                
            case .rideEnd:
                markerStatus = DriverStateDescription.rideEnded
                break
                
            default:
                markerStatus = DriverStateDescription.driverEnRoute
                break
            }
            
            if let driverLoc = ride.driverLocation?.coordinate() {
                setDriverLocation(driverLoc,
                                  status: markerStatus.rawValue)
            }
        }
        
        adjustGMSCameraFocus(marker1: pickupMarker, marker2: driverLocMarker)
    }
    
    func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        cancelButtonOutlet.layer.cornerRadius = 10.0
        cancelButtonOutlet.layer.borderWidth = 2.0
        cancelButtonOutlet.layer.borderColor = UIColor.red.cgColor
        cancelButtonOutlet.tintColor = UIColor.red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initProperties()
        setupUI()
        rideBeginSetup()
        setupNotificationObservers()
    }
    
    deinit {
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
            DDLogVerbose("NotificationObserver newDriverLoc: \(loc)")
            
            self.updateDriverLocation(loc)
        }
    }
    
    fileprivate func removeNotificationObservers() {
        driverLocationObserver?.removeObserver()
    }
    
    // MARK: - Helpers
    
    func centerMarkers() {
        adjustGMSCameraFocus(marker1: pickupMarker ?? dropoffMarker, marker2: driverLocMarker)
    }
    
    func rideStartCallback() {
        let latLng = driverLocMarker?.position
        setDriverLocation(latLng!, status: DriverStateDescription.rideStarted.rawValue)
    }
    
    func driverArrivedCallback() {
        let latLng = driverLocMarker?.position
        
        clearPickupDetails()
        
        setDriverLocation(latLng!, status: DriverStateDescription.driverArrived.rawValue)
        setDropoffDetails(bid.dropoffLocation!)
        
        adjustGMSCameraFocus(marker1: dropoffMarker, marker2: driverLocMarker)
    }
    
    func clearPickupDetails() {
        pickupMarker?.map = nil
        pickupMarker = nil
    }
    
    func setPickupDetails (_ location: YBLocation) {
        
        pickupMarker?.map = nil
        
        let pumarker = GMSMarker(position: location.coordinate())
        pumarker.map = gmsMapViewOutlet
        pumarker.icon = YibbyMapMarker.annotationImageWithMarker(pumarker,
                                                                  title: location.name!,
                                                                  type: .pickup)
        
        pickupMarker = pumarker
    }
    
    func setDropoffDetails (_ location: YBLocation) {
        
        dropoffMarker?.map = nil
        
        let domarker = GMSMarker(position: location.coordinate())
        domarker.map = gmsMapViewOutlet
        domarker.icon = YibbyMapMarker.annotationImageWithMarker(domarker,
                                                                 title: location.name!,
                                                                 type: .dropoff)
        
        dropoffMarker = domarker
    }
    
    func updateDriverLocation (_ loc: CLLocationCoordinate2D) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(LocationService.DRIVER_LOC_FETCH_TIMER_INTERVAL)
        driverLocMarker?.position = loc
        CATransaction.commit()
        
        // if the distance between the driver and the rider is too less, adjust the map
        
    }
    
    func setDriverLocation(_ loc: CLLocationCoordinate2D, status: String) {
        
        // TODO: REMOVE THIS ====================
//        let lat: CLLocationDegrees = 37.527466
//        let long: CLLocationDegrees = -122.276797
//        let loc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
        //  ==================== ====================
        
        driverLocMarker?.map = nil
        self.driverLocLatLng = loc
        
        let dlmarker = GMSMarker(position: loc)
        dlmarker.map = gmsMapViewOutlet

        dlmarker.icon = YibbyMapMarker.driverCarImageWithMarker(dlmarker,
                                                                 title: status,
                                                                 type: .driver)
        
        driverLocMarker = dlmarker
    }
}
