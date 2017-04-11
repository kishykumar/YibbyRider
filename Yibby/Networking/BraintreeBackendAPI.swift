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

public typealias MakeTransactionCompletionBlock = (_ transactionId: String, _ error: NSError?) -> Void
public typealias TokenFetchCompletionBlock = (_ clientToken: String?, _ error: NSError?) -> Void
public typealias PaymentMethodsCompletionBlock = (_ paymentMethods: [BTPaymentMethodNonce]?, _ error: NSError?) -> Void
public typealias BTErrorBlock = (NSError?) -> Void

public protocol BraintreeBackendAPIAdapter {
    
    // complete charge equivalent to Stripe
    func makeTransaction(_ paymentMethodNonce: String, completion completionBlock: MakeTransactionCompletionBlock)
    
    func fetchClientToken(_ completionBlock: @escaping TokenFetchCompletionBlock)
    
    func retrievePaymentMethods(_ clientToken: String, completion: @escaping PaymentMethodsCompletionBlock)
    
    func deleteSourceFromCustomer(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock)
    
    func updateSourceForCustomer(_ paymentMethod: BTPaymentMethodNonce,
                                 oldPaymentMethod: String,
                                 completion: @escaping BTErrorBlock)
    
    func attachSourceToCustomer(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock)
    
    func selectDefaultCustomerSource(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock)
}

class BraintreeBackendAPI: NSObject, BraintreeBackendAPIAdapter {
    
    // MARK: - Properties
    
    let customerID: String?
    
    // used for fake cards
    var defaultSource: BTPaymentMethodNonce? = nil
    var sources: [BTPaymentMethodNonce] = []
    
    static var sharedClient = BraintreeBackendAPI(customerID: nil)
    
    static func sharedInit(_ customerID: String?) {
        sharedClient = BraintreeBackendAPI(customerID: customerID)
    }
    
    init(customerID: String?) {
        self.customerID = customerID
        super.init()
        self.setupFakeCards()
    }
    
    func setupFakeCards () {
        
        guard let _ = customerID else {
            let card1 = BTPaymentMethodNonce(nonce: "123x", localizedDescription: "*4242", type: "Visa", isDefault: false)
            let card2 = BTPaymentMethodNonce(nonce: "123y", localizedDescription: "*4244", type: "Amex", isDefault: false)
            let card3 = BTPaymentMethodNonce(nonce: "123z", localizedDescription: "*4246", type: "MasterCard", isDefault: true)
            let card4 = BTPaymentMethodNonce(nonce: "123w", localizedDescription: "*4248", type: "Visa", isDefault: false)
            
            self.sources.append(card1!)
            self.sources.append(card2!)
            self.sources.append(card3!)
            self.sources.append(card4!)
            
            self.defaultSource = card1
            
            return;
        }
    }
    
