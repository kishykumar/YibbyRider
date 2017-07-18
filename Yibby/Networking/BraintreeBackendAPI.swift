//
//  BraintreeBackendAPI.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/4/16.
//  Copyright © 2016 Yibby. All rights reserved.
//


import Foundation
import BaasBoxSDK
import CocoaLumberjack
import Alamofire
import Braintree
import ObjectMapper

public typealias MakeTransactionCompletionBlock = (_ transactionId: String, _ error: NSError?) -> Void
public typealias TokenFetchCompletionBlock = (_ clientToken: String?, _ error: NSError?) -> Void
public typealias PaymentMethodsCompletionBlock = (_ paymentMethods: [YBPaymentMethod]?, _ error: NSError?) -> Void
public typealias BTErrorBlock = (NSError?) -> Void
public typealias PaymentMethodCompletionBlock = (_ paymentMethod: YBPaymentMethod?, _ error: NSError?) -> Void

public protocol BraintreeBackendAPIAdapter {
    
    func fetchClientToken(_ completionBlock: @escaping TokenFetchCompletionBlock)
    
    func retrievePaymentMethods( completion: @escaping PaymentMethodsCompletionBlock)
    
    func deleteSourceFromCustomer(_ paymentMethod: YBPaymentMethod, completionBlock: @escaping BTErrorBlock)
    
    func updateSourceForCustomer(_ newPaymentMethodNonce: BTPaymentMethodNonce,
                                 oldPaymentMethod: YBPaymentMethod,
                                 completion: @escaping BTErrorBlock)
    
    func attachSourceToCustomer(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping PaymentMethodCompletionBlock)
    
    func selectDefaultCustomerSource(_ paymentMethod: YBPaymentMethod, completion: @escaping PaymentMethodCompletionBlock)
}

class BraintreeBackendAPI: NSObject, BraintreeBackendAPIAdapter {
    
    // MARK: - Properties

    
    // used for fake cards
//    var defaultSource: BTPaymentMethodNonce? = nil
//    var sources: [BTPaymentMethodNonce] = []
    
    static var sharedClient = BraintreeBackendAPI()
    
    static func sharedInit() {
        sharedClient = BraintreeBackendAPI()
    }
    
   /* init(_: ) {
        super.init()
//        self.setupFakeCards()
    }*/
    
//    func setupFakeCards () {
//        
//        guard let _ = customerID else {
//            let card1 = BTPaymentMethodNonce(nonce: "123x", localizedDescription: "*4242", type: "Visa", isDefault: false)
//            let card2 = BTPaymentMethodNonce(nonce: "123y", localizedDescription: "*4244", type: "Amex", isDefault: false)
//            let card3 = BTPaymentMethodNonce(nonce: "123z", localizedDescription: "*4246", type: "MasterCard", isDefault: true)
//            let card4 = BTPaymentMethodNonce(nonce: "123w", localizedDescription: "*4248", type: "Visa", isDefault: false)
//            
//            self.sources.append(card1!)
//            self.sources.append(card2!)
//            self.sources.append(card3!)
//            self.sources.append(card4!)
//            
//            self.defaultSource = card1
//            
//            return;
//        }
//    }
    
    func addPaymentCard(nonce: AnyObject)
    {
        
        let client: BAAClient = BAAClient.shared()
        
        client.addPaymentMethod(BAASBOX_RIDER_STRING, paymentMethodNonce: nonce as! String, completion: {(success, error) -> Void in
            
            print(success as Any)
            
            if ((success) != nil) {
                DDLogVerbose("PaymentMethod added successfully \(success)")
                
                //back
            }
            else {
                DDLogVerbose("Error PaymentMethod in: \(error)")
                
                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                    
                    // check for authentication error and redirect the user to Login page
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })
    }

    func fetchClientToken(_ completionBlock: @escaping TokenFetchCompletionBlock) {

        let client: BAAClient = BAAClient.shared()
        client.getPaymentClientToken(BAASBOX_RIDER_STRING,completion: {(success, error) -> Void in
            
            
            if (error == nil)
            {
                completionBlock(success as? String, error as NSError?)
            }
            else
            {
                completionBlock(nil, error as NSError?)
            }
            
        })
    }
    
    func retrievePaymentMethods( completion: @escaping PaymentMethodsCompletionBlock) {
    
        let client: BAAClient = BAAClient.shared()
        client.getPaymentMethods(BAASBOX_RIDER_STRING, completion:{(success, error) -> Void in
            
            if (success != nil) {
                let paymentMethods = Mapper<YBPaymentMethod>().mapArray(JSONObject: success)
                completion(paymentMethods, nil)
            }
            else {
                completion(nil, error as NSError?)
            }
        })
    }
    
    func selectDefaultCustomerSource(_ paymentMethod: YBPaymentMethod, completion: @escaping PaymentMethodCompletionBlock) {
        
        let client: BAAClient = BAAClient.shared()
        client.makeDefaultPaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: paymentMethod.token, completion: {(success, error) -> Void in
            
            if (success != nil) {
                let paymentMethodModel = Mapper<YBPaymentMethod>().map(JSONObject: success)
                completion(paymentMethodModel, error as NSError?)
            } else {
                completion(nil, error as NSError?)
            }
        })
    }
    
    func attachSourceToCustomer(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping PaymentMethodCompletionBlock) {
        
        let client: BAAClient = BAAClient.shared()
        client.addPaymentMethod(BAASBOX_RIDER_STRING, paymentMethodNonce: paymentMethod.nonce, completion: {(success, error) -> Void in
            
            if (success != nil) {
                let paymentMethodModel = Mapper<YBPaymentMethod>().map(JSONObject: success)
                completion(paymentMethodModel, error as NSError?)
            } else {
                completion(nil, error as NSError?)
            }
        })
    }
    
    func updateSourceForCustomer(_ newPaymentMethodNonce: BTPaymentMethodNonce,
                                oldPaymentMethod: YBPaymentMethod,
                                completion: @escaping BTErrorBlock) {

        let client: BAAClient = BAAClient.shared()
        client.updatePaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: oldPaymentMethod.token, paymentMethodNonce: newPaymentMethodNonce.nonce, completion: {(success, error) -> Void in
            
            print(success as Any)
            
            completion(error as NSError?)
            
        })
    }
    
    func deleteSourceFromCustomer(_ paymentMethod: YBPaymentMethod,
                                  completionBlock: @escaping BTErrorBlock) {

        let client: BAAClient = BAAClient.shared()
        client.deletePaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: paymentMethod.token, completion: {(success, error) -> Void in
            
            if let successBool = success as? Bool {
                if (successBool == true) {
                    completionBlock(nil)
                } else {
                    completionBlock(error as NSError?)
                }
            }
        })
    }
}
