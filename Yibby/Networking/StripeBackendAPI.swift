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
    func deleteSourceFromCustomer(source: STPSource, completion: STPErrorBlock)
    func updateSourceForCustomer(source: STPSource, oldSource: STPSource, completion: STPErrorBlock)
}

class StripeBackendAPI: NSObject, StripeBackendAPIAdapter {
    
    // MARK: - Properties 
    
    let customerID: String?
    var defaultSource: STPCard? = nil
    var sources: [STPCard] = []
    
    static var sharedClient = StripeBackendAPI(customerID: nil)
    static func sharedInit(customerID: String?) {
        sharedClient = StripeBackendAPI(customerID: customerID)
    }
    
    init(customerID: String?) {
        self.customerID = customerID
        super.init()
        self.setupFakeCards()
    }

    func setupFakeCards () {
    
        guard let _ = customerID else {
            let card1 = STPCard(ID: "card_185iQx4JYtv6MPZKfcuXwkOx", brand: STPCardBrand.Visa,
            last4: "4242", expMonth:2, expYear: 2018, funding: STPCardFundingType.Credit)
            
            let card2 = STPCard(ID: "card_185iQx4JYtv6MPZKfcuXwkOy", brand: STPCardBrand.MasterCard,
            last4: "5658", expMonth:3, expYear: 2019, funding: STPCardFundingType.Credit)
            
            let card3 = STPCard(ID: "card_185iQx4JYtv6MPZKfcuXwkOz", brand: STPCardBrand.JCB,
            last4: "3632", expMonth:4, expYear: 2020, funding: STPCardFundingType.Credit)
            
            let card4 = STPCard(ID: "card_185iQx4JYtv6MPZKfcuXwkOw", brand: STPCardBrand.Visa,
            last4: "9868", expMonth:5, expYear: 2021, funding: STPCardFundingType.Credit)
            
            self.sources.append(card1)
            self.sources.append(card2)
            self.sources.append(card3)
            self.sources.append(card4)
            self.defaultSource = card1
            return;
        }
    }
    
    func completeCharge(result: STPPaymentResult, amount: Int, completion: STPErrorBlock) {
        
        guard let customerID = customerID else {
            completion(nil)
            DDLogError("Customer ID nil for Stripe Client.")
            return
        }
        
        let path = "charge"

        let params: [String: AnyObject] = [
            "source": result.source.stripeID,
            "amount": amount,
            "customer": customerID
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
    
    @objc func retrieveCustomer(completion: STPCustomerCompletionBlock) {
        
        let client: BAAClient = BAAClient.sharedClient()
        guard let baseURL = client.baseURL, customerID = customerID else {
            
            let customer = STPCustomer(stripeID: "cus_test", defaultSource: self.defaultSource, sources: self.sources)
            completion(customer, nil)
            
            DDLogError("Customer ID nil for Stripe Client.")
            return;
        }
        
        let path = "/customers/\(customerID)"
        let url = baseURL.URLByAppendingPathComponent(path)
        
        Alamofire.request(.GET, url!, parameters: [:])
            .response { request, response, data, error in
                let deserializer = STPCustomerDeserializer(data: data, urlResponse: response, error: error)
                if let error = deserializer.error {
                    completion(nil, error)
                    return
                } else if let customer = deserializer.customer {
                    completion(customer, nil)
                }
            }
    }
    
    @objc func selectDefaultCustomerSource(source: STPSource, completion: STPErrorBlock) {
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
    
    @objc func attachSourceToCustomer(source: STPSource, completion: STPErrorBlock) {
        
        guard let customerID = customerID else {
            
            if let token = source as? STPToken, card = token.card {
                
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
    
    @objc func updateSourceForCustomer(source: STPSource, oldSource: STPSource, completion: STPErrorBlock) {
        
        guard let customerID = customerID else {
            
            if let card = oldSource as? STPCard, token = source as? STPToken, newCard = token.card {
                
                let idx = self.sources.indexOf(card)
                if (idx != nil) {
                    
                    self.sources.removeAtIndex(idx!)
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
    
    @objc func deleteSourceFromCustomer(source: STPSource, completion: STPErrorBlock) {
        
        guard let customerID = customerID else {
            
            if let card = source as? STPCard {

                let idx = self.sources.indexOf(card)
                if (idx != nil) {

                    self.sources.removeAtIndex(idx!)

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
