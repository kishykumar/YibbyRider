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
public typealias BTAttachSourceCompletionBlock = BTErrorBlock
public typealias BTDeleteSourceCompletionBlock = BTErrorBlock
public typealias BTDefaultSourceCompletionBlock = BTErrorBlock
public typealias BTUpdateSourceCompletionBlock = BTErrorBlock

// BraintreePaymentService singleton
public class BraintreePaymentService: NSObject {
    
    private static let myInstance = BraintreePaymentService()
    
    var customerID: String? = nil
    var clientToken: String! = nil
    
    var appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = InterfaceString.App.AppName
    let paymentCurrency = InterfaceString.Payment.PaymentCurrency
    
//    var configuration: STPPaymentConfiguration?
    
    var paymentMethods = [BTPaymentMethodNonce]()
    
    var apiAdapter: BraintreeBackendAPIAdapter = BraintreeBackendAPI.sharedClient
    var apiClient: BTAPIClient?
    
    var defaultPaymentMethod: BTPaymentMethodNonce?
    
    override init() {
        
    }
    
    static func sharedInstance () -> BraintreePaymentService {
        return myInstance
    }
    
    func setupConfiguration (completionBlock: BTCustomerLoadCompletionBlock) {
        
        apiAdapter.fetchClientToken( { (clientToken: String?, error: NSError?) -> Void in
            if error == nil {
                if let clientToken = clientToken {
                    self.clientToken = clientToken

                    self.apiClient = BTAPIClient(authorization: clientToken)
                    
                    self.loadCustomerDetails({
                        completionBlock()
                    })
                    
                } else {
                    DDLogError("Error in Braintree client token: nil")    
                }
            } else {
                DDLogError("Error fetching Braintree client token")
            }
        })
    }
    
    func loadCustomerDetails(completionBlock: BTCustomerLoadCompletionBlock) {
        
        apiAdapter.retrievePaymentMethods(self.clientToken,
                                          completion: { (paymentMethods: [BTPaymentMethodNonce]?, error: NSError?) -> Void in
            
            if error != nil {
                // TODO: handle error
                AlertUtil.displayAlert(error!.localizedDescription, message: "")
            }
            else {
                if let paymentMethods = paymentMethods {
                    self.paymentMethods.removeAll()
                    self.defaultPaymentMethod = nil
                    
                    self.paymentMethods = paymentMethods
                    
                    for method in paymentMethods {
                        if method.isDefault {
                            self.defaultPaymentMethod = method
                        }
                    }
                }
                
                completionBlock()
            }
        })
    }

    func attachSourceToCustomer(paymentMethod: BTPaymentMethodNonce, completionBlock: BTAttachSourceCompletionBlock) {
        apiAdapter.attachSourceToCustomer(paymentMethod, completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
    func updateSourceForCustomer(paymentMethod: BTPaymentMethodNonce,
                                 oldPaymentMethod: BTPaymentMethodNonce,
                                 completionBlock: UpdateSourceCompletionBlock) {
        apiAdapter.updateSourceForCustomer(paymentMethod,
                                           oldPaymentMethod: oldPaymentMethod,
                                           completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
    func deleteSourceFromCustomer(paymentMethod: BTPaymentMethodNonce, completionBlock: BTDeleteSourceCompletionBlock) {
        apiAdapter.deleteSourceFromCustomer(paymentMethod, completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
    func selectDefaultCustomerSource(paymentMethod: BTPaymentMethodNonce, completionBlock: BTDefaultSourceCompletionBlock) {
        apiAdapter.selectDefaultCustomerSource(paymentMethod, completion: {(error: NSError?) -> Void in
            completionBlock(error)
        })
    }
    
}