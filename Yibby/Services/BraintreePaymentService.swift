//
//  BraintreePaymentService.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/4/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import Braintree
import CocoaLumberjack
import ObjectMapper

public typealias BTSetupCompletionBlock = BTErrorBlock
public typealias BTCustomerLoadCompletionBlock = () -> Void
public typealias BTCustomerPaymentLoadCompletionBlock = BTErrorBlock
public typealias BTAttachSourceCompletionBlock = BTErrorBlock
public typealias BTDeleteSourceCompletionBlock = BTErrorBlock
public typealias BTDefaultSourceCompletionBlock = BTErrorBlock
public typealias BTUpdateSourceCompletionBlock = BTErrorBlock

// BraintreePaymentService singleton
open class BraintreePaymentService: NSObject {
    
    private static let myInstance = BraintreePaymentService()
    
//    var customerID: String? = nil
    var clientToken: String! = nil
    
//    var appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
//    let companyName = InterfaceString.App.AppName
//    let paymentCurrency = InterfaceString.Payment.PaymentCurrency
    
//    var configuration: STPPaymentConfiguration?
    
//    var paymentMethods = [BTPaymentMethodNonce]()
//    var allPaymentMethods = [PaymentDetailsObject]()
    
    var apiAdapter: BraintreeBackendAPIAdapter = BraintreeBackendAPI.sharedClient
    var apiClient: BTAPIClient?
    
//    var defaultPaymentMethod: BTPaymentMethodNonce?
//    var currentPaymentMethod: PaymentDetailsObject?
    
    override init() {
        
    }
    
    static func sharedInstance () -> BraintreePaymentService {
        return myInstance
    }
    
    func setupConfiguration (_ completionBlock: @escaping BTSetupCompletionBlock) {
        
        apiAdapter.fetchClientToken( { (clientToken: String?, error: NSError?) -> Void in
            if error == nil {
                if let clientToken = clientToken {
                    self.clientToken = clientToken

                    self.apiClient = BTAPIClient(authorization: clientToken)
                    completionBlock(nil)
                } else {
                    DDLogError("Error in Braintree client token: nil")
                    completionBlock(InterfaceError.createNSError(InterfaceError.Error.paymentsSetupFailure))
                }
            } else {
                DDLogError("Error fetching Braintree client token")
                completionBlock(error)
            }
        })
    }
    
    func loadCustomerDetails(_ completionBlock: @escaping BTCustomerPaymentLoadCompletionBlock) {
        
        apiAdapter.retrievePaymentMethods(completion: { (paymentMethods: [YBPaymentMethod]?, error: NSError?) -> Void in
            
            if (error == nil && paymentMethods != nil) {
                YBClient.sharedInstance().refreshPaymentMethods((paymentMethods)!)
            }
            
            completionBlock(error)
        })
    }

    func attachSourceToCustomer(_ paymentMethodNonce: BTPaymentMethodNonce, completionBlock: @escaping BTAttachSourceCompletionBlock) {
        
        apiAdapter.attachSourceToCustomer(paymentMethodNonce, completion: {(paymentMethodModel: YBPaymentMethod?, error: NSError?) -> Void in

            if (error == nil) {
                // add the payment method to the local list of payment methods
                YBClient.sharedInstance().paymentMethods.append(paymentMethodModel!)
                
                if let isDefaultPM = paymentMethodModel?.isDefault {
                    if (isDefaultPM) {
                        YBClient.sharedInstance().defaultPaymentMethod = paymentMethodModel
                    }
                }
            }
            
            completionBlock(error)
        })
    }
    
    func updateSourceForCustomer(_ paymentMethod: BTPaymentMethodNonce,
                                 oldPaymentMethod: YBPaymentMethod,
                                 completionBlock: @escaping UpdateSourceCompletionBlock) {
        
        apiAdapter.updateSourceForCustomer(paymentMethod,
                                           oldPaymentMethod: oldPaymentMethod,
                                           completion: {(error: Error?) -> Void in
            completionBlock(error)
        })
    }
    
    func deleteSourceFromCustomer(_ paymentMethod: YBPaymentMethod, completionBlock: @escaping BTDeleteSourceCompletionBlock) {
        
        apiAdapter.deleteSourceFromCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
            
            let listedPaymentMethods = YBClient.sharedInstance().paymentMethods
            let index = listedPaymentMethods.index{$0 === paymentMethod}
            
            if (index != nil) {
                
                // Special case: if the default payment method was deleted, we need to refresh the list from the server
                if (paymentMethod.token == YBClient.sharedInstance().defaultPaymentMethod?.token) {
                    
                    self.loadCustomerDetails({(error: NSError?) -> Void in
                      completionBlock(error)
                    })
                    return;
                }
                
                YBClient.sharedInstance().paymentMethods.remove(at: index!)
            }
            
            completionBlock(error)
        })
    }
    
    func selectDefaultCustomerSource(_ paymentMethod: YBPaymentMethod, completionBlock: @escaping BTDefaultSourceCompletionBlock) {
        
        apiAdapter.selectDefaultCustomerSource(paymentMethod, completion: {(paymentMethodModel: YBPaymentMethod?, error: NSError?) -> Void in
            
            if (error == nil) {
                
                // Loop through all the payment Methods to find the old default one and unmark it
                for pm in YBClient.sharedInstance().paymentMethods {
                    if let isDefault = pm.isDefault, isDefault == true {
                        pm.isDefault = false
                        break;
                    }
                }
                
                // Loop through all the payment Methods to find the new default and mark it
                for pm in YBClient.sharedInstance().paymentMethods {
                    if pm.token == paymentMethodModel?.token {
                        
                        pm.isDefault = true
                        
                        // update the state for old default payment Method and the new one
                        YBClient.sharedInstance().defaultPaymentMethod = pm
                        break;
                    }
                }
            }
            
            completionBlock(error)
            
        })
    }
    
}
