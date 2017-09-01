//
//  Ride.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/17/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import Braintree
import ObjectMapper

class Ride: Mappable {
    
    // MARK: - Properties
    var bidId: String?
    var datetime: String?
    var driver: YBDriver?
    var driverBidPrice: Float?
    var driverLocation: YBLocation?
    var dropoffLocation: YBLocation?
    var fare: Float?
    var id: String?
    var miles: Float?
    var paymentMethodToken: String?
    var paymentMethodBrand: String?
    var paymentMethodLast4: String?
    var numPeople: Int?
    var pickupLocation: YBLocation?
    var rideTime: Int?
    var riderBidPrice: Float?
    var tip: Float?
    var vehicle: YBVehicle?
    
    // MARK: Initialization
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        bidId                   <- map["bidId"]
        datetime                <- map["datetime"]
        driver                  <- map["driver"]
        driverBidPrice          <- map["driverBidPrice"]
        driverLocation          <- map["driverLocation"]
        dropoffLocation         <- map["dropoffLocation"]
        fare                    <- map["fare"]
        id                      <- map["id"]
        miles                   <- map["miles"]
        paymentMethodToken      <- map["paymentMethodToken"]
        paymentMethodBrand      <- map["paymentMethodBrand"]
        paymentMethodLast4      <- map["paymentMethodLast4"]
        numPeople               <- map["people"]
        pickupLocation          <- map["pickupLocation"]
        rideTime                <- map["rideTime"]
        riderBidPrice           <- map["riderBidPrice"]
        tip                     <- map["tip"]
        vehicle                 <- map["vehicle"]
    }
}
