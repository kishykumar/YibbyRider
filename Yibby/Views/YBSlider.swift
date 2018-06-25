//
//  YBSlider.swift
//  Yibby
//
//  Created by Kishy Kumar on 5/13/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import UIKit

class YBSlider: UISlider {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }
    
    func sharedSetup() {
        
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 12
        return newBounds
    }
}
