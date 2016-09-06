//
//  CardHolderNameTextField.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/30/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

/// A text field which can be used to enter CVCs and provides validation of the same.
public class CardHolderNameTextField: DetailInputTextField {
    
    override var expectedInputLength: Int {
        return 50
    }
    
    /**
     Checks the validity of the entered card validation code.
     
     - precondition: The property `cardType` of `self` must match the card type for which a CVC should be validated.
     
     - returns: True, if the card validation code is valid.
     */
    override func isInputValid(input: String, partiallyValid: Bool) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.textFieldReturnCallback?()
        
        return false // We do not want UITextField to insert line-breaks.
    }
}
