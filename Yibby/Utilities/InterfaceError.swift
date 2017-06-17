//
//  InterfaceError.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/9/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import Foundation

public class InterfaceError {
 
    static let errorDomain = "com.yibbyapp.error"

    // error codes
    public enum Error: Int {
        case paymentsSetupFailure = 1
        case pushNotificationsSetupFailure = 2
    }
    
    public static func createNSError(_ error: InterfaceError.Error) -> NSError {
        return NSError(domain: InterfaceError.errorDomain, code: error.rawValue, userInfo:nil)
    }
}
