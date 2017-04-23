//
//  PaymentObjectModels.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 4/21/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import ObjectMapper

class PaymentObjectModels: Mappable {
    
    //  JSON object:
    //    [VehicleModel, ...]
    
    // MARK: - Properties
    var models: [PaymentObjectModel]?
    
    // MARK: Initialization
    
    required init?(map: Map) {
        // do the checks here to make sure if a required property exists within the JSON.
    }
    
    // Mappable
    func mapping(map: Map) {
        models <- map[""]
    }
}

extension PaymentObjectModels {
    
}
