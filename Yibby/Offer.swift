//
//  Offer.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit

class Offer {
    
    // MARK: Properties
    
    var offerPrice: Int
    var eta: Int
    
    // MARK: Initialization
    
    init?(offerPrice: Int, eta: Int) {
        // Initialize stored properties.
        self.offerPrice = offerPrice
        self.eta = eta
        
        // Initialization should fail if there is no name or if the rating is negative.
        if offerPrice == 0 || eta == 0 {
            return nil
        }
    }
}