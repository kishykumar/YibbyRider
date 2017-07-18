//
//  Sync.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/25/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import UIKit
import ObjectMapper

class YBSync: Mappable {
    
    // MARK: - Properties
    var status: YBClientStatus?
    var bid: Bid?
    var ride: Ride?
    var profile: YBProfile?
    var paymentMethods: [YBPaymentMethod]?
    
    // MARK: Initialization
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        bid             <- map["bid"]
        status          <- map["status"]
        ride            <- map["ride"]
        profile         <- map["profile"]
        paymentMethods  <- map["paymentMethods"]
    }
}
