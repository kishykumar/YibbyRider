//
//  UIViewExtensions.swift
//  Yibby
//
//  Created by Kishy Kumar on 10/16/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

extension UIView {
    
    func addBottomBorder() {
        let border = CALayer()
        let borderWidth: CGFloat = 1.0
        
        border.backgroundColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0,
                              y: self.frame.size.height - borderWidth,
                              width: self.frame.size.width,
                              height: borderWidth)
        
        self.layer.addSublayer(border)
    }
}
