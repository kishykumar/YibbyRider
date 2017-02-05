//
//  Bid.swift
//  YibbyPartner
//
//  Created by Kishy Kumar on 3/10/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps

class Bid: NSObject {
    
    // MARK: - Properties
    var id: String
    var bidHigh: Int
    var bidLow: Int
    
    var etaHigh: Int
    var etaLow: Int
    
    var pickupLocation: YBLocation
    var dropoffLocation: YBLocation
    
    // MARK: Initialization
    
    init(id: String, bidHigh: Int, bidLow: Int, etaHigh: Int, etaLow: Int, pickupLocation: YBLocation, dropoffLocation: YBLocation) {
        // Initialize stored properties.
        self.id = id
        self.bidHigh = bidHigh
        self.bidLow = bidLow
        self.etaHigh = etaHigh
        self.etaLow = etaLow
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        
        // Initialization should fail if there is no name or if the rating is negative.
//        if pickupLoc.isEmpty || dropoffLoc.isEmpty || bidHigh == 0 {
//            return nil
//        }
    }
    
//    func copy(with zone: NSZone?) -> Any {
//        let copy = Bid(id: id, bidHigh: bidHigh, bidLow: bidLow,
//            etaHigh: etaHigh, etaLow: etaLow, pickupLat: pickupLat,
//            pickupLong: pickupLong, pickupLoc: pickupLoc, dropoffLat: dropoffLat,
//            dropoffLong: dropoffLong, dropoffLoc: dropoffLoc)
//        
//        return copy!
//    }
}
