//
//  YibbyCircleView.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

@IBDesignable
public class YibbyCircleView: YibbyBorderedUIView {
    
    required public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }
    
    override func sharedSetup() {

        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        self.addConstraint(widthConstraint)
        
        self.layer.cornerRadius = self.bounds.height / 2
    }
}