    func makeTransaction(_ paymentMethodNonce: String, completion completionBlock: MakeTransactionCompletionBlock) {
    
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
        guard let customerID = customerID else {
            completionBlock("eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI2YmU3MGIzY2IzNTcwZDY3MzU0YjdjMmIyMGQyNjllOGM5ODkwNTE5MGYxZGRlN2ZkN2Q5NDIzY2U3MmQ0ZTAwfGNyZWF0ZWRfYXQ9MjAxNi0wOC0wN1QwOTowNzowOC41NDgyMzUxNjErMDAwMFx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tL2RjcHNweTJicndkanIzcW4ifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6InN0Y2gybmZkZndzenl0dzUiLCJjdXJyZW5jeUlzb0NvZGUiOiJVU0QifSwiY29pbmJhc2VFbmFibGVkIjp0cnVlLCJjb2luYmFzZSI6eyJjbGllbnRJZCI6IjdlYTc5N2EyYmY2ZjM2YmY5NjFmYTc5ZTk0YTQwNjBlODM2ZTc1NmEyYzM1ZGU4MjlmYzM0NzI3YTJhYmYxODEiLCJtZXJjaGFudEFjY291bnQiOiJjb2luYmFzZS1zYW5kYm94LXNoYXJlZC1tZXJjaGFudEBnZXRicmFpbnRyZWUuY29tIiwic2NvcGVzIjoiYXV0aG9yaXphdGlvbnM6YnJhaW50cmVlIHVzZXIiLCJyZWRpcmVjdFVybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tL2NvaW5iYXNlL29hdXRoL3JlZGlyZWN0LWxhbmRpbmcuaHRtbCIsImVudmlyb25tZW50Ijoic2hhcmVkX3NhbmRib3gifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==", nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/client_token"
        client.getPath(path, parameters: [:],
            success: {(responseObject: (Any?)) -> Void in
                
                let dict: NSDictionary = responseObject as! NSDictionary
                completionBlock((dict["client_token"] as! String), nil)
            },
            failure: {(error: (Error?)) -> Void in
                completionBlock(nil, error as NSError?)
            }
        )
    }
    
    func retrievePaymentMethods(_ clientToken: String, completion: @escaping PaymentMethodsCompletionBlock) {
    
        guard let customerID = customerID else {
            
            completion(self.sources, nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        if let apiClient: BTAPIClient = BTAPIClient(authorization: clientToken) {
            apiClient.fetchPaymentMethodNonces(true,
                                               completion: {(paymentMethodNonces: [BTPaymentMethodNonce]?, error: NSError?) -> Void in
                completion(paymentMethodNonces, error)
            } as! ([BTPaymentMethodNonce]?, Error?) -> Void)
        }
    }
    
    func selectDefaultCustomerSource(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock) {
        
        guard let customerID = customerID else {
            
            for method in self.sources {
                if method.isDefault {

                    let oldIdx = self.sources.index(of: method)
                    let newIdx = self.sources.index(of: paymentMethod)
                    
                    let oldMethod = BTPaymentMethodNonce(nonce: method.nonce,
                                                         localizedDescription: method.localizedDescription,
                                                         type: method.type,
                                                         isDefault: false)
                    
                    let newMethod = BTPaymentMethodNonce(nonce: paymentMethod.nonce,
                                                    localizedDescription: paymentMethod.localizedDescription,
                                                    type: paymentMethod.type,
                                                    isDefault: true)
                    

                    self.sources.remove(at: oldIdx!)
                    self.sources.remove(at: newIdx!)

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
        
        let client: BAAClient = BAAClient.shared()
        client.postPath(path, parameters: params,
                        
                        success: {(responseObject: (Any?)) -> Void in
                            completion(nil)
            },
                        
                        failure: {(error: (Error?)) -> Void in
                            completion(error as NSError?)
            }
        )
    }
    
    func attachSourceToCustomer(_ paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock) {
        
       /* guard let customerID = customerID else {
            
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
        
        let client: BAAClient = BAAClient.shared()
        client.postPath(path, parameters: params,
                        
                        success: {(responseObject: (Any?)) -> Void in
                            completion(nil)
            },
                        
                        failure: {(error: (Error?)) -> Void in
                            completion(error as NSError?)
            }
        )*/
        let client: BAAClient = BAAClient.shared()
        client.addPaymentMethod(BAASBOX_RIDER_STRING, paymentMethodNonce: paymentMethod.nonce, completion: {(success, error) -> Void in
            
            print(success as Any)
            
            completion(error as NSError?)
            
        })
    }
    
    func updateSourceForCustomer(_ paymentMethod: BTPaymentMethodNonce,
                                oldPaymentMethod: String,
                                completion: @escaping BTErrorBlock) {
        
   /*     guard let customerID = customerID else {
            
            let idx = self.sources.index(of: oldPaymentMethod)
            if (idx != nil) {
                
                self.sources.remove(at: idx!)
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
        
        let client: BAAClient = BAAClient.shared()
        client.postPath(path, parameters: params,
                        
                success: {(responseObject: (Any?)) -> Void in
                    completion(nil)
            },
                        
                failure: {(error: (Error?)) -> Void in
                    completion(error as NSError?)
            }
        )*/
        let client: BAAClient = BAAClient.shared()
        client.updatePaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: oldPaymentMethod, paymentMethodNonce: paymentMethod.nonce, completion: {(success, error) -> Void in
            
            print(success as Any)
            
            completion(error as NSError?)
            
        })
       
    }
    
    func deleteSourceFromCustomer(_ paymentMethod: BTPaymentMethodNonce,
                                        completion: @escaping BTErrorBlock) {

        guard let customerID = customerID else {
            
            
            let idx = self.sources.index(of: paymentMethod)
            if (idx != nil) {
                
                self.sources.remove(at: idx!)
                
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
        
        let client: BAAClient = BAAClient.shared()
        client.deletePath(path, parameters: params,
                          
                          success: {(responseObject: (Any?)) -> Void in
                            completion(nil)
            },
                          
                          failure: {(error: (Error?)) -> Void in
                            completion(error as NSError?)
            }
        )
    }
}
