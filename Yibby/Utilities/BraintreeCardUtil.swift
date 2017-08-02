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
    
    class func paymentMethodImageFromBrand(_ brand: String?) -> UIImage? {
        
        if brand == nil {
            return UIImage(named: "Unknown")
        }
        if (brand == InterfaceString.Card.AmericanExpress) {
            return UIImage(named: "Amex")
        }
        else if (brand == InterfaceString.Card.Visa) {
            return UIImage(named: "Visa")
        }
        else if (brand == InterfaceString.Card.MasterCard) {
            return UIImage(named: "MasterCard")
        }
        else if (brand == InterfaceString.Card.Discover) {
            return UIImage(named: "Discover")
        }
        else if (brand == InterfaceString.Card.JCB) {
            return UIImage(named: "JCB")
        }
        else if (brand == InterfaceString.Card.Maestro) {
            return UIImage(named: "Maestro")
        }
        else if (brand == InterfaceString.Card.DinersClub) {
            return UIImage(named: "Diners Club")
        }
        else if (brand == InterfaceString.Card.UnionPay) {
            return UIImage(named: "UnionPay")
        }
        else {
            return UIImage(named: "Unknown")
        }
    }
}
