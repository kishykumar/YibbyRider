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

public typealias RideArrayResultBlock = (success: NSArray?, error: NSError?) -> Void
public typealias RideResultBlock = (success: AnyObject?, error: NSError?) -> Void

public struct RideService {
    
    public init() {
        
    }

    public func getRidesCount (completionBlock: RideResultBlock) {

    }
    
    public func getRideByFileId (fileId: String, completionBlock: RideResultBlock) {
        
        let client: BAAClient = BAAClient.sharedClient()
        
        client.loadFileDetails(fileId, completion: {(success, error) -> Void in
            
            if (error == nil) {
                completionBlock(success: (success as? BAAFile), error: nil)
            }
            else {
                completionBlock(success: nil, error: error)
            }
        })
    }
    
    public func getRides () {
        
    }
}
