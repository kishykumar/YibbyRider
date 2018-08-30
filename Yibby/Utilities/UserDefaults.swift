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
    
    static func setYibbyPickLocation(pickLocation: String) {
        defaults.set(pickLocation, forKey: "yibbyPickLocation")
    }
    
    static func getYibbyPickLocation() -> String {
        if let pick = defaults.string(forKey: "yibbyPickLocation"){
            return pick
        } else {
            return "no pick location"
        }
        
    }
    
    static func setYibbyDropLocation(dropLocation: String) {
        defaults.set(dropLocation, forKey: "yibbyDropLocation")
    }
    
    static func getYibbyDropLocation() -> String {
        if let drop = defaults.string(forKey: "yibbyDropLocation"){
            return drop
        } else {
            return "no drop location"
        }
    }

}
