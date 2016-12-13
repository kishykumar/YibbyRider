//
//  ElloLabel.swift
//  Ello
//
//  Created by Sean on 3/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import UIKit
//import ElloUIFonts

open class ElloLabel: UILabel {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let text = self.text {
            self.setLabelText(text, color: textColor)
        }
    }

    public init() {
        super.init(frame: CGRect.zero)
    }

    func attributes(_ color: UIColor, alignment: NSTextAlignment) -> [String : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = alignment

        return [
//            NSFontAttributeName : UIFont.defaultFont(),
            NSFontAttributeName : UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }
}

// MARK: UIView Overrides
extension ElloLabel {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = heightForWidth(size.width) + 10
        return size
    }
}

public extension ElloLabel {
    func setLabelText(_ title: String, color: UIColor = UIColor.white, alignment: NSTextAlignment = .left) {
        let attrs = attributes(color, alignment: alignment)
        attributedText = NSAttributedString(string: title, attributes: attrs)
    }

    func height() -> CGFloat {
        return heightForWidth(self.frame.size.width)
    }

    func heightForWidth(_ width: CGFloat) -> CGFloat {
        return (attributedText?.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil).size.height).map(ceil) ?? 0
    }

}

open class ElloToggleLabel: ElloLabel {
    open override func setLabelText(_ title: String, color: UIColor = UIColor.greyA(), alignment: NSTextAlignment = .left) {
        super.setLabelText(title, color: color, alignment: alignment)
    }
}

open class ElloErrorLabel: ElloLabel {
    open override func setLabelText(_ title: String, color: UIColor = UIColor.red, alignment: NSTextAlignment = .left) {
        super.setLabelText(title, color: color, alignment: alignment)
    }
}

open class ElloSizeableLabel: ElloLabel {
    override open func attributes(_ color: UIColor, alignment: NSTextAlignment) -> [String : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = alignment

        return [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }
}
