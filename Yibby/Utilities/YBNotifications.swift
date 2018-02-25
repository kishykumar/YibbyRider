//
//  YBNotifications.swift
//  YibbyPartner
//
//  Created by Kishy Kumar on 1/28/18.
//  Copyright © 2017 Yibby. All rights reserved.
//

import Foundation

public struct BidNotifications {
    
    // @notUsed
    //static let counterOffer = TypedNotification<Bid>(name: "com.Yibby.Bid.CounterOffer")
    
    static let noOffers = TypedNotification<Bid>(name: "com.Yibby.Bid.NoOffers")
}

public struct RideNotifications {
    static let driverEnRoute = TypedNotification<Ride>(name: "com.Yibby.Ride.DriverEnRoute")
    static let rideStart = TypedNotification<String>(name: "com.Yibby.Ride.RideStart")
    static let driverArrived = TypedNotification<String>(name: "com.Yibby.Ride.DriverArrived")
    static let rideEnd = TypedNotification<String>(name: "com.Yibby.Ride.RideEnd")
}
