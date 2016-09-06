//
//  AddPaymentViewControllerDelegate.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/3/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import Braintree
import Stripe

protocol AddPaymentViewControllerDelegate {
    
    /**
     *  Called when the user cancels adding a card. You should dismiss (or pop) the view controller at this point.
     *
     *  @param addPaymentViewController the view controller that has been cancelled
     */
    
    func addPaymentViewControllerDidCancel(addPaymentViewController: AddPaymentViewController)
    
    /**
     *  This is called when the user successfully adds a card and tokenizes it with Stripe. You should send the token to your backend to store it on a customer, and then call the provided `completion` block when that call is finished. If an error occurred while talking to your backend, call `completion(error)`, otherwise, call `completion(nil)` and then dismiss (or pop) the view controller.
     *
     *  @param addPaymentViewController the view controller that successfully created a token
     *  @param token                 the Stripe token that was created. @see STPToken
     *  @param completion            call this callback when you're done sending the token to your backend
     */
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
    didCreateToken token: STPToken, completion: STPErrorBlock)
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                  didCreateNonce paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock)
    #endif
    
}