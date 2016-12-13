//
//  RideService.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/4/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

// TODO: Remove the BAAFile with BAARide

import BaasBoxSDK
import CocoaLumberjack

public typealias RideArrayResultBlock = (_ success: NSArray?, _ error: NSError?) -> Void
public typealias RideResultBlock = (_ success: AnyObject?, _ error: NSError?) -> Void

public struct RideService {
    
    public init() {
        
    }

    public func getRidesCount (_ completionBlock: RideResultBlock) {

    }
    
    public func getRideByFileId (_ fileId: String, completionBlock: @escaping RideResultBlock) {
        
        let client: BAAClient = BAAClient.shared()
        
        client.loadFileDetails(fileId, completion: {(success, error) -> Void in
            
            if (error == nil) {
                completionBlock((success as? BAAFile), nil)
            }
            else {
                completionBlock(nil, error as NSError?)
            }
        })
    }
    
    public func getRides () {
        
    }
}
