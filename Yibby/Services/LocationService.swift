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

public struct DriverLocationNotifications {
    static let newDriverLocation = TypedNotification<CLLocationCoordinate2D>(name: "com.Yibby.LocationService.NewDriverLocation")
}

// LocationService singleton
public class LocationService: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    private static let myInstance = LocationService()
    var locationManager:CLLocationManager!
    
    private var lastLocUpdateTS = 0.0
    private var curLocation: CLLocation!
    
    private let UPDATES_AGE_TIME: NSTimeInterval = 120
    private let DESIRED_HORIZONTAL_ACCURACY = 200.0
    
    private var totalLocationUpdates = 0
    private var currentLocation: CLLocation?
    
    var driverLocationFetchTimer: NSTimer?
    let DRIVER_LOC_FETCH_TIMER_INTERVAL = 5.0

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
        let timeoutDate: NSDate = NSDate(timeIntervalSinceNow: 10.0)
        while (self.currentLocation == nil &&
               timeoutDate.timeIntervalSinceNow > 0) {
                
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        }

        stopLocationUpdates()
        
        if let location = self.currentLocation {
            self.currentLocation = nil
            return location
        }
        
        return nil;
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {

        totalLocationUpdates += 1;
        
        let age: NSTimeInterval = -newLocation.timestamp.timeIntervalSinceNow
        
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
    
    private func startDriverLocationFetchTimer () {
        driverLocationFetchTimer =
            NSTimer.scheduledTimerWithTimeInterval(DRIVER_LOC_FETCH_TIMER_INTERVAL,
                                                   target: self,
                                                   selector: #selector(LocationService.fetchDriverLocation),
                                                   userInfo: nil, repeats: true)
    }
    
    @objc private func fetchDriverLocation() {
        
        // Refresh the location marker for the map
        let client: BAAClient = BAAClient.sharedClient()
        client.getDriverLocation("", completion: {(success, error) -> Void in
            
            if ((success) != nil) {
                // Post a notification to the View Controllers
                postNotification(DriverLocationNotifications.newDriverLocation,
                    value: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
            }
            else {
                DDLogVerbose("Error logging in: \(error)")
            }
        })
    }
    
    private func stopDriverLocationFetchTimer() {
        if let driverLocationFetchTimer = self.driverLocationFetchTimer {
            driverLocationFetchTimer.invalidate()
        }
    }

}