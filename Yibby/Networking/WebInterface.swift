//
//  WebInterface.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/18/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import SVProgressHUD
import BaasBoxSDK
import CocoaLumberjack

open class WebInterface {
    
    static let BAASBOX_AUTHENTICATION_ERROR = -22222

    static func makeWebRequestAndHandleError (_ vc: UIViewController, webRequest:(_ errorBlock: @escaping(BAAObjectResultBlock)) -> Void) {
        
        webRequest({ (success, error) -> Void in
//            if (error.domain == BaasBox.errorDomain() && error.code ==
            if ((error as! NSError).code ==
                WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                // check for authentication error and redirect the user to Login page
                
                DDLogVerbose("Error in webRequest1: \(error)")
                let signupStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.SignUp,
                    bundle: nil)
                
                vc.present(signupStoryboard.instantiateInitialViewController()!, animated: false, completion: nil)
            }
            else {
                DDLogVerbose("Error in webRequest2: \(error)")
                AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
            }
        })
    }
}
