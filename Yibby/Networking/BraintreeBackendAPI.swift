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

public typealias MakeTransactionCompletionBlock = (transactionId: String, error: NSError?) -> Void
public typealias TokenFetchCompletionBlock = (clientToken: String?, error: NSError?) -> Void
public typealias PaymentMethodsCompletionBlock = (paymentMethods: [BTPaymentMethodNonce]?, error: NSError?) -> Void
public typealias BTErrorBlock = (NSError?) -> Void

public protocol BraintreeBackendAPIAdapter {
    
    // complete charge equivalent to Stripe
    func makeTransaction(paymentMethodNonce: String, completion completionBlock: MakeTransactionCompletionBlock)
    
    func fetchClientToken(completionBlock: TokenFetchCompletionBlock)
    
    func retrievePaymentMethods(clientToken: String, completion: PaymentMethodsCompletionBlock)
    
    func deleteSourceFromCustomer(paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock)
    
    func updateSourceForCustomer(paymentMethod: BTPaymentMethodNonce,
                                 oldPaymentMethod: BTPaymentMethodNonce,
                                 completion: BTErrorBlock)
    
    func attachSourceToCustomer(paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock)
    
    func selectDefaultCustomerSource(paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock)
}

class BraintreeBackendAPI: NSObject, BraintreeBackendAPIAdapter {
    
    // MARK: Properties
    
    let customerID: String?
    
    // used for fake cards
    var defaultSource: BTPaymentMethodNonce? = nil
    var sources: [BTPaymentMethodNonce] = []
    
    static var sharedClient = BraintreeBackendAPI(customerID: nil)
    
    static func sharedInit(customerID: String?) {
        sharedClient = BraintreeBackendAPI(customerID: customerID)
    }
    
    init(customerID: String?) {
        self.customerID = customerID
        super.init()
        self.setupFakeCards()
    }
    
    func setupFakeCards () {
        
        guard let _ = customerID else {
            let card1 = BTPaymentMethodNonce(nonce: "123x", localizedDescription: "ending in 42", type: "Visa", isDefault: false)
            let card2 = BTPaymentMethodNonce(nonce: "123y", localizedDescription: "ending in 44", type: "Amex", isDefault: false)
            let card3 = BTPaymentMethodNonce(nonce: "123z", localizedDescription: "ending in 46", type: "MasterCard", isDefault: true)
            let card4 = BTPaymentMethodNonce(nonce: "123w", localizedDescription: "ending in 48", type: "Visa", isDefault: false)
            
            self.sources.append(card1!)
            self.sources.append(card2!)
            self.sources.append(card3!)
            self.sources.append(card4!)
            
            self.defaultSource = card1
            
            return;
        }
    }
    
    func makeTransaction(paymentMethodNonce: String, completion completionBlock: MakeTransactionCompletionBlock) {
    
//        guard let customerID = customerID else {
//            completion(nil)
//            DDLogError("Customer ID nil for Stripe Client.")
//            return
//        }
//        
//        let path = "charge"
//        
//        let params: [String: AnyObject] = [
//            "source": result.source.stripeID,
//            "amount": amount,
//            "customer": customerID
//        ]
//        
//        let client: BAAClient = BAAClient.sharedClient()
//        client.postPath(path, parameters: params,
//                        
//                        success: {(responseObject: (AnyObject)!) -> Void in
//                            completion(nil)
//            },
//                        
//                        failure: {(error: (NSError)!) -> Void in
//                            completion(error)
//            }
//        )
    }
    
