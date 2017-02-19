//
//  AlertCell.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Foundation
//import ElloUIFonts
import CoreGraphics

public protocol AlertCellDelegate: class {
    func tappedOkButton()
    func tappedCancelButton()
}

open class AlertCell: UITableViewCell {
    weak var delegate: AlertCellDelegate?

    @IBOutlet weak var label: ElloLabel!
    @IBOutlet weak var input: ElloTextField!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var okButton: ElloButton!
    @IBOutlet weak var cancelButton: ElloButton!
    let inputBorder = UIView()

    var onInputChanged: ((String) -> Void)?

    override open func awakeFromNib() {
        super.awakeFromNib()

        input.backgroundColor = UIColor.white
//        input.font = UIFont.defaultFont()
        input.font = UIFont.systemFont(ofSize: 14)
        input.textColor = UIColor.black
        input.tintColor = UIColor.black
        input.clipsToBounds = false

        inputBorder.backgroundColor = UIColor.black
        input.addSubview(inputBorder)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        inputBorder.frame = input.bounds.fromBottom().grow(top: 1, sides: 10, bottom: 0)
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        label.text = ""
        input.text = ""
        input.resignFirstResponder()
    }
}

extension AlertCell {
    @IBAction func didUpdateInput() {
        onInputChanged?(input.text ?? "")
    }

    @IBAction func didTapOkButton() {
        delegate?.tappedOkButton()
    }

    @IBAction func didTapCancelButton() {
        delegate?.tappedCancelButton()
    }

}

extension AlertCell {
    class func nib() -> UINib {
        return UINib(nibName: "AlertCell", bundle: .none)
    }

    class func reuseIdentifier() -> String {
        return "AlertCell"
    }

}
