//
//  NSStringExtensions.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//
import Stripe
extension NSString {
    
    class func stp_stringWithCardBrand(brand: STPCardBrand) -> String {
        switch brand {
        case STPCardBrand.Amex:
            return "American Express"
        case STPCardBrand.DinersClub:
            return "Diners Club"
        case STPCardBrand.Discover:
            return "Discover"
        case STPCardBrand.JCB:
            return "JCB"
        case STPCardBrand.MasterCard:
            return "MasterCard"
        case STPCardBrand.Unknown:
            return "Unknown"
        case STPCardBrand.Visa:
            return "Visa"
        }
    }
    
    class func getFontSizeFromCGSize(text: String, font: UIFont, rect: CGSize) -> CGFloat {
        
        // Size required to render string
        let size = text.sizeWithAttributes([NSFontAttributeName: font])
        
        // For current font point size, calculate points per pixel
        let pointsPerPixel: CGFloat =  font.pointSize / size.height;

        // Scale up point size for the height of the label
        let desiredPointSize: CGFloat = rect.height * pointsPerPixel
        
        return desiredPointSize
    }
    
}
func linkNSStringCardBrandsCategory() {
}