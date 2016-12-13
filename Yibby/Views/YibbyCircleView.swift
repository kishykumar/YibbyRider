//
//  YibbyCircleView.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

@IBDesignable
open class YibbyCircleView: YibbyBorderedUIView {
    
    required public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }
    
    override func sharedSetup() {

        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        self.addConstraint(widthConstraint)
        
        self.layer.cornerRadius = self.bounds.height / 2
    }
}
