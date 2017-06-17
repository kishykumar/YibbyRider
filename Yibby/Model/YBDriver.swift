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
    var profilePictureFileId: String?
    var rating: String?
    var phoneNumber: String?
    
    // MARK: Initialization
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id                          <- map["id"]
        firstName                   <- map["firstName"]
        location                    <- map["location"]
        profilePictureFileId        <- map["profilePictureFileId"]
        rating                      <- map["rating"]
        phoneNumber                 <- map["phoneNumber"]
    }
}

extension YBDriver {
    
    func call() {
        let phoneURLString = "tel:\(self.phoneNumber)"
        let phoneURL = URL(string: phoneURLString)!
        UIApplication.shared.openURL(phoneURL)
    }
}
