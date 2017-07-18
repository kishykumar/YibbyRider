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

public class YBPaymentMethod: Mappable {
    
    // MARK: - Properties
    var expirationMonth: Int?
    var expirationYear: Int?
    var isDefault: Bool?
    var last4: String?
    var postalCode: Int?
    var token: String?
    var type: String?
   
    // MARK: Initialization
    
    required public init?(map: Map) {
        
    }

    // Mappable
    public func mapping(map: Map) {
        expirationMonth           <- map["expirationMonth"]
        expirationYear         <- map["expirationYear"]
        isDefault           <- map["isDefault"]
        last4         <- map["last4"]
        postalCode           <- map["postalCode"]
        token         <- map["token"]
        type           <- map["type"]
    }
}
