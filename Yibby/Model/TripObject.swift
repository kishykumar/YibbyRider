//
//  TripObject.swift
//  Yibby
//
//  Created by Rubi Kumari on 28/03/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class TripObject
{
    var riderBidPrice = ""
    var driverBidPrice = ""
    var fare = ""
    var id = ""
    var bidId = ""
    var dateTime = ""
    var rideTime = ""
    
    var pickup_latitude = ""
    var pickup_longitude = ""
    var pickup_name = ""
    
    var drop_latitude = ""
    var drop_longitude = ""
    var drop_name = ""

    var driver_id = ""
    var driver_firstName = ""
    var driver_latitude = ""
    var driver_longitude = ""
    var driver_photoURL = ""
    var driver_rating = ""
    var driver_mobile = ""

    var vehicle_id = ""
    var vehicle_exteriorColor = ""
    var vehicle_licensePlate = ""
    var vehicle_make = ""
    var vehicle_model = ""
    var vehicle_capacity = ""
    
    
    func saveTripDetails(responseArr: NSArray) -> NSMutableArray{
        
        
        let dataArray = NSMutableArray()
        
        for index in 0..<responseArr.count{
            let currentDict = responseArr[index] as! NSDictionary
            
            let classObject = TripObject()
            
            classObject.riderBidPrice = currentDict["riderBidPrice"] as! String
            classObject.driverBidPrice = currentDict["driverBidPrice"] as! String
            classObject.fare = currentDict["fare"] as! String
            classObject.id = currentDict["id"] as! String
            classObject.bidId = currentDict["bidId"] as! String
            classObject.dateTime = currentDict["datetime"] as! String
            classObject.rideTime = currentDict["rideTime"] as! String
            
            
            if let pickupDict = currentDict["pickupLocation"] as? NSDictionary {
                classObject.pickup_latitude = pickupDict["latitude"] as! String
                 classObject.pickup_longitude = pickupDict["longitude"] as! String
                 classObject.pickup_name = pickupDict["name"] as! String
                
            }
            
            if let dropLocationDict = currentDict["dropoffLocation"] as? NSDictionary {
                
                classObject.drop_latitude = dropLocationDict["latitude"] as! String
                classObject.drop_longitude = dropLocationDict["longitude"] as! String
                classObject.drop_name = dropLocationDict["name"] as! String
                
                
            }
            
            if let driverDict = currentDict["driver"] as? NSDictionary {
                
classObject.driver_id = driverDict["id"] as! String
classObject.driver_firstName = driverDict["firstName"] as! String
    classObject.driver_photoURL = driverDict["photoUrl"] as! String
    classObject.driver_rating = driverDict["rating"] as! String
classObject.driver_mobile = driverDict["mobile"] as! String
                
        if let locationDict = currentDict["location"] as? NSDictionary {
            
            classObject.driver_latitude = locationDict["latitude"] as! String
            classObject.driver_longitude = locationDict["longitude"] as! String
                    
                }
                
            }
            
            if let vehicleDict = currentDict["vehicle"] as? NSDictionary {
                classObject.vehicle_id = vehicleDict["id"] as! String
                 classObject.vehicle_exteriorColor = vehicleDict["exteriorColor"] as! String
                 classObject.vehicle_licensePlate = vehicleDict["licensePlate"] as! String
                 classObject.vehicle_make = vehicleDict["make"] as! String
                 classObject.vehicle_model = vehicleDict["model"] as! String
                 classObject.vehicle_capacity = vehicleDict["capacity"] as! String
                
                
            }
            
            dataArray.add(classObject)
            
        }
        return dataArray
        
    }
}
