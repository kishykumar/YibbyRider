//
//  StripePaymentService.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/19/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import Stripe


// StripePaymentService singleton
public class StripePaymentService: NSObject {
    
    private static let myInstance = StripePaymentService()
    
    // 1) first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    let stripePublishableKey = "pk_test_xWKW55CirtaPeSkJz81JLvYk"
    
    // 2a) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend , click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    let backendBaseURL: String? = nil
    
    // 2b) If you're saving your user's payment details, head to https://dashboard.stripe.com/test/customers ,
    // click "New", and create a customer (you can leave the fields blank). Replace nil on the line below
    // with the newly-created customer ID (it looks like cus_abcdef). In a real application, you would create
    // this customer on your backend when your user signs up for your service.
    let customerID: String? = nil
    
    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    let appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Emoji Apparel"
    let paymentCurrency = "usd"

    var configuration: STPPaymentConfiguration?
    
    override init() {
        
    }
    
    static func sharedInstance () -> StripePaymentService {
        return myInstance
    }
    
    func setupConfiguration () {
        configuration = STPPaymentConfiguration.sharedConfiguration()
        configuration!.publishableKey = self.stripePublishableKey
        configuration!.appleMerchantIdentifier = self.appleMerchantID
        configuration!.companyName = self.companyName
    }
    
    func getConfiguration () -> STPPaymentConfiguration {
        return configuration!
    }
}