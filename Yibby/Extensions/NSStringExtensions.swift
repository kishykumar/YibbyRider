//
//  NSStringExtensions.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//
import Stripe
extension NSString {
    
    class func stp_stringWithCardBrand(brand: STPCardBrand) -> String {
        switch brand {
        case STPCardBrand.Amex:
            return "American Express"
        case STPCardBrand.DinersClub:
            return "Diners Club"
        case STPCardBrand.Discover:
            return "Discover"
        case STPCardBrand.JCB:
            return "JCB"
        case STPCardBrand.MasterCard:
            return "MasterCard"
        case STPCardBrand.Unknown:
            return "Unknown"
        case STPCardBrand.Visa:
            return "Visa"
        }
    }
}
func linkNSStringCardBrandsCategory() {
}