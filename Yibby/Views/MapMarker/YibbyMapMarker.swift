//
//  YibbyMapMarker.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/7/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import GoogleMaps
import TextFieldEffects
import BButton

@IBDesignable
open class YibbyMapMarker: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var infoWindowLabelOutlet: UILabel!
    
    var marker: GMSMarker!
    
    // MARK: - Initializers & view setup

    
    // MARK: - View customization
    
    /**
     You can override this function to provide your own Nib. If you do so, please override 'getNibBundle' as well to provide the right NSBundle to load the nib file.
     */
    class func getNibName() -> String {
        return "YibbyMapMarker"
    }
    
    /**
     You can override this function to provide the NSBundle for your own Nib. If you do so, please override 'getNibName' as well to provide the right Nib to load the nib file.
     */
    class func getNibBundle() -> Bundle {
        return Bundle(for: YibbyMapMarker.self)
    }
    
    // MARK: - Helper functions
    
    func bindGUI(_ title: String) {
        self.infoWindowLabelOutlet.text = title
    }
    
    func setMarkerValue(_ marker: GMSMarker, title: String) {
        self.marker = marker
        self.bindGUI(title)
    }
    
    class func annotationImageWithMarker(_ marker: GMSMarker,
                                         title: String,
                                         andPinIcon iconImage: UIImage,
                                         pickup: Bool) -> UIImage {
        
        let screenSize: CGRect = UIScreen.main.bounds

        let infoWindowHeight = iconImage.size.height * 1.1
        let infoWindowWidth = screenSize.width * 0.50
        
        let infoWindow = YibbyFloatLabelTextField(frame: CGRect(x: 0, y: 0,
                                                                    width: infoWindowWidth,
                                                                    height: infoWindowHeight))
        
        infoWindow.font = UIFont.systemFont(ofSize: 12.5)
        infoWindow.text = title
        infoWindow.backgroundColor = UIColor.white
        infoWindow.borderWidth = 1.0
        infoWindow.cornerRadius = 10.0
        infoWindow.textAlignment = NSTextAlignment.center
        infoWindow.titleYPadding = 5.0
        
        // Create container view
        let containerView = UIView(frame: CGRect(x: 0, y: 0,
                                                     width: (infoWindowWidth > iconImage.size.width) ?
                                                        infoWindowWidth : iconImage.size.width,
                                                     height: iconImage.size.height + infoWindowHeight))
        
        // Create icon image, and center it below the view
//        let iconImageView = UIImageView(image: iconImage)
//        iconImageView.backgroundColor = UIColor.clearColor()
//        
//        iconImageView.frame = CGRectMake((infoWindow.frame.size.width - iconImage.size.width) / 2,
//                                         infoWindow.frame.size.height,
//                                         iconImage.size.width,
//                                         iconImage.size.height)
        
        let label = UILabel(frame: CGRect(x: (infoWindow.frame.size.width - iconImage.size.width) / 2,
                                                y: infoWindow.frame.size.height,
                                                width: infoWindowWidth,
                                                height: iconImage.size.height))
        
        label.font = UIFont(name: "FontAwesome", size: 12.0)
        label.text = String.fa_string(forFontAwesomeIcon: FAIcon.FAMapMarker)
        
        
        let labelFontSize = String.getFontSizeFromCGSize(label.text!,
                                                         font: label.font,
                                                         rect: CGSize(width: infoWindowWidth, height: iconImage.size.height))
        
        label.font = UIFont(name: "FontAwesome", size: labelFontSize)
        
        if (pickup) {
            infoWindow.placeholder = InterfaceString.Ride.Pickup
            infoWindow.borderColor = UIColor.red
            infoWindow.titleTextColour = UIColor.red
            
            label.textColor = UIColor.red
        } else {
            infoWindow.placeholder = InterfaceString.Ride.Dropoff
            infoWindow.borderColor = UIColor.appDarkGreen1()
            infoWindow.titleTextColour = UIColor.appDarkGreen1()
            
            label.textColor = UIColor.appDarkGreen1()
        }
        
        containerView.addSubview(infoWindow)
        containerView.addSubview(label)
//        containerView.addSubview(iconImageView)
        
        // Render image
        UIGraphicsBeginImageContextWithOptions(containerView.frame.size, false, UIScreen.main.scale)
        containerView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return image!
    }
}
