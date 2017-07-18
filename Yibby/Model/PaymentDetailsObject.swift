//
//  PaymentDetailsObject.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 08/04/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import ObjectMapper


class PaymentDetailsObject 
{

    var expirationMonth = ""
    var expirationYear = ""
    var isDefault = ""
    var last4 = ""
    var postalCode = ""
    var token = ""
    var type = ""
    var isCurrent:Bool?
    
    init() {
        
    }
    
  /*  required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map, responseArr: NSArray) -> NSMutableArray {
        print(responseArr)
        
        let dataArray = NSMutableArray()
        
        for index in 0..<responseArr.count{
            let currentDict = responseArr[index] as! NSDictionary
            
            let classObject = PaymentDetailsObject()
            
            classObject.expirationMonth  <- map["expirationMonth"]
            classObject.isDefault  <- map["isDefault"]
            classObject.postalCode  <- map["postalCode"]
            classObject.last4  <- map["last4"]
            classObject.postalCode  <- map["postalCode"]
            classObject.token  <- map["token"]
            classObject.type  <- map["type"]
            
            
            
            dataArray.add(classObject)
            
        }
        
        return dataArray
    }
*/
//    func savePaymentCardDetails(responseArr: NSArray) -> NSMutableArray{
//        
//        print(responseArr)
//        
//        let dataArray = NSMutableArray()
//        
//        for index in 0..<responseArr.count{
//            let currentDict = responseArr[index] as! NSDictionary
//            
//            let classObject = PaymentDetailsObject()
//            
//            classObject.expirationMonth = String(describing: currentDict["expirationMonth"] as! NSObject)
//            classObject.expirationYear = String(describing: currentDict["expirationYear"] as! NSObject)
//            classObject.isDefault = String(describing: currentDict["isDefault"] as! NSObject)
//            classObject.last4 = String(describing: currentDict["last4"] as! NSObject)
//            classObject.postalCode = String(describing: currentDict["postalCode"] as! NSObject)
//            classObject.token = String(describing: currentDict["token"] as! NSObject)
//            classObject.type = String(describing: currentDict["type"] as! NSObject)
//            classObject.isCurrent = currentDict["isDefault"] as? Bool
//            dataArray.add(classObject)
//            if classObject.isCurrent! {
//                BraintreePaymentService.sharedInstance().currentPaymentMethod = classObject
//            }
//        }
//        return dataArray
//        
//    }
    
    
   
}
