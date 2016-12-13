//
//  UIImageViewExtensions.swift
//  Ello
//
//  Created by Colin Gray on 5/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension UIImageView {

    func setImage(_ interfaceImage: InterfaceImage, degree: Double) {
        self.image = interfaceImage.normalImage
        if degree != 0 {
            let radians = (degree * M_PI) / 180.0
            self.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        }
    }

    func setRoundedWithWhiteBorder() {
        assert(self.frame.size.width == self.frame.size.height)
        
        let layer = self.layer
        layer.masksToBounds = true
        layer.cornerRadius = (self.frame.size.width / 2)
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}
