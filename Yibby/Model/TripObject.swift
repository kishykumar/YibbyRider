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
        
        print(responseArr)
        
        let dataArray = NSMutableArray()
        
        for index in 0..<responseArr.count{
            let currentDict = responseArr[index] as! NSDictionary
            
            let classObject = TripObject()
            
            classObject.riderBidPrice = String(describing: currentDict["riderBidPrice"] as! NSObject)
            print(classObject.riderBidPrice)
            classObject.driverBidPrice = String(describing: currentDict["driverBidPrice"] as! NSObject)
            
            classObject.fare = String(describing: currentDict["fare"] as! NSObject)
            
            classObject.id = currentDict["id"] as! String
            classObject.bidId = currentDict["bidId"] as! String
            classObject.dateTime = currentDict["datetime"] as! String
            classObject.rideTime = String(describing: currentDict["rideTime"] as! NSObject)
            
            
            if let pickupDict = currentDict["pickupLocation"] as? NSDictionary {
                classObject.pickup_latitude = String(describing: pickupDict["latitude"] as! NSObject)
                
                 classObject.pickup_longitude = String(describing: pickupDict["longitude"] as! NSObject)
                
                 classObject.pickup_name = pickupDict["name"] as! String
                
            }
            
            if let dropLocationDict = currentDict["dropoffLocation"] as? NSDictionary {
                
                classObject.drop_latitude = String(describing: dropLocationDict["latitude"] as! NSObject)
                
                classObject.drop_longitude = String(describing:dropLocationDict["longitude"] as! NSObject)
                classObject.drop_name = dropLocationDict["name"] as! String
                
                
            }
            
            if let driverDict = currentDict["driver"] as? NSDictionary {
                
classObject.driver_id = driverDict["id"] as! String
classObject.driver_firstName = driverDict["firstName"] as! String
    classObject.driver_photoURL = driverDict["photoUrl"] as! String
    classObject.driver_rating = driverDict["rating"] as! String
classObject.driver_mobile = driverDict["mobile"] as! String
                
        if let locationDict = currentDict["location"] as? NSDictionary {
            
            classObject.driver_latitude = String(describing:locationDict["latitude"] as! NSObject)
            
            classObject.driver_longitude = String(describing:locationDict["longitude"] as! NSObject)
            
                    
                }
                
            }
            
            if let vehicleDict = currentDict["vehicle"] as? NSDictionary {
                classObject.vehicle_id = vehicleDict["id"] as! String
                 classObject.vehicle_exteriorColor = vehicleDict["exteriorColor"] as! String
                 classObject.vehicle_licensePlate = vehicleDict["licensePlate"] as! String
                 classObject.vehicle_make = vehicleDict["make"] as! String
                 classObject.vehicle_model = vehicleDict["model"] as! String
                 classObject.vehicle_capacity = String(describing: vehicleDict["capacity"] as! NSObject)
                
                
                
            }
            
            dataArray.add(classObject)
            
        }
        return dataArray
        
    }
}
