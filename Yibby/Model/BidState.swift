//
//  BidState.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/27/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

// BidState singleton
open class BidState {
    
    fileprivate static let myInstance = BidState()
    fileprivate var ongoingBid: Bid?
    
    init() {
        ongoingBid = nil
    }
    
    static func sharedInstance () -> BidState {
        return myInstance
    }

    func setOngoingBid (_ inBid: Bid) {
        ongoingBid = inBid.copy() as? Bid // copies over the dictionary
    }

    func getOngoingBid () -> Bid? {
        return ongoingBid
    }

    func resetOngoingBid () {
        ongoingBid = nil
    }

    func isOngoingBid () -> Bool {
        return (ongoingBid != nil)
    }

    func isSameAsOngoingBid (_ bidId: String?) -> Bool {
        
        if (ongoingBid == nil || bidId == nil) {
            return false
        }
        
        return ((ongoingBid!.id ) == bidId)
    }
}
