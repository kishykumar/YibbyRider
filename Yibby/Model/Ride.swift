//
//  Ride.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/17/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import Braintree
import ObjectMapper

class Ride: Mappable {
    
    // MARK: - Properties
    var id: String?

    var riderBidPrice: Float?
    var driverBidPrice: Float?
    var fare: Float?

    var people: Int?

//    var paymentMethod: BTPaymentMethodNonce?

    var pickupLocation: YBLocation?
    var dropoffLocation: YBLocation?
    var driverStartLocation: YBLocation?
    
    var driver: YBDriver?
    var vehicle: YBVehicle?
    
    // MARK: Initialization
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id                      <- map["id"]
        riderBidPrice           <- map["riderBidPrice"]
        driverBidPrice          <- map["driverBidPrice"]
        fare                    <- map["fare"]
        people                  <- map["people"]
        pickupLocation          <- map["pickupLocation"]
        dropoffLocation         <- map["dropoffLocation"]
        driverStartLocation     <- map["driverStartLocation"]
        driver                  <- map["driver"]
        vehicle                 <- map["vehicle"]
    }
}
