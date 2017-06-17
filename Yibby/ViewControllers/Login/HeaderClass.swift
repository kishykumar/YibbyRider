//
//  HeaderClass.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 17/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import Foundation


// MARK: Password validation with 1 numeric and 1 special character

//func checkTextSufficientComplexity( text : String) -> Bool{
//    let text = text
//    let numberRegEx  = ".*[0-9]+.*"
//    let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
//    let numberresult = texttest1.evaluate (with: text)
//    print("\(numberresult)")
//    let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
//    let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
//    
//    let specialresult = texttest2.evaluate(with: text) //texttest2.evaluate(with: text)
//    print("\(specialresult)")
//    
//    return specialresult && numberresult
//    
//}
//
//func isValidPassword(testStr:String) -> Bool{
//    
//    if (testStr.characters.count < 6){
//        return checkTextSufficientComplexity(text: testStr)
//    }
//    else{
//        return false
//        
//    }
//}
//
//
//// MARK: Email validation
//
//func isValidEmail(testStr:String) -> Bool {
//    let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
//    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//    let result = emailTest.evaluate(with: testStr)
//    return result
//}
//
//// MARK: Phone no validation
//
//func isValidPhoneNo(testStr: String) -> Bool {
//    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
//    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//    let result =  phoneTest.evaluate(with: testStr)
//    return result
//}
