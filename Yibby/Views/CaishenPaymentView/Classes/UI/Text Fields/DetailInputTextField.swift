//
//  DetailInputTextField.swift
//  Caishen
//
//  Created by Daniel Vancura on 3/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A text field subclass that validates any input for card detail before changing the text attribute.
 You can subclass `DetailInputTextField` and override `isInputValid` to specify the validation routine.
 The default implementation accepts any input.
 */
open class DetailInputTextField: StylizedTextField {
    
    open var cardInfoTextFieldDelegate: CardInfoTextFieldDelegate?
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            
            // NOTE: The following line has been commented out because it messes up
//            textField.text = UITextField.emptyTextFieldCharacter
        }
    }
    
    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: (textField.text ?? "")).replacingCharacters(in: range, with: string).replacingOccurrences(of: UITextField.emptyTextFieldCharacter, with: "")
        
        let deletingLastCharacter = !(textField.text ?? "").isEmpty && textField.text != UITextField.emptyTextFieldCharacter && newText.isEmpty
        if deletingLastCharacter {
//            textField.text = UITextField.emptyTextFieldCharacter
            textField.text = ""
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: newText)
            return false
        }
        
        let autoCompletedNewText = autocompleteText(newText)
        
        let (currentTextFieldText, overflowTextFieldText) = splitText(autoCompletedNewText)
        
        if isInputValid(currentTextFieldText, partiallyValid: true) {
            textField.text = currentTextFieldText
            if isInputValid(currentTextFieldText, partiallyValid: false) {
                cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: currentTextFieldText)
            } else {
                cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: currentTextFieldText)
            }
        }
        
        if !overflowTextFieldText.characters.isEmpty {
            cardInfoTextFieldDelegate?.textField(self, didEnterOverflowInfo: overflowTextFieldText)
        }
        
        return false
    }
    
    open func prefillInformation(_ info: String) {
        if isInputValid(info, partiallyValid: false) {
            text = info
            cardInfoTextFieldDelegate?.textField(self, didEnterValidInfo: info)
        } else if isInputValid(info, partiallyValid: true) {
            text = info
            cardInfoTextFieldDelegate?.textField(self, didEnterPartiallyValidInfo: info)
        }
    }
    
    fileprivate func splitText(_ text: String) -> (currentText: String, overflowText: String) {
        let hasOverflow = text.characters.count > expectedInputLength
        let index = (hasOverflow) ?
            text.characters.index(text.startIndex, offsetBy: expectedInputLength) :
            text.characters.index(text.startIndex, offsetBy: text.characters.count)
        return (text.substring(to: index), text.substring(from: index))
    }
}

extension DetailInputTextField: AutoCompletingTextField {

    func autocompleteText(_ text: String) -> String {
        return text
    }
}

extension DetailInputTextField: TextFieldValidation {
    /**
     Default number of expected digits for MonthInputTextField and YearInputTextField
     */
    var expectedInputLength: Int {
        return 2
    }

    func isInputValid(_ input: String, partiallyValid: Bool) -> Bool {
        return true
    }
}
