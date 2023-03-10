//
//  CardFieldsView+PrefillInformation.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/5/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

public extension CardFieldsView {
    
    /**
     Fills all form fields of this card text field with the information provided and moves to card detail, if the provided card number was valid.
     
     - parameter cardNumber: The card number which should be shown in the number input field.
     - parameter month:      The month that should be shown in the month input field.
     - parameter year:       The year that should be shown in the year input field.
     - parameter cvc:        The CVC that should be shown in the CVC input field.
     */
    public func prefillCardInformation(cardNumber: String?, month: Int?, year: Int?, cvc: String?) {
        if let year = year {
            var trimmedYear = year
            if year > 100 {
                trimmedYear = year % 100
            }
            
            yearTextField?.prefill(String(format: "%02i", arguments: [trimmedYear]))
        }
        
        if let month = month {
            monthTextField?.prefill(String(format: "%02i", arguments: [month]))
        }
        
        if let cardNumber = cardNumber, let numberInputTextField = numberInputTextField {
            numberInputTextField.prefill(cardNumber)
            
            // With a new card number comes a new card type - pass this card type to `cvcTextField`
            cvcTextField?.cardType = cardType
        }
        
        if let cvc = cvc {
            cvcTextField?.prefill(cvc)
        }
        
//        NSOperationQueue().addOperationWithBlock({
//            NSThread.sleepForTimeInterval(0.5)
//            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] _ in
//                self?.moveCardNumberOutAnimated()
//                })
//        })
        
        notifyDelegate()
    }
}
