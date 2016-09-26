//
//  BraintreeCardUtil.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/24/16.
//  Copyright © 2016 BraintreeCardUtil. All rights reserved.
//

import Foundation
import Braintree

public class BraintreeCardUtil {

    class func paymentMethodTypeFromBrand(brand: String?) -> BTUIPaymentOptionType {
        
        if brand == nil {
            return BTUIPaymentOptionType.Unknown
        }
        if (brand == InterfaceString.Card.AmericanExpress) {
            return BTUIPaymentOptionType.AMEX
        }
        else if (brand == InterfaceString.Card.Visa) {
            return BTUIPaymentOptionType.Visa
        }
        else if (brand == InterfaceString.Card.MasterCard) {
            return BTUIPaymentOptionType.MasterCard
        }
        else if (brand == InterfaceString.Card.Discover) {
            return BTUIPaymentOptionType.Discover
        }
        else if (brand == InterfaceString.Card.JCB) {
            return BTUIPaymentOptionType.JCB
        }
        else if (brand == InterfaceString.Card.Maestro) {
            return BTUIPaymentOptionType.Maestro
        }
        else if (brand == InterfaceString.Card.DinersClub) {
            return BTUIPaymentOptionType.DinersClub
        }
        else if (brand == InterfaceString.Card.UnionPay) {
            return BTUIPaymentOptionType.UnionPay
        }
        else {
            return BTUIPaymentOptionType.Unknown
        }
        
    }
}