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

public class YBPaymentMethods: Mappable {
    
    //  JSON object:
    //    [YBPaymentMethod, ...]
    
    // MARK: - Properties
    var models: [YBPaymentMethod]?
    
    // MARK: Initialization
    
    required public init?(map: Map) {
        // do the checks here to make sure if a required property exists within the JSON.
    }
    
    // Mappable
    public func mapping(map: Map) {
        models <- map["Models"]
    }
}
