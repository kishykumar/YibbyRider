//
//  CustomizeTextfield.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 17/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class CustomizeTextfield : UITextField{
        
        var textFieldData : String? {
            didSet {
                print(textFieldData)
            }
        }
        
        
        func setRightViewButton(rightButton : UIButton,buttonImage : UIImage, senderTextfield : UITextField) {
            
            let rightView = UIView()
            rightButton.frame = CGRect(x:0, y:0, width:25, height: 25)
            rightButton.setImage(buttonImage, for: .normal)
            rightView.addSubview(rightButton)
            rightView.frame = CGRect(x:0, y:0, width:rightButton.frame.size.width+10, height: 30)
            senderTextfield.rightViewMode = .always
            senderTextfield.rightView = rightView
            
            
        }
        
        
        //MARK: Set Left Image Icon
//func setLeftViewImage(leftImageIcon : UIImage,senderTextfield : UITextField) {
    
    func setLeftViewImage(leftImageIcon: UIImage,senderTextfield: UITextField) {
            
            textFieldData = senderTextfield.text
            
            let leftImageView = UIImageView()
            leftImageView.image = leftImageIcon
            let leftView = UIView()
            
            //    if imageName == "msg-icon" {
            //        leftImageView.frame = CGRect(x:0, y:0, width:textField.frame.size.height-15, height: textField.frame.size.height-20)
            //    }else{
            leftImageView.frame = CGRect(x:5, y: 5, width:senderTextfield.frame.size.height-10, height: senderTextfield.frame.size.height-10)
            // }
            leftView.addSubview(leftImageView)
            leftView.frame = CGRect(x:0, y:0, width:leftImageView.frame.size.width + 10, height: senderTextfield.frame.size.height)
            leftImageView.contentMode = .scaleToFill
            senderTextfield.leftViewMode = .always
            senderTextfield.leftView = leftView
            
            senderTextfield.text = textFieldData
            // senderTextfield.sizeToFit()
            senderTextfield.adjustsFontSizeToFitWidth = true
            senderTextfield.minimumFontSize = 10.0
            
            // senderTextfield.layoutIfNeeded()
        }
        
        //MARK: Set Right Image Icon
func setRightViewImage(rightImageIcon : UIImage,senderTextfield : UITextField) {
            
            
            textFieldData = senderTextfield.text
            
            let rightView = UIView()
            let rightImageView = UIImageView()
            rightImageView.frame = CGRect(x:5, y: 5, width:senderTextfield.frame.size.height-10, height: senderTextfield.frame.size.height-10)
            rightImageView.image = rightImageIcon
            
            rightView.addSubview(rightImageView)
            rightView.frame = CGRect(x:0, y:0, width:rightImageView.frame.size.width + 10, height: senderTextfield.frame.size.height)
            rightImageView.contentMode = .scaleToFill
            senderTextfield.rightViewMode = .always
            senderTextfield.rightView = rightView
            
            senderTextfield.text = textFieldData
            
            // senderTextfield.sizeToFit()
            senderTextfield.adjustsFontSizeToFitWidth = true
            senderTextfield.minimumFontSize = 10.0
            
            //  senderTextfield.layoutIfNeeded()
            
            
        }
        
        
        
        /*func removeRightView(senderTextfield : UITextField, type : String){
            print(senderTextfield.subviews)
            if type == "Right" {
                senderTextfield.rightViewMode = .Never
                senderTextfield.rightView = rightView
            }else{
                senderTextfield.leftViewMode = .Never
                senderTextfield.leftView = leftView
            }
        }*/
        
        
        //MARK: Set Padding Left and Right
        
        func setBothSidesPadding(selectedTF:UITextField,amount:CGFloat) {
            
            setLeftPaddingPoint(selectedTF: selectedTF, amount: amount)
            setRightPaddingPoint(selectedTF: selectedTF, amount: amount)
        }
        
        
        func setLeftPaddingPoint(selectedTF:UITextField,amount:CGFloat){
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        func setRightPaddingPoint(selectedTF:UITextField,amount:CGFloat) {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
        }
        
        
        //        for subview in selectedTextField.subviews {
        //           // if ((subview as? UIView) != nil) || ((subview as? UIImageView) != nil) {
        //                subview.removeFromSuperview()
        //           // }
        //        }
        
        
        
        
        
}
