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

class DriverEnRouteViewController: BaseYibbyViewController {

    // MARK: - Properties
    
    @IBOutlet weak var driverLocMapViewOutlet: GMSMapView!
    @IBOutlet weak var fareValueOutlet: UILabel!
    @IBOutlet weak var paymentValueOutlet: UILabel!
    @IBOutlet weak var numPeopleValueOutlet: UILabel!
    @IBOutlet weak var driverRatingValueOutlet: UILabel!
    @IBOutlet weak var driverCarValueOutlet: UILabel!
    @IBOutlet weak var plateNumValueOutlet: UILabel!
    
    var driverLocLatLng: CLLocationCoordinate2D?
    var driverLocMarker: GMSMarker?
    
    var bid: Bid!

    fileprivate var driverLocationObserver: NotificationObserver?

    let DRIVER_EN_ROUTE_MARKER_TITLE = "Driver En Route"
    
    // MARK: - Setup functions
    
    func initProperties() {
        self.bid = (BidState.sharedInstance().getOngoingBid())!
    }
    
    func rideBeginSetup() {
        LocationService.sharedInstance().startFetchingDriverLocation()
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
    
    // MARK: GoogleMap functions
    
    func adjustGMSCameraFocus () {
        let update = GMSCameraUpdate.setTarget((driverLocMarker?.position)!)
        driverLocMapViewOutlet.moveCamera(update)
    }
    
    func setDriverLocation (_ loc: CLLocationCoordinate2D) {
        
        driverLocMarker?.map = nil
        
        self.driverLocLatLng = loc
        
        let dlmarker = GMSMarker(position: loc)
        dlmarker?.title = DRIVER_EN_ROUTE_MARKER_TITLE
        dlmarker?.map = driverLocMapViewOutlet
        driverLocMarker = dlmarker
        driverLocMapViewOutlet.selectedMarker = driverLocMarker
        
        adjustGMSCameraFocus()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
