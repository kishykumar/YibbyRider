//
//  YibbyTextField.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import Foundation

public class YibbyTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20);
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }
    
    func sharedSetup() {
        self.backgroundColor = UIColor.textFieldBackgroundColor1()
        self.textColor = UIColor.textFieldTextColor1()
        
        self.font = UIFont.systemFontOfSize(14)
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6.0;
        self.layer.borderColor = UIColor.themeColor1().CGColor
        
        self.setNeedsDisplay()
    }
    
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    override public func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    private func rectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}
