//
//  TextfieldValidations.swift
//  Yibby
//
//  Created by Rubi Kumari on 16/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class TextfieldValidations {
    
    func validateEmptyTextfieldsOnly(superView : AnyObject) -> (boolValue: Bool,textPlaceHolder: String) {
        
        // print(superView.subviews)
        
        for object in superView.subviews {
            
            if let textfield = object as? UITextField {
                
                if textfield.text == "" {
                    return (false,"Please Enter \(textfield.placeholder!)")
                }
                
                if textfield.placeholder == "Email address" {
                    if !(isValidEmail(testStr: textfield.text!)) {
                        return (false,"Enter valid email")
                    }
                    
                }
                if textfield.placeholder == "Password" {
                    if !(isValidPassword(testStr: textfield.text!)){
                        return (false,"Password must be more than six characters with minimum one numeric and special character.")
                    }
                    
                }
                if textfield.placeholder == "Phone No" {
                    if !(isValidPhoneNo(testStr: textfield.text!)){
                        return (false,"Enter valid telephone no")
                    }
                    
                }
            }
        }
        return (true,"")
    }
    
    func makeTextfieldsEmpty(superView : AnyObject){
        
        for object in superView.subviews {
            
            if let textfield = object as? UITextField {
                if textfield.text != "" {
                    textfield.text = ""
                }
            }
        }
    }
  
}
