//
//  YibbyBorderedUIView.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/17/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import Spring

@IBDesignable
open class YibbyBorderedUIView: SpringView {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }
    
    func sharedSetup() {
        
//        self.layer.cornerRadius = 10
        self.layer.cornerRadius = 0
        
        // shadow
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.0
        self.layer.shadowRadius = 0
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.borderColor = UIColor.clear.cgColor
    }

    @IBInspectable
    var cornerRadius: CGFloat = 10 {
        didSet {
            if cornerRadius >= 0 {
                self.layer.cornerRadius = cornerRadius
            }
        }
    }

    @IBInspectable
    var shadowOpacity: Float = 0.5 {
        didSet {
            if shadowOpacity >= 0 {
                self.layer.shadowOpacity = shadowOpacity
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 2 {
        didSet {
            if shadowRadius >= 0 {
                self.layer.shadowRadius = shadowRadius
            }
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = UIColor.black {
        didSet {
            self.layer.shadowColor = self.shadowColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth >= 0 {
                self.layer.borderWidth = CGFloat(borderWidth)
            } else {
                self.layer.borderWidth = 0
            }
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
}