    func fetchClientToken(completionBlock: TokenFetchCompletionBlock) {
        
        let client: BAAClient = BAAClient.sharedClient()
        guard let customerID = customerID else {
            
            completionBlock(clientToken: "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI2YmU3MGIzY2IzNTcwZDY3MzU0YjdjMmIyMGQyNjllOGM5ODkwNTE5MGYxZGRlN2ZkN2Q5NDIzY2U3MmQ0ZTAwfGNyZWF0ZWRfYXQ9MjAxNi0wOC0wN1QwOTowNzowOC41NDgyMzUxNjErMDAwMFx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL2RjcHNweTJicndkanIzcW4ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6InN0Y2gybmZkZndzenl0dzUiLCJjdXJyZW5jeUlzb0NvZGUiOiJVU0QifSwiY29pbmJhc2VFbmFibGVkIjp0cnVlLCJjb2luYmFzZSI6eyJjbGllbnRJZCI6IjdlYTc5N2EyYmY2ZjM2YmY5NjFmYTc5ZTk0YTQwNjBlODM2ZTc1NmEyYzM1ZGU4MjlmYzM0NzI3YTJhYmYxODEiLCJtZXJjaGFudEFjY291bnQiOiJjb2luYmFzZS1zYW5kYm94LXNoYXJlZC1tZXJjaGFudEBnZXRicmFpbnRyZWUuY29tIiwic2NvcGVzIjoiYXV0aG9yaXphdGlvbnM6YnJhaW50cmVlIHVzZXIiLCJyZWRpcmVjdFVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tL2NvaW5iYXNlL29hdXRoL3JlZGlyZWN0LWxhbmRpbmcuaHRtbCIsImVudmlyb25tZW50Ijoic2hhcmVkX3NhbmRib3gifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==", error: nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/client_token"
        client.getPath(path, parameters: [:],
            success: {(responseObject: AnyObject!) -> Void in
                
                let dict: NSDictionary = responseObject as! NSDictionary
                completionBlock(clientToken: (dict["client_token"] as! String), error: nil)
            },
            failure: {(error: (NSError)!) -> Void in
                completionBlock(clientToken: nil, error: error)
            }
        )
    }
    
    func retrievePaymentMethods(clientToken: String, completion: PaymentMethodsCompletionBlock) {
    
        guard let customerID = customerID else {
            
            completion(paymentMethods: self.sources, error: nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        if let apiClient: BTAPIClient = BTAPIClient(authorization: clientToken) {
            apiClient.fetchPaymentMethodNonces(true,
                                               completion: {(paymentMethodNonces: [BTPaymentMethodNonce]?, error: NSError?) -> Void in
                completion(paymentMethods: paymentMethodNonces, error: error)
            })
        }
    }
    
    func selectDefaultCustomerSource(paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock) {
        
        guard let customerID = customerID else {
            
            for method in self.sources {
                if method.isDefault {

                    let oldIdx = self.sources.indexOf(method)
                    let newIdx = self.sources.indexOf(paymentMethod)
                    
                    let oldMethod = BTPaymentMethodNonce(nonce: method.nonce,
                                                         localizedDescription: method.localizedDescription,
                                                         type: method.type,
                                                         isDefault: false)
                    
                    let newMethod = BTPaymentMethodNonce(nonce: paymentMethod.nonce,
                                                    localizedDescription: paymentMethod.localizedDescription,
                                                    type: paymentMethod.type,
                                                    isDefault: true)
                    

                    self.sources.removeAtIndex(oldIdx!)
                    self.sources.removeAtIndex(newIdx!)

                    self.sources.append(newMethod!)
                    self.sources.append(oldMethod!)

                    break;
                }
            }
            
            self.defaultSource = paymentMethod
            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/select_source"
        
        let params = [
            "customer": customerID,
            "source": paymentMethod.nonce,
            ]
        
        let client: BAAClient = BAAClient.sharedClient()
        client.postPath(path, parameters: params,
                        
                        success: {(responseObject: (AnyObject)!) -> Void in
                            completion(nil)
            },
                        
                        failure: {(error: (NSError)!) -> Void in
                            completion(error)
            }
        )
    }
    
    func attachSourceToCustomer(paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock) {
        
        guard let customerID = customerID else {
            
            if (self.sources.count == 0) {
                self.defaultSource = paymentMethod
            }
            
            self.sources.append(paymentMethod)
            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/sources"
        
        let params = [
            "customer": customerID,
            "source":   paymentMethod.nonce,
            ]
        
        let client: BAAClient = BAAClient.sharedClient()
        client.postPath(path, parameters: params,
                        
                        success: {(responseObject: (AnyObject)!) -> Void in
                            completion(nil)
            },
                        
                        failure: {(error: (NSError)!) -> Void in
                            completion(error)
            }
        )
    }
    
    func updateSourceForCustomer(paymentMethod: BTPaymentMethodNonce,
                                oldPaymentMethod: BTPaymentMethodNonce,
                                completion: BTErrorBlock) {
        
        guard let customerID = customerID else {
            
            let idx = self.sources.indexOf(oldPaymentMethod)
            if (idx != nil) {
                
                self.sources.removeAtIndex(idx!)
                self.sources.append(paymentMethod)
                
                // check if we removed the default card
                if (self.defaultSource == paymentMethod) {
                    self.defaultSource = paymentMethod
                }
            }

            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/sources"
        
        let params = [
            "customer": customerID,
            "source":   paymentMethod.nonce,
            ]
        
        let client: BAAClient = BAAClient.sharedClient()
        client.postPath(path, parameters: params,
                        
                        success: {(responseObject: (AnyObject)!) -> Void in
                            completion(nil)
            },
                        
                        failure: {(error: (NSError)!) -> Void in
                            completion(error)
            }
        )
    }
    
    func deleteSourceFromCustomer(paymentMethod: BTPaymentMethodNonce,
                                        completion: BTErrorBlock) {

        guard let customerID = customerID else {
            
            
            let idx = self.sources.indexOf(paymentMethod)
            if (idx != nil) {
                
                self.sources.removeAtIndex(idx!)
                
                // check if we removed the default card
                if (self.defaultSource == paymentMethod) {
                    self.defaultSource = self.sources.last
                }
            }

            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/sources"
        
        let params = [
            "customer": customerID,
            "source":   paymentMethod.nonce,
            ]
        
        let client: BAAClient = BAAClient.sharedClient()
        client.deletePath(path, parameters: params,
                          
                          success: {(responseObject: (AnyObject)!) -> Void in
                            completion(nil)
            },
                          
                          failure: {(error: (NSError)!) -> Void in
                            completion(error)
            }
        )
    }
}
