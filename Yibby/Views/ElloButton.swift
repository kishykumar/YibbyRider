//
//  ElloButton.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

open class ElloButton: UIButton {

    override open var isEnabled: Bool {
        didSet { updateStyle() }
    }

    override open var isSelected: Bool {
        didSet { updateStyle() }
    }

    func updateStyle() {
        backgroundColor = isEnabled ? .black : .grey231F20()
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        if buttonType != .custom {
            print("Warning, ElloButton instance '\(currentTitle)' should be configured as 'Custom', not \(buttonType)")
        }

        updateStyle()
    }

    func sharedSetup() {
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel?.numberOfLines = 1
        setTitleColor(.white, for: UIControlState())
        setTitleColor(.greyA(), for: .disabled)
        updateStyle()
    }

    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRect(forContentRect: contentRect)
        let delta: CGFloat = 4
        titleRect.size.height += 2 * delta
        titleRect.origin.y -= delta
        return titleRect
    }

}

open class LightElloButton: ElloButton {

    override func updateStyle() {
        backgroundColor = isEnabled ? .greyE5() : .greyF1()
    }

    override func sharedSetup() {
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel?.numberOfLines = 1
        setTitleColor(.grey6(), for: UIControlState())
        setTitleColor(.black, for: .highlighted)
        setTitleColor(.greyC(), for: .disabled)
    }

}

open class WhiteElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updateStyle() {
        if !isEnabled {
            backgroundColor = .greyA()
        }
        else if isSelected {
            backgroundColor = .black
        }
        else {
            backgroundColor = .white
        }
    }

    override func sharedSetup() {
        super.sharedSetup()
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        setTitleColor(.black, for: UIControlState())
        setTitleColor(.grey6(), for: .highlighted)
        setTitleColor(.greyC(), for: .disabled)
        setTitleColor(.white, for: .selected)
    }
}

open class OutlineElloButton: WhiteElloButton {

    override func sharedSetup() {
        super.sharedSetup()
        backgroundColor = .white
        updateOutline()
    }

    override open var isHighlighted: Bool {
        didSet {
            updateOutline()
        }
    }

    fileprivate func updateOutline() {
        layer.borderColor = isHighlighted ? UIColor.greyE5().cgColor : UIColor.black.cgColor
        layer.borderWidth = 1
    }
}


open class RoundedElloButton: ElloButton {
    var borderColor: UIColor = .black {
        didSet {
            updateOutline()
        }
    }

    override open func sharedSetup() {
        super.sharedSetup()
        setTitleColor(.black, for: UIControlState())
        setTitleColor(.grey6(), for: .highlighted)
        setTitleColor(.greyC(), for: .disabled)
        layer.borderWidth = 1
        backgroundColor = .clear
        updateOutline()
    }

    override func updateStyle() {
        backgroundColor = isEnabled ? .clear : .grey231F20()
    }

    func updateOutline() {
        layer.borderColor = borderColor.cgColor
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.height, frame.width) / 2
    }
}

open class GreenElloButton: ElloButton {

    override func updateStyle() {
        backgroundColor = isEnabled ? .greenD1() : .greyF1()
    }

    override func sharedSetup() {
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel?.numberOfLines = 1
        setTitleColor(.white, for: UIControlState())
        setTitleColor(.grey6(), for: .highlighted)
        setTitleColor(.greyA(), for: .disabled)
        layer.cornerRadius = 5
    }

}
