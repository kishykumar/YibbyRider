//
//  ImageExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/9/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import CoreGraphics

public extension UIImage {

    class func isGif(_ imageData: Data) -> Bool {
        let length = imageData.count
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        (imageData as NSData).getBytes(buffer, length: imageData.count)

        defer {
            buffer.deallocate(capacity: imageData.count)
        }

        if length >= 4 {
            let isG = Int(buffer[0]) == 71
            let isI = Int(buffer[1]) == 73
            let isF = Int(buffer[2]) == 70
            let is8 = Int(buffer[3]) == 56

            return isG && isI && isF && is8
        }
        else {
            return false
        }
    }

    class func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    class func imageWithHex(_ hex: Int) -> UIImage {
        return imageWithColor(UIColor(netHex: hex))
    }

    func squareImage() -> UIImage? {
        let originalWidth  = self.size.width
        let originalHeight = self.size.height

        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }

        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0

        print("origW: \(originalWidth) origH: \(originalHeight) edge: \(edge) posX: \(posX) posY: \(posY)")
        
        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)

        let imageRef = self.cgImage!.cropping(to: cropSquare)
        if let imageRef = imageRef {
            return UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: self.imageOrientation)
        }
        return nil
    }

    func resizeToSize(_ targetSize: CGSize) -> UIImage {
        let newSize = self.size.scaledSize(targetSize)

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    func roundCorners() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        UIBezierPath(roundedRect: rect, cornerRadius: size.width / 2.0).addClip()
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func copyWithCorrectOrientationAndSize(_ completion:@escaping (_ image: UIImage) -> Void) {
        inBackground {
            let sourceImage: UIImage
            if self.imageOrientation == .up && self.scale == 1.0 {
                sourceImage = self
            }
            else {
                let newSize = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                sourceImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }

            let maxSize = CGSize(width: 1200.0, height: 3600.0)
            let resizedImage = sourceImage.resizeToSize(maxSize)
            inForeground {
                completion(resizedImage)
            }
        }
    }

}
