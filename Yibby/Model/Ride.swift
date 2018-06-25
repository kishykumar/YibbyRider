//
//  Ride.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/17/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import Braintree
import ObjectMapper

enum RideCancelled: Int {
    case notCancelled = 0
    case cancelledByRider = 1
    case cancelledByDriver = 2
}

class Ride: Mappable {
    
    // MARK: - Properties
    var bidId: String?
    var datetime: String?
    var driver: YBDriver?
    var bidPrice: Float?
    var driverLocation: YBLocation?
    var dropoffLocation: YBLocation?
    var id: String?
    var tripDistance: Float?
    var paymentMethodToken: String?
    var paymentMethodBrand: String?
    var paymentMethodLast4: String?
    var numPeople: Int?
    var pickupLocation: YBLocation?
    var rideTime: Int?
    var tip: Float?
    var otherFees: Float?
    var vehicle: YBVehicle?
    var cancelled: Int?
    
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
        bidPrice                <- map["bidPrice"]
        driverLocation          <- map["driverLocation"]
        dropoffLocation         <- map["dropoffLocation"]
        id                      <- map["id"]
        tripDistance            <- map["tripDistance"]
        paymentMethodToken      <- map["paymentMethodToken"]
        paymentMethodBrand      <- map["paymentMethodBrand"]
        paymentMethodLast4      <- map["paymentMethodLast4"]
        numPeople               <- map["people"]
        pickupLocation          <- map["pickupLocation"]
        rideTime                <- map["rideTime"]
        tip                     <- map["tip"]
        vehicle                 <- map["vehicle"]
        cancelled               <- map["cancelled"]
    }
}
