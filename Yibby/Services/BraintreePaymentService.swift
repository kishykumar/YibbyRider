//
//  BraintreePaymentService.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/4/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import Braintree
import CocoaLumberjack

public typealias BTCustomerLoadCompletionBlock = () -> Void
public typealias BTCustomerPaymentLoadCompletionBlock = PaymentMethodsCompletionBlock

public typealias BTAttachSourceCompletionBlock = BTErrorBlock
public typealias BTDeleteSourceCompletionBlock = BTErrorBlock
public typealias BTDefaultSourceCompletionBlock = BTErrorBlock
public typealias BTUpdateSourceCompletionBlock = BTErrorBlock

// BraintreePaymentService singleton
open class BraintreePaymentService: NSObject {
    
    private static let myInstance = BraintreePaymentService()
    
    var customerID: String? = nil
    var clientToken: String! = nil
    
    var appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = InterfaceString.App.AppName
    let paymentCurrency = InterfaceString.Payment.PaymentCurrency
    
//    var configuration: STPPaymentConfiguration?
    
    var paymentMethods = [BTPaymentMethodNonce]()
    var allPaymentMethods = [PaymentDetailsObject]()
    
    var apiAdapter: BraintreeBackendAPIAdapter = BraintreeBackendAPI.sharedClient
    var apiClient: BTAPIClient?
    
    var defaultPaymentMethod: BTPaymentMethodNonce?
    var currentPaymentMethod: PaymentDetailsObject?
    
    override init() {
        
    }
    
    static func sharedInstance () -> BraintreePaymentService {
        return myInstance
    }
    
    func setupConfiguration (_ completionBlock: @escaping BTCustomerLoadCompletionBlock) {
        
        apiAdapter.fetchClientToken( { (clientToken: String?, error: NSError?) -> Void in
            if error == nil {
                if let clientToken = clientToken {
                    self.clientToken = clientToken

                    self.apiClient = BTAPIClient(authorization: clientToken)
                    
                   /* self.loadCustomerDetails({
                        completionBlock()
                    })*/
                    
                } else {
                    DDLogError("Error in Braintree client token: nil")    
                }
            } else {
                DDLogError("Error fetching Braintree client token")
            }
        })
    }
    
    func loadCustomerDetails(_ completionBlock: @escaping BTCustomerPaymentLoadCompletionBlock) {
        
        apiAdapter.retrievePaymentMethods(completion: { (paymentMethods: NSArray?, error: NSError?) -> Void in
            
            if error != nil {
                // TODO: handle error
                AlertUtil.displayAlert(error!.localizedDescription, message: "")
            }
            else {
               
                
                completionBlock(paymentMethods as NSArray?, nil)
            }
        })
    }

    func attachSourceToCustomer(_ paymentMethod: BTPaymentMethodNonce, completionBlock: @escaping BTAttachSourceCompletionBlock) {
        apiAdapter.attachSourceToCustomer(paymentMethod, completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
    func updateSourceForCustomer(_ paymentMethod: BTPaymentMethodNonce,
                                 oldPaymentMethod: String,
                                 completionBlock: @escaping UpdateSourceCompletionBlock) {
        apiAdapter.updateSourceForCustomer(paymentMethod,
                                           oldPaymentMethod: oldPaymentMethod,
                                           completion: {(error: Error?) -> Void in
            completionBlock(error)
        })
    }
    //with string
    func updateSourceForCustomerstring(_ paymentMethod: String,
                                 oldPaymentMethod: String,
                                 completionBlock: @escaping UpdateSourceCompletionBlock) {
        apiAdapter.updateSourceForCustomerString(paymentMethod,
                                           oldPaymentMethod: oldPaymentMethod,
                                           completion: {(error: Error?) -> Void in
                                            completionBlock(error)
        })
    }
    
    func deleteSourceFromCustomer(_ paymentMethod: String, completionBlock: @escaping BTDeleteSourceCompletionBlock) {
        apiAdapter.deleteSourceFromCustomer(paymentMethod, completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
    func selectDefaultCustomerSource(_ paymentMethod: BTPaymentMethodNonce, completionBlock: @escaping BTDefaultSourceCompletionBlock) {
        apiAdapter.selectDefaultCustomerSource(paymentMethod, completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
}
