//
//  DriverEnRouteContentViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 12/15/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import GoogleMaps
import ISHPullUp

class DriverEnRouteContentViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    
    weak var pullUpController: ISHPullUpViewController!
    
    var driverLocLatLng: CLLocationCoordinate2D?
    var driverLocMarker: GMSMarker?
    
    var pickupMarker: GMSMarker?
    
    var bid: Bid!
    
    fileprivate var driverLocationObserver: NotificationObserver?
    
    let DRIVER_EN_ROUTE_MARKER_TITLE = "Driver En Route"
    let GMS_DEFAULT_CAMERA_ZOOM: Float = 14.0
    
    // MARK: - Actions
    
    @IBAction func onBackButtonImageViewClick(_ sender: Any) {
        _ = pullUpController.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCenterMarkersButtonClick(_ sender: Any) {
        adjustGMSCameraFocus()
    }
    
    // MARK: - Setup functions
    
    func initProperties() {
        self.bid = (YBClient.sharedInstance().getBid())!
    }
    
    func rideBeginSetup() {
        LocationService.sharedInstance().startFetchingDriverLocation()
        
        // Add marker to the pickup location
        setPickupDetails(bid.pickupLocation!)
        
        setDriverInitialLocation()
        adjustGMSCameraFocus()
    }
    
    func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
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
    
    fileprivate func adjustGMSCameraFocus() {
        
        guard let pickupMarker = pickupMarker else {
            
            if let driverLocMarker = driverLocMarker {
                let update = GMSCameraUpdate.setTarget((driverLocMarker.position),
                                                       zoom: GMS_DEFAULT_CAMERA_ZOOM)
                gmsMapViewOutlet.moveCamera(update)
            }
            return
        }
        
        guard let driverLocMarker = driverLocMarker else {
            
            let update = GMSCameraUpdate.setTarget((pickupMarker.position),
                                                   zoom: GMS_DEFAULT_CAMERA_ZOOM)
            gmsMapViewOutlet.moveCamera(update)
            return
        }
        
        let widthInset = (driverLocMarker.icon.size.width < pickupMarker.icon.size.width) ? driverLocMarker.icon.size.width : pickupMarker.icon.size.width
        
        let heightInset = (driverLocMarker.icon.size.height < pickupMarker.icon.size.height) ? driverLocMarker.icon.size.height : pickupMarker.icon.size.height
        
        let screenSize: CGRect = UIScreen.main.bounds
        let pullupViewTargetHeight = DriverEnRouteBottomViewController.PULLUP_VIEW_PERCENT_OF_SCREEN * screenSize.height
        
        let insets = UIEdgeInsets(top: self.topLayoutGuide.length + heightInset/2,
                                  left: (widthInset/2) + 10.0,
                                  bottom: pullupViewTargetHeight + heightInset/2,
                                  right: (widthInset/2) + 10.0)
        
        mapFitCoordinates(coordinate1: pickupMarker.position, coordinate2: driverLocMarker.position, insets: insets)
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
    
    func setDriverLocation (_ loc: CLLocationCoordinate2D) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(LocationService.DRIVER_LOC_FETCH_TIMER_INTERVAL)
        driverLocMarker?.position = loc
        CATransaction.commit()
    
        // if the distance between the driver and the rider is too less, adjust the map
        
    }
    
    func setDriverInitialLocation() {
        
        // TODO: REMOVE THIS ====================
        let lat: CLLocationDegrees = 37.531631
        let long: CLLocationDegrees = -122.263606
        let loc: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
        //  ==================== ====================
        
        driverLocMarker?.map = nil
        self.driverLocLatLng = loc
        
        let dlmarker = GMSMarker(position: loc)
        dlmarker?.title = DRIVER_EN_ROUTE_MARKER_TITLE
        dlmarker?.map = gmsMapViewOutlet
        
        driverLocMarker = dlmarker
        
        driverLocMarker?.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        
        let markerImage = UIImage(named: InterfaceImage.DriverCar.rawValue)!
        let imageData = UIImagePNGRepresentation(markerImage)!
        driverLocMarker?.icon = UIImage(data: imageData, scale: 2.5)
    }
    
    // MARK: Notifications
    
    fileprivate func setupNotificationObservers() {
        
        driverLocationObserver = NotificationObserver(notification: DriverLocationNotifications.newDriverLocation) { [unowned self] loc in
            DDLogVerbose("NotificationObserver newDriverLoc: \(loc)")
            
            self.setDriverLocation(loc)
        }
    }
    
    fileprivate func removeNotificationObservers() {
        driverLocationObserver?.removeObserver()
    }
    
    // MARK: - Helper functions
    
    func setPickupDetails (_ location: YBLocation) {
        
        pickupMarker?.map = nil
        
        let pumarker = GMSMarker(position: location.coordinate())
        pumarker?.map = gmsMapViewOutlet
        pumarker?.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        pumarker?.icon = YibbyMapMarker.annotationImageWithMarker(pumarker!,
                                                                  title: location.name!,
                                                                  andPinIcon: UIImage(named: "defaultMarker")!,
                                                                  pickup: true)
        
        pickupMarker = pumarker
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

//extension DriverEnRouteContentViewController: GMSMapViewDelegate {
//
//    public func mapView(_ mapView: GMSMapView!, didChange position: GMSCameraPosition!) {
//        
//
//    }
//}
