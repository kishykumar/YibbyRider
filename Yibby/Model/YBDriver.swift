//
//  YBDriver.swift
//  Yibby
//
//  Created by Kishy Kumar on 1/3/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper

class YBDriver: Mappable {
    
    // MARK: - Properties
    var id: String?
    var firstName: String?
    var location: YBLocation?
    var photoUrl: String?
    var rating: String?
    var mobile: String?
    
    // MARK: Initialization
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id           <- map["id"]
        firstName    <- map["firstName"]
        location     <- map["location"]
        photoUrl     <- map["photoUrl"]
        rating       <- map["rating"]
        mobile       <- map["mobile"]
    }
}

extension YBDriver {
    
    func call() {
        let phoneURLString = "tel:\(self.mobile)"
        let phoneURL = URL(string: phoneURLString)!
        UIApplication.shared.openURL(phoneURL)
    }
}
