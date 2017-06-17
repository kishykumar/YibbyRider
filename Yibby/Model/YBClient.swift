//
//  YbClient.swift
//  Yibby
//
//  Created by Kishy Kumar on 1/3/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import UIKit
import CocoaLumberjack

enum YBClientStatus: Int {
    case looking = 0
    case ongoingBid
    case driverEnRoute
    case onRide
    case pendingRating
}

// BidState singleton
open class YBClient {
    
    private static let myInstance = YBClient()
    
    private var status: YBClientStatus
    private var bid: Bid?
    private var ride: Ride?
    private var profile: YBProfile?
    
    init() {
        status = .looking
    }
    
    static func sharedInstance () -> YBClient {
        return myInstance
    }
    
    func setBid (_ bid: Bid?) { self.bid = bid }
    func getBid () -> Bid? { return bid }
    
    func setRide (_ ride: Ride?) { self.ride = ride }
    func getRide () -> Ride? { return ride }
    
    func setProfile (_ profile: YBProfile?) { self.profile = profile }
    func getProfile () -> YBProfile? { return profile }
    
    func setStatus (_ status: YBClientStatus) { self.status = status }
    func getStatus () -> YBClientStatus? { return status }
}

extension YBClient {

    func resetBid () {
        setBid(nil)
    }
    
    func isOngoingBid () -> Bool {
        return (getBid() != nil)
    }
    
    func isSameAsOngoingBid (bidId: String?) -> Bool {
        
        if (getBid() == nil || bidId == nil) {
            return false
        }
        
        return ((getBid()!.id ) == bidId)
    }
}
