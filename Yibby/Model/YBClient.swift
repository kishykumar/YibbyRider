//
//  YbClient.swift
//  Yibby
//
//  Created by Kishy Kumar on 1/3/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import UIKit
import CocoaLumberjack

enum YBClientStatus: String {
    case looking = "LOOKING"
    case ongoingBid = "BID_IN_PROCESS"
    case failedNoOffers = "FAILED_NO_OFFERS"
    case failedHighOffers = "FAILED_HIGH_OFFERS"
    case driverEnRoute = "DRIVER_EN_ROUTE"
    case driverArrived = "DRIVER_ARRIVED"
    case onRide = "RIDE_START"
    case pendingRating = "RIDE_END"
}

// BidState singleton
open class YBClient {
    
    private static let myInstance = YBClient()
    
    var status: YBClientStatus
    
    var bid: Bid? {
        didSet {
            if (self.bid == nil) {
                removePersistedBidId()
            } else {
                persistBidId()
            }
        }
    }
    
    var ride: Ride?
    var profile: YBProfile?
    var paymentMethods = [YBPaymentMethod]()
    var defaultPaymentMethod: YBPaymentMethod?
    
    let APP_BID_ID_KEY = "APP_BID_ID"
    
    init() {
        status = .looking
    }
    
    static func sharedInstance () -> YBClient {
        return myInstance
    }
    
//    func setBid (_ bid: Bid?) { self.bid = bid }
//    func getBid () -> Bid? { return bid }
//    
//    func setRide (_ ride: Ride?) { self.ride = ride }
//    func getRide () -> Ride? { return ride }
//    
//    func setProfile (_ profile: YBProfile?) { self.profile = profile }
//    func getProfile () -> YBProfile? { return profile }
//    
//    func setStatus (_ status: YBClientStatus) { self.status = status }
//    func getStatus () -> YBClientStatus? { return status }
//    
//    func setPaymentMethods (_ pms: [PaymentMethod]) { self.paymentMethods = pms }
//    func getPaymentMethods () -> [PaymentMethod]? { return self.paymentMethods }
    
    func isOngoingBid () -> Bool {
        return (bid != nil)
    }
    
    func isSameAsOngoingBid (bidId: String?) -> Bool {
        
        if (bid == nil || bidId == nil) {
            return false
        }
        
        return ((bid!.id ) == bidId)
    }

    func syncClient(_ syncData: YBSync) {
        defaultPaymentMethod = nil
        if let myBid = syncData.bid {
            self.bid = myBid
        }
        
        if let myRide = syncData.ride {
            self.ride = myRide
        }
        
        if let myProfile = syncData.profile {
            self.profile = myProfile
        }
        
        if let status = syncData.status {
            self.status = status
        }
        
        if let paymentMethods = syncData.paymentMethods {
            if (paymentMethods.count != 0) {
                refreshPaymentMethods(paymentMethods)
            }
        }
    }

    func refreshPaymentMethods(_ paymentMethods: [YBPaymentMethod]) {
        
        self.paymentMethods = paymentMethods
        
        // Loop through all the payment Methods to find the default one
        for pm in paymentMethods {
            if let isDefault = pm.isDefault, isDefault == true {
                self.defaultPaymentMethod = pm
                break;
            }
        }
        assert(self.defaultPaymentMethod != nil)
    }
    
    fileprivate func persistBidId() {
        let bidId = self.bid?.id
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(bidId, forKey: APP_BID_ID_KEY)
    }
    
    fileprivate func removePersistedBidId() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: APP_BID_ID_KEY)
    }
    
    func getPersistedBidId() -> String? {
        let userDefaults = UserDefaults.standard
        let bidId = userDefaults.object(forKey: APP_BID_ID_KEY) as? String
        return bidId
    }
}
