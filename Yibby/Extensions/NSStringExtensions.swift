//
//  NSStringExtensions.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//
import Stripe
extension NSString {
    
    class func stp_stringWithCardBrand(_ brand: STPCardBrand) -> String {
        switch brand {
        case STPCardBrand.amex:
            return "American Express"
        case STPCardBrand.dinersClub:
            return "Diners Club"
        case STPCardBrand.discover:
            return "Discover"
        case STPCardBrand.JCB:
            return "JCB"
        case STPCardBrand.masterCard:
            return "MasterCard"
        case STPCardBrand.unknown:
            return "Unknown"
        case STPCardBrand.visa:
            return "Visa"
        case .unionPay:
            return "Union Pay"
        }
    }
    
    class func getFontSizeFromCGSize(_ text: String, font: UIFont, rect: CGSize) -> CGFloat {
        
        // Size required to render string
        let size = text.size(withAttributes: [NSAttributedStringKey.font: font])
        
        // For current font point size, calculate points per pixel
        let pointsPerPixel: CGFloat =  font.pointSize / size.height;

        // Scale up point size for the height of the label
        let desiredPointSize: CGFloat = rect.height * pointsPerPixel
        
        return desiredPointSize
    }
}

extension String {
    func stripPhoneNumber() -> String {
        var formattedPhoneNumber = self
        formattedPhoneNumber =
            formattedPhoneNumber.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
        formattedPhoneNumber =
            formattedPhoneNumber.replacingOccurrences(of: ")", with: "", options: .literal, range: nil)
        formattedPhoneNumber =
            formattedPhoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        formattedPhoneNumber =
            formattedPhoneNumber.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
        return formattedPhoneNumber
    }
}
