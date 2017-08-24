//
//  YBValidPaymentFieldRule.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/14/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import Foundation
import SwiftValidator

/**
 `RequiredRule` is a subclass of Rule that defines how a required field is validated.
 */
open class YBValidPaymentFieldRule: Rule {
    
    public /**
     Validates text of a field.
     
     - parameter value: String of text to be validated.
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    func validate(_ value: String) -> Bool {
        return true
    }

    
    // Validation Callback
    private var validationCallback: () -> Bool
    
    // String that holds error message.
    private var message : String
    
    /**
     Initializes `RequiredRule` object with error message. Used to validate a field that requires text.
     
     - parameter message: String of error message.
     - returns: An initialized `RequiredRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(cbk: @escaping () -> Bool, message : String = "This field is invalid"){
        self.validationCallback = cbk
        self.message = message
    }
    
    /**
     Validates a field.
     
     - parameter: None
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    open func validate() -> Bool {
        return self.validationCallback()
    }
    
    /**
     Used to display error message when validation fails.
     
     - returns: String of error message.
     */
    open func errorMessage() -> String {
        return message
    }
}
