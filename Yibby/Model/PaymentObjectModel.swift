//
//  PaymentObjectModel.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 4/21/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import ObjectMapper

class PaymentObjectModel: Mappable {
    
    //  JSON object:
    //    {
    //    "model_name": "Crown Victoria",
    //    "model_make_id": "ford"
    //    }
    
    // MARK: - Properties
    var expirationMonth: String?
    var expirationYear: String?
    var isDefault: String?
    var last4: String?
    var postalCode: String?
    var token: String?
    var type: String?
   
    
    // MARK: Initialization
    
    required init?(map: Map) {
        
    }


    // Mappable
    func mapping(map: Map) {
        expirationMonth           <- map["expirationMonth"]
        expirationYear         <- map["expirationYear"]
        isDefault           <- map["isDefault"]
        last4         <- map["last4"]
        postalCode           <- map["postalCode"]
        token         <- map["token"]
        type           <- map["type"]
    
    }
}

extension PaymentObjectModel {
    
}
