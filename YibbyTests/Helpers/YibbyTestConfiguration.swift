//
//  YibbyTestConfiguration.swift
//  Yibby
//
//  Created by Kishy Kumar on 10/7/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

@testable
import Yibby
import Quick
import Nimble_Snapshots

// Add in custom configuration
class YibbyTestConfiguration: QuickConfiguration {
    override class func configure(config: Configuration) {
        
        config.beforeSuite {
            
        }
        
        config.beforeEach {
            
        }
        config.afterEach {
            
        }
        
        config.afterSuite {
            
        }
    }
}

//func stubbedJSONData(file: String, _ propertyName: String) -> ([String:AnyObject]) {
//    let loadedData:NSData = stubbedData(file)
//    let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(loadedData, options: [])
//    
//    var castJSON = json as! [String: AnyObject]
//    let parsedProperty = castJSON[propertyName] as! [String:AnyObject]
//    if let linkedJSON = castJSON["linked"] as? [String:[[String:AnyObject]]] {
//        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
//    }
//    
//    return parsedProperty
//}
//
//func stubbedJSONDataArray(file: String, _ propertyName: String) -> [[String:AnyObject]] {
//    let loadedData:NSData = stubbedData(file)
//    let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(loadedData, options: [])
//    
//    var castJSON:[String:AnyObject] = json as! [String: AnyObject]
//    let parsedProperty = castJSON[propertyName] as! [[String:AnyObject]]
//    if let linkedJSON = castJSON["linked"] as? [String:[[String:AnyObject]]] {
//        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
//    }
//    
//    return parsedProperty
//}
//
//func supressRequestsTo(domain: String) {
//    OHHTTPStubs.stubRequestsPassingTest({$0.URL!.host == domain}) { _ in
//        return OHHTTPStubsResponse(data: NSData(),
//                                   statusCode: 200, headers: ["Content-Type":"image/gif"])
//    }
//}
