//
//  EditPaymentViewControllerDelegate.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/3/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import Braintree
import Stripe

protocol EditPaymentViewControllerDelegate {
    
    func editPaymentViewControllerDidCancel(_ editPaymentViewController: AddPaymentViewController)
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
        func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                        didCreateNewToken token: STPToken, completion: STPErrorBlock)
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
        func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                       didCreateNewToken token: BTPaymentMethodNonce, completion: @escaping BTErrorBlock)
    #endif
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
        func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                        didRemovePaymentMethod paymentMethod: STPPaymentMethod, completion: STPErrorBlock)
    
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
        func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                       didRemovePaymentMethod paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock)
    #endif
}
