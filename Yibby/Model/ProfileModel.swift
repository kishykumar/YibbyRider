//
//  ProfileModel.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 4/21/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import Braintree
import ObjectMapper

class ProfileModel: Mappable {
    
    // MARK: - Properties
    var email: String?
    var name: String?
    var phoneNo: String?
    var addHomePlaceName: String?
    var addWorkPlaceName: String?
    var profilePicture: String?
    
    
    
    
    // MARK: Initialization
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        email                      <- map["email"]
        name           <- map["name"]
        phoneNo          <- map["phoneNumber"]
        addHomePlaceName                    <- map["homeLocation.name"]
        addWorkPlaceName                  <- map["workLocation.name"]
        profilePicture          <- map["profilePicture"]
    }
}
