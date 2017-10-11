//
//  AlertCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

struct AlertCellPresenter {

    static func configureCell(_ alertCell: AlertCell, type: AlertType = .normal) {
        alertCell.input.isHidden = true
        alertCell.okButton.isHidden = true
        alertCell.cancelButton.isHidden = true
        alertCell.contentView.backgroundColor = type.backgroundColor
    }

    static func configureForWhiteAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.setLabelText(action.title, color: UIColor.black, alignment: textAlignment)
        cell.background.backgroundColor = UIColor.white
    }

    static func configureForLightAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.setLabelText(action.title, color: UIColor.grey6(), alignment: textAlignment)
        cell.background.backgroundColor = UIColor.greyE5()
    }

    static func configureForDarkAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.setLabelText(action.title, alignment: textAlignment)
        cell.background.backgroundColor = UIColor.black
    }

    static func configureForInputAction(_ cell: AlertCell, type: AlertType, action: AlertAction) {
        configureCell(cell, type: type)

        cell.input.isHidden = false
        cell.input.placeholder = action.title

        cell.input.keyboardAppearance = .dark
        cell.input.keyboardType = .default
        cell.input.autocapitalizationType = .sentences
        cell.input.autocorrectionType = .default
        cell.input.spellCheckingType = .default
        cell.input.keyboardAppearance = .dark
        cell.input.enablesReturnKeyAutomatically = true
        cell.input.returnKeyType = .default

        cell.background.backgroundColor = UIColor.white
    }

    static func configureForURLAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureForInputAction(cell, type: type, action: action)

        cell.input.keyboardAppearance = .dark
        cell.input.keyboardType = .URL
        cell.input.autocapitalizationType = .none
        cell.input.autocorrectionType = .no
        cell.input.spellCheckingType = .no
    }

    static func configureForOKCancelAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        cell.background.backgroundColor = UIColor.clear
        cell.label.isHidden = true
        cell.input.isHidden = true
        cell.okButton.isHidden = false
        cell.cancelButton.isHidden = false
    }

}
