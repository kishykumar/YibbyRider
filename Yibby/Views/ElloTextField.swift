//
//  ElloTextField.swift
//  Ello
//
//  Created by Sean Dougherty on 11/25/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

enum ValidationState {
    case loading
    case error
    case ok
    case none

    var imageRepresentation: UIImage? {
        switch self {
        case .loading: return InterfaceImage.ValidationLoading.normalImage
        case .error: return InterfaceImage.ValidationError.normalImage
        case .ok: return InterfaceImage.ValidationOK.normalImage
        case .none: return nil
        }
    }
}

open class ElloTextField: UITextField {
    var hasOnePassword = false
    var validationState = ValidationState.none {
        didSet {
            self.rightViewMode = .always
            self.rightView = UIImageView(image: validationState.imageRepresentation)
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.backgroundColor = UIColor.greyE5()
        self.font = UIFont.systemFont(ofSize: 14)
        self.textColor = UIColor.black

        self.setNeedsDisplay()
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 44
        }
        return rect
    }

    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 10
        return rect
    }

    fileprivate func rectForBounds(_ bounds: CGRect) -> CGRect {
        return bounds.shrinkLeft(15).inset(topBottom: 10, sides: 15)
    }

}
