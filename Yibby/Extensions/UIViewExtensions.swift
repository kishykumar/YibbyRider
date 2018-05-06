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
        
        border.backgroundColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0,
                              y: self.frame.size.height - borderWidth,
                              width: self.frame.size.width,
                              height: borderWidth)
        
        self.layer.addSublayer(border)
    }
    
    func setRoundedWithWhiteBorder() {
        setRoundedWithBorder(UIColor.white)
    }

    func setRoundedWithBorder(_ color: UIColor) {
        makeRounded()
        setBorder(color)
    }

    func setBorder(_ borderColor: UIColor) {
        let layer = self.layer
        layer.borderWidth = 2.0
        layer.borderColor = borderColor.cgColor
    }
    
    func addShadow() {
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 2.0
        
        // To avoid performance hit, As per: https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addShadowToRoundView(_ cornerRadius: CGFloat) {
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 2.0
        
        // To avoid performance hit, As per: https://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
        //self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func makeRounded() {
        let layer = self.layer
        self.clipsToBounds = true
        layer.cornerRadius = self.frame.size.height / 2;
        layer.masksToBounds = true
    }
    
    func curvedViewWithBorder(_ cornerRadius: CGFloat, borderColor: UIColor) {
        let layer = self.layer
        self.clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        setBorder(borderColor)
    }
    
    func addBlur() -> UIVisualEffectView? {
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            return blurEffectView
        } else {
            self.backgroundColor = .black
        }
        return nil
    }
    
    func removeBlur(blurEffectView: UIVisualEffectView) {
        
        UIView.animate(withDuration: 1.5, animations: {blurEffectView.alpha = 0.0},
                       completion: {(value: Bool) in
                            blurEffectView.removeFromSuperview()
        })
    }
}
