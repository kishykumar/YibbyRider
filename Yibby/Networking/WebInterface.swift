//
//  WebInterface.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/18/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import GoogleMaps
import BaasBoxSDK
import CocoaLumberjack

open class WebInterface {
    
    static let BAASBOX_AUTHENTICATION_ERROR = -22222
    static let BAASBOX_INTERNAL_ERROR = -22223
    
    static func makeWebRequestAndHandleError (_ vc: UIViewController, webRequest:(_ errorBlock: @escaping(BAAObjectResultBlock)) -> Void) {
        
        webRequest({ (success, error) -> Void in
            
            if let myNSError = error as NSError? {
                switch (myNSError.code) {
                case WebInterface.BAASBOX_AUTHENTICATION_ERROR:
                    
                    // check for authentication error and redirect the user to Login page
                    
                    DDLogVerbose("Error in webRequest1: \(String(describing: error))")
                    let signupStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.SignUp,
                        bundle: nil)
                    
                    vc.present(signupStoryboard.instantiateInitialViewController()!, animated: false, completion: nil)
                    break
                    
                case WebInterface.BAASBOX_INTERNAL_ERROR:
                    DDLogVerbose("Internal Server Error in webRequest2: \(String(describing: error))")
                    AlertUtil.displayAlert(myNSError.localizedDescription, message: "Please check back again in some time.")
                    break
                    
                default:
                    DDLogVerbose("Error in webRequest3: \(String(describing: error))")
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })
    }
}
