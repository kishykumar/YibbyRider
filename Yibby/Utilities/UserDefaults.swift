//
//  UserDefaults.swift
//  Yibby
//
//  Created by Prabhdeep Singh on 8/28/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import Foundation

open class Defaults{
    
    static let defaults = UserDefaults.standard
    static var pickDictionary = [String:Any]()
    static var dropDictionary = [String:Any]()
    
    static func setPickUpLocation(pickUpLat: Double, pickUpLong: Double, pickUpName: String){
        defaults.set(pickUpName, forKey: "pickUpName")
        defaults.set(pickUpLat, forKey: "pickUpLat")
        defaults.set(pickUpLong, forKey: "pickUpLong")
    }
    
    static func getPickUpLocation() -> [String:Any] {
        let name = defaults.string(forKey: "pickUpName")
        let lat =  defaults.double(forKey: "pickUpLat")
        let long = defaults.double(forKey: "pickUpLong")
        
        self.pickDictionary["name"] = name
        self.pickDictionary["latitude"] = lat
        self.pickDictionary["longitude"] = long
        
        return self.pickDictionary

    }
    
    static func setDropLocation(dropLat: Double, dropLong: Double, dropName: String){
        defaults.set(dropName, forKey: "dropName")
        defaults.set(dropLat, forKey: "dropLat")
        defaults.set(dropLong, forKey: "dropLong")
    }
    
    static func getDropLocation() -> [String:Any] {
        let name = defaults.string(forKey: "dropName")
        let lat =  defaults.double(forKey: "dropLat")
        let long = defaults.double(forKey: "dropLong")
        
        self.dropDictionary["name"] = name
        self.dropDictionary["latitude"] = lat
        self.dropDictionary["longitude"] = long
        
        return self.dropDictionary
        
    }

}
