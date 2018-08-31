//
//  UserDefaults.swift
//  Yibby
//
//  Created by Prabhdeep Singh on 8/28/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import Foundation
import ObjectMapper

open class Defaults{
    
    static let defaults = UserDefaults.standard
    
    static func setYibbyPickLocation(pickLocation: YBLocation) {
        let jsonString = pickLocation.toJSONString()
        defaults.set(jsonString, forKey: "yibbyPickLocation")
    }
    
    static func getYibbyPickLocation() -> YBLocation {
        if let pick = defaults.string(forKey: "yibbyPickLocation"){
            return YBLocation(JSONString: pick)!
        } else {
            return YBLocation(lat: 37.422094, long: -122.084068, name: "Googleplex, Amphitheatre Parkway, Mountain View, CA")
        }
        
    }
    
    static func setYibbyDropLocation(dropLocation: YBLocation) {
        let jsonString = dropLocation.toJSONString()
        defaults.set(jsonString, forKey: "yibbyDropLocation")
    }
    
    static func getYibbyDropLocation() -> YBLocation {
        if let drop = defaults.string(forKey: "yibbyDropLocation"){
            return YBLocation(JSONString: drop)!
        } else {
            return YBLocation(lat: 37.430033, long: -122.173335, name: "Stanford Computer Science Department")
        }
    }

}
