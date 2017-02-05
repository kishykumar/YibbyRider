//
//  LocationService.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/15/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import BaasBoxSDK
import CocoaLumberjack
import SwiftyJSON

public struct DriverLocationNotifications {
    static let newDriverLocation = TypedNotification<CLLocationCoordinate2D>(name: "com.Yibby.LocationService.NewDriverLocation")
}

// LocationService singleton
open class LocationService: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    fileprivate static let myInstance = LocationService()
    var locationManager:CLLocationManager!
    
    fileprivate var lastLocUpdateTS = 0.0
    fileprivate var curLocation: CLLocation!
    
    fileprivate let UPDATES_AGE_TIME: TimeInterval = 120
    fileprivate let DESIRED_HORIZONTAL_ACCURACY = 200.0
    
    fileprivate var totalLocationUpdates = 0
    fileprivate var currentLocation: CLLocation?
    
    var driverLocationFetchTimer: Timer?
    static let DRIVER_LOC_FETCH_TIMER_INTERVAL = 5.0

    let LATITUDE_JSON_FIELD_NAME = "latitude"
    let LONGITUDE_JSON_FIELD_NAME = "longitude"
    
    override init() {
        
    }
    
    static func sharedInstance () -> LocationService {
        return myInstance
    }
    
    // MARK: - Setup functions
    
    func setupLocationManager () {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: Rider Location Fetch
    
    func startLocationUpdates () {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates () {
        locationManager.stopUpdatingLocation()
    }
    
    func provideCurrentLocation () -> CLLocation? {
        startLocationUpdates()
        
        // wait for an accurate location update
        let timeoutDate: Date = Date(timeIntervalSinceNow: 10.0)
        while (self.currentLocation == nil &&
               timeoutDate.timeIntervalSinceNow > 0) {
                
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.1, false)
        }

        stopLocationUpdates()
        
        if let location = self.currentLocation {
            self.currentLocation = nil
            return location
        }
        
        return nil;
    }
    
    open func locationManager(_ manager: CLLocationManager,
                                  didUpdateLocations locations: [CLLocation]) {

        guard let newLocation = locations.last else {
            return;
        }
        
        totalLocationUpdates += 1;
        
        let age: TimeInterval = -newLocation.timestamp.timeIntervalSinceNow
        
        if (age > UPDATES_AGE_TIME) {
            return
        }
        
        // ignore old (cached) and less accurate updates
        if (newLocation.horizontalAccuracy < 0 ||
            (newLocation.horizontalAccuracy > DESIRED_HORIZONTAL_ACCURACY && totalLocationUpdates <= 10)) {
            
            return
        }
        
        if let userLocation:CLLocation = newLocation {
            self.currentLocation = userLocation
            totalLocationUpdates = 0
        }
    }
    
    // MARK: Driver Location Fetch
    
    func startFetchingDriverLocation() {
        startDriverLocationFetchTimer()
    }
    
    func stopFetchingDriverLocation() {
        stopDriverLocationFetchTimer()
    }
    
    fileprivate func startDriverLocationFetchTimer () {
        driverLocationFetchTimer =
            Timer.scheduledTimer(timeInterval: LocationService.DRIVER_LOC_FETCH_TIMER_INTERVAL,
                                                   target: self,
                                                   selector: #selector(LocationService.fetchDriverLocation),
                                                   userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func fetchDriverLocation() {
        
        if let bid = (YBClient.sharedInstance().getBid()) {

            // Refresh the location marker for the map
            let client: BAAClient = BAAClient.shared()
            client.getDriverLocation(bid.id, completion: {(success, error) -> Void in
                
                if ((success) != nil) {
                    
                    if let resultDict = success as? NSDictionary,
                        let latitude = resultDict[self.LATITUDE_JSON_FIELD_NAME] as? Double,
                        let longitude = resultDict[self.LONGITUDE_JSON_FIELD_NAME] as? Double {
                        
                        // Post a notification to the View Controllers
                        postNotification(DriverLocationNotifications.newDriverLocation,
                                         value: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                }
                else {
                    DDLogError("Error in fetching driver location: \(error)")
                }
            })
        }
    }
    
    fileprivate func stopDriverLocationFetchTimer() {
        if let driverLocationFetchTimer = self.driverLocationFetchTimer {
            driverLocationFetchTimer.invalidate()
        }
    }

}
