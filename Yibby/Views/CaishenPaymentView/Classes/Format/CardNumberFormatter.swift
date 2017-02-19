//
//  CardNumberFormatter.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/4/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 A `CardNumberFormatter` provides the formatting of card numbers based on their card type.
 */
public final class CardNumberFormatter {

    /// The separator which is used to separate different groups of a card number.
    public let separator: String
    
    /// The card type register which is used to access accepted card types. Formatting will only take place for card numbers whose card type can be found in this property.
    private var cardTypeRegister: CardTypeRegister
    
    /**
     Creates a `CardNumberFormatter` with the provided separator for formatting.
     
     - parameter separator: The separator that is used for grouping the card number.
     */
    public init(cardTypeRegister: CardTypeRegister, separator: String = " ") {
        self.separator = separator
        self.cardTypeRegister = cardTypeRegister
    }
    
    /**
     This function removes the format of a card number string that has been formatted with the same instance of a `CardNumberFormatter`.
     
     - parameter cardNumberString: The card number string representation that has previously been formatted with `self`.
     
     - returns: The unformatted card number string representation.
     */
    public func unformattedCardNumber(cardNumberString: String) -> String {
        return cardNumberString.stringByReplacingOccurrencesOfString(self.separator, withString: "")
    }
    
    /**
     Formats the given card number string based on the detected card type.
     
     - parameter cardNumberString: The card number's unformatted string representation.
     
     - returns: Formatted card number string.
     */
    public func formattedCardNumber(cardNumberString: String) -> String {
        let regex: NSRegularExpression
        
        let cardType = cardTypeRegister.cardTypeForNumber(Number(rawValue: cardNumberString))
        do {
            let groups = cardType.numberGrouping
            var pattern = ""
            var first = true
            for group in groups {
                pattern += "(\\d{1,\(group)})"
                if !first {
                    pattern += "?"
                }
                first = false
            }
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
        } catch {
            fatalError("Error when creating regular expression: \(error)")
        }
        
        return NSArray(array: self.splitString(cardNumberString, withRegex: regex)).componentsJoinedByString(self.separator)
    }
    
    /**
     Computes the index of the cursor position after unformatting the textField's content.
     
     - parameter textField: The textField containing a formatted string.
     
     - returns: The index of the cursor position or nil, if no selected text was found.
     */
    public func cursorPositionAfterUnformattingText(text: String, inTextField textField: UITextField) -> Int? {
        guard let selectedRange = textField.selectedTextRange else {
            return nil
        }
        let addedCharacters = text.characters.count - (textField.text ?? "").characters.count
        
        let position = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: selectedRange.start) + addedCharacters
        
        let formattedString = text ?? ""
        let components = formattedString.componentsSeparatedByString(self.separator)
        
        // Find the component that contains the cursor
        var componentContainingCursor = 0
        var stringParsingIndex = 0
        for i in 0..<components.count {
            stringParsingIndex += components[i].characters.count
            if position <= stringParsingIndex {
                componentContainingCursor = i
                break
            }
            stringParsingIndex += self.separator.characters.count
        }
        
        return position - componentContainingCursor * self.separator.characters.count
    }
    
    /**
     Computes the index of a character in an unformatted string that is equivalent to `index` in `formattedString`.
     
     **Example:** Index **7** in *"0123 - 4"* (pointing at *"4"*) is equal to index **4** in the unformatted string *"01234"*.
     
     - parameter index:           The index in the formatted string whose equivalent in the unformatted string should be determined.
     - parameter formattedString: The formatted string.
     
     - returns: The index in an unformatted string that is equivalent to `index` in `formattedString`.
     */
    private func indexInUnformattedString(index: Int, formattedString: String) -> Int {
        var componentWithIndex = 0
        var charCount = 0
        for component in formattedString.componentsSeparatedByString(self.separator) {
            charCount += component.characters.count
            if charCount >= index {
                break
            } else {
                componentWithIndex += 1
                charCount += self.separator.characters.count
            }
        }
        
        return index - componentWithIndex * self.separator.characters.count
    }
    
    /**
     Computes the index of a character in a formatted string that is equivalent to `index` in `unformattedString`.
     
     **Example:** Index **4** in *"01234"* (pointing at *"4"*) is equal to index **7** in the formatted string *"0123 - 4"*.
     
     - parameter index:           The index in the unformatted string whose equivalent in the formatted string should be determined.
     - parameter unformattedString: The unformatted string.
     
     - returns: The index in a formatted string that is equivalent to `index` in `unformattedString`.
     */
    private func indexInFormattedString(index: Int, unformattedString: String) -> Int {
        var charIdx = 0
        let formattedString = self.formattedCardNumber(unformattedString)
        
        let groups = formattedString.componentsSeparatedByString(self.separator)
        
        for i in 0..<groups.count {
            let groupChars = groups[i].characters.count
            
            charIdx += groupChars
            if charIdx >= index {
                return min(index + i * self.separator.characters.count, formattedString.characters.count)
            }
        }
        
        return 0
    }
    
    /**
     Replaces the specified range of text in the provided text field with the given string and makes sure that the result is formatted.
     
     - parameter range:     The range of text which should be replaced.
     - parameter textField: The text field whose text should be changed.
     - parameter string:    The new string. This might be unformatted or badly formatted and will be formatted properly before being inserted into `textField`.
     */
    public func replaceRangeFormatted(range: NSRange, inTextField textField: UITextField, withString string: String) {
        let newValueUnformatted = self.unformattedCardNumber(NSString(string: textField.text ?? "").stringByReplacingCharactersInRange(range, withString: string))
        let oldValueUnformatted = self.unformattedCardNumber(textField.text ?? "")
        
        let newValue = self.formattedCardNumber(newValueUnformatted)
        let oldValue = textField.text ?? ""
        
        var position: UITextPosition?
        if let start = textField.selectedTextRange?.start {
            let oldCursorPosition = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: start)
            let oldCursorPositionUnformatted = self.indexInUnformattedString(oldCursorPosition, formattedString: oldValue)
            let newCursorPositionUnformatted = oldCursorPositionUnformatted + (newValueUnformatted.characters.count - oldValueUnformatted.characters.count)
            let newCursorPositionFormatted = self.indexInFormattedString(newCursorPositionUnformatted, unformattedString: newValueUnformatted)
            
            position = textField.positionFromPosition(textField.beginningOfDocument, offset: newCursorPositionFormatted)
        }
        
        textField.text = newValue
        if let position = position {
            textField.selectedTextRange = textField.textRangeFromPosition(position, toPosition: position)
        }
    }
    
    /**
     Splits a string with a given regular expression and returns all matches in an array of separate strings.
     
     - parameter string: The string that is to be split.
     - parameter regex: The regular expression that is used to search for matches in `string`.
     
     - returns: An array of all matches found in string for `regex`.
     */
    private func splitString(string: String, withRegex regex: NSRegularExpression) -> [String] {
        let matches = regex.matchesInString(string, options: NSMatchingOptions(), range: NSMakeRange(0, string.characters.count))
        var result = [String]()
        
        matches.forEach {
            for i in 1..<$0.numberOfRanges {
                let range = $0.rangeAtIndex(i)
                
                if range.length > 0 {
                    result.append(NSString(string: string).substringWithRange(range))
                }
            }
        }
        
        return result
    }
}