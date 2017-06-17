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

class YBProfile: Mappable {
    
    // MARK: - Properties
    var email: String?
    var name: String?
    var phoneNumber: String?
    var profilePicture: String?
    var homeLocation: YBLocation?
    var workLocation: YBLocation?
    
    // MARK: Initialization
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        email               <- map["email"]
        name                <- map["name"]
        phoneNumber         <- map["phoneNumber"]
        profilePicture      <- map["profilePicture"]
        homeLocation        <- map["homeLocation"]
        workLocation        <- map["workLocation"]
        
    }
}
