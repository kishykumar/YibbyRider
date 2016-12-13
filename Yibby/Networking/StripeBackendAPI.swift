//
//  BackendAPIAdapter.swift
//  Stripe iOS Example (Simple)
//
//  Created by Ben Guo on 4/15/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import Foundation
import Stripe
import BaasBoxSDK
import CocoaLumberjack
import Alamofire

public protocol StripeBackendAPIAdapter : STPBackendAPIAdapter {
    func deleteSourceFromCustomer(_ source: STPSource, completion: @escaping STPErrorBlock)
    func updateSourceForCustomer(_ source: STPSource, oldSource: STPSource, completion: @escaping STPErrorBlock)
}

class StripeBackendAPI: NSObject, StripeBackendAPIAdapter {
    
    // MARK: - Properties 
    
    let customerID: String?
    var defaultSource: STPCard? = nil
    var sources: [STPCard] = []
    
    static var sharedClient = StripeBackendAPI(customerID: nil)
    static func sharedInit(_ customerID: String?) {
        sharedClient = StripeBackendAPI(customerID: customerID)
    }
    
    init(customerID: String?) {
        self.customerID = customerID
        super.init()
        self.setupFakeCards()
    }

    func setupFakeCards () {
    
        guard let _ = customerID else {
            let card1 = STPCard(id: "card_185iQx4JYtv6MPZKfcuXwkOx", brand: STPCardBrand.visa,
            last4: "4242", expMonth:2, expYear: 2018, funding: STPCardFundingType.credit)
            
            let card2 = STPCard(id: "card_185iQx4JYtv6MPZKfcuXwkOy", brand: STPCardBrand.masterCard,
            last4: "5658", expMonth:3, expYear: 2019, funding: STPCardFundingType.credit)
            
            let card3 = STPCard(id: "card_185iQx4JYtv6MPZKfcuXwkOz", brand: STPCardBrand.JCB,
            last4: "3632", expMonth:4, expYear: 2020, funding: STPCardFundingType.credit)
            
            let card4 = STPCard(id: "card_185iQx4JYtv6MPZKfcuXwkOw", brand: STPCardBrand.visa,
            last4: "9868", expMonth:5, expYear: 2021, funding: STPCardFundingType.credit)
            
            self.sources.append(card1)
            self.sources.append(card2)
            self.sources.append(card3)
            self.sources.append(card4)
            self.defaultSource = card1
            return;
        }
    }
    
    func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPErrorBlock) {
        
        guard let customerID = customerID else {
            completion(nil)
            DDLogError("Customer ID nil for Stripe Client.")
            return
        }
        
        let path = "charge"

        let params: [String: AnyObject] = [
            "source": result.source.stripeID as AnyObject,
            "amount": amount as AnyObject,
            "customer": customerID as AnyObject
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
    
    @objc func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        
        let client: BAAClient = BAAClient.shared()
        guard let baseURL = client.baseURL, let customerID = customerID else {
            
            let customer = STPCustomer(stripeID: "cus_test", defaultSource: self.defaultSource, sources: self.sources)
            completion(customer, nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)"
        let url = baseURL.appendingPathComponent(path)
        
        Alamofire.request(url)
            .response { response in
                let deserializer = STPCustomerDeserializer(data: response.data,
                                                           urlResponse: response.response,
                                                           error: response.error)
                if let error = deserializer.error {
                    completion(nil, error)
                    return
                } else if let customer = deserializer.customer {
                    completion(customer, nil)
                }
            }
    }
    
    @objc func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        guard let customerID = customerID else {

            if let card = source as? STPCard {
                self.defaultSource = card
            }
            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/select_source"
        
        let params = [
            "customer": customerID,
            "source": source.stripeID,
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
    
    @objc func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        
        guard let customerID = customerID else {
            
            if let token = source as? STPToken, let card = token.card {
                
                if (self.sources.count == 0) {
                    self.defaultSource = card
                }
                
                self.sources.append(card)
            }
            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/sources"
        
        let params = [
            "customer": customerID,
            "source":   source.stripeID,
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
    
    public func updateSourceForCustomer(_ source: STPSource, oldSource: STPSource, completion: @escaping STPErrorBlock) {
        
        guard let customerID = customerID else {
            
            if let card = oldSource as? STPCard, let token = source as? STPToken, let newCard = token.card {
                
                let idx = self.sources.index(of: card)
                if (idx != nil) {
                    
                    self.sources.remove(at: idx!)
                    self.sources.append(newCard)
                    
                    // check if we removed the default card
                    if (self.defaultSource == card) {
                        self.defaultSource = newCard
                    }
                }
            }
            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/sources"
        
        let params = [
            "customer": customerID,
            "source":   source.stripeID,
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
      
    public func deleteSourceFromCustomer(_ source: STPSource, completion: @escaping STPErrorBlock) {
        
        guard let customerID = customerID else {
            
            if let card = source as? STPCard {

                let idx = self.sources.index(of: card)
                if (idx != nil) {

                    self.sources.remove(at: idx!)

                    // check if we removed the default card
                    if (self.defaultSource == card) {
                        self.defaultSource = self.sources.last
                    }
                }
            }
            completion(nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)/sources"
        
        let params = [
            "customer": customerID,
            "source":   source.stripeID,
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
