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

class DriverEnRouteViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var driverLocMapViewOutlet: GMSMapView!
    
    @IBOutlet weak var fareValueOutlet: UILabel!
    
    @IBOutlet weak var paymentValueOutlet: UILabel!
    
    @IBOutlet weak var numPeopleValueOutlet: UILabel!
    
    @IBOutlet weak var driverRatingValueOutlet: UILabel!
    
    @IBOutlet weak var driverCarValueOutlet: UILabel!
    
    @IBOutlet weak var plateNumValueOutlet: UILabel!
    
    var driverLocationFetchTimer: NSTimer?
    let DRIVER_LOC_FETCH_TIMER_INTERVAL = 3.0

    var driverLocLatLng: CLLocationCoordinate2D?
    var driverLocMarker: GMSMarker?
    
    let DRIVER_EN_ROUTE_MARKER_TITLE = "Driver En Route"
    
    // MARK: Setup functions
    
    func setupUI () {
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        startDriverLocationFetchTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Location Poll Timer Functions
    
    func startDriverLocationFetchTimer () {
        driverLocationFetchTimer =
            NSTimer.scheduledTimerWithTimeInterval(DRIVER_LOC_FETCH_TIMER_INTERVAL,
                                                   target: self,
                                                   selector: #selector(DriverEnRouteViewController.fetchDriverLocation),
                                                   userInfo: nil, repeats: true)
    }
    
    func fetchDriverLocation() {
        
        // Refresh the location marker for the map
        let client: BAAClient = BAAClient.sharedClient()
        client.dummyCall( {(success, error) -> Void in
            
            if ((success) != nil) {
                // Update the UI from here.
//                setDriverLocation()
            }
            else {
                DDLogVerbose("Error logging in: \(error)")
            }
        })
    }
    
    func stopDriverLocationFetchTimer() {
        if let driverLocationFetchTimer = self.driverLocationFetchTimer {
            driverLocationFetchTimer.invalidate()
        }
    }

    // MARK: GoogleMap functions
    
    func adjustGMSCameraFocus () {
        let update = GMSCameraUpdate.setTarget((driverLocMarker?.position)!)
        driverLocMapViewOutlet.moveCamera(update)
    }
    
    func setDriverLocation (loc: CLLocationCoordinate2D) {
        
        driverLocMarker?.map = nil
        
        self.driverLocLatLng = loc
        
        let dlmarker = GMSMarker(position: loc)
        dlmarker.title = DRIVER_EN_ROUTE_MARKER_TITLE
        dlmarker.map = driverLocMapViewOutlet
        driverLocMarker = dlmarker
        driverLocMapViewOutlet.selectedMarker = driverLocMarker
        
        adjustGMSCameraFocus()
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
