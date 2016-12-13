//
//  PostalCodeTextField.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/30/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

/// A text field which can be used to enter CVCs and provides validation of the same.
open class PostalCodeTextField: DetailInputTextField {
    
    internal override var expectedInputLength: Int {
        return 5
    }
    
    /**
     Checks the validity of the entered card validation code.
     
     - precondition: The property `cardType` of `self` must match the card type for which a CVC should be validated.
     
     - returns: True, if the card validation code is valid.
     */
    internal override func isInputValid(_ input: String, partiallyValid: Bool) -> Bool {
        
        return true
    }
}
