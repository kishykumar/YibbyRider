//
//  DriverEta.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import UIKit
import Braintree
import ObjectMapper

class DriverEta: Mappable {
    
    // MARK: - Properties
    var loc: YBLocation?
    var eta: Int?
    var dist: Int?
    
    // MARK: Initialization
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        loc                <- map["loc"]
        eta                <- map["eta"]
        dist               <- map["dist"]
    }
}
