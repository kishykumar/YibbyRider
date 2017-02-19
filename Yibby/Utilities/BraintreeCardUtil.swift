//
//  BraintreeCardUtil.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/24/16.
//  Copyright © 2016 BraintreeCardUtil. All rights reserved.
//

import Foundation
import Braintree

open class BraintreeCardUtil {

    class func paymentMethodTypeFromBrand(_ brand: String?) -> BTUIPaymentOptionType {
        
        if brand == nil {
            return BTUIPaymentOptionType.unknown
        }
        if (brand == InterfaceString.Card.AmericanExpress) {
            return BTUIPaymentOptionType.AMEX
        }
        else if (brand == InterfaceString.Card.Visa) {
            return BTUIPaymentOptionType.visa
        }
        else if (brand == InterfaceString.Card.MasterCard) {
            return BTUIPaymentOptionType.masterCard
        }
        else if (brand == InterfaceString.Card.Discover) {
            return BTUIPaymentOptionType.discover
        }
        else if (brand == InterfaceString.Card.JCB) {
            return BTUIPaymentOptionType.JCB
        }
        else if (brand == InterfaceString.Card.Maestro) {
            return BTUIPaymentOptionType.maestro
        }
        else if (brand == InterfaceString.Card.DinersClub) {
            return BTUIPaymentOptionType.dinersClub
        }
        else if (brand == InterfaceString.Card.UnionPay) {
            return BTUIPaymentOptionType.unionPay
        }
        else {
            return BTUIPaymentOptionType.unknown
        }
        
    }
}
