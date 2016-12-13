//
//  AlertAction.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public typealias AlertHandler = ((AlertAction) -> Void)?
public typealias AlertCellConfigClosure = (
    _ cell: AlertCell,
    _ type: AlertType,
    _ action: AlertAction,
    _ textAlignment: NSTextAlignment
) -> Void

public enum ActionStyle {
    case white
    case light
    case dark
    case okCancel
    case urlInput
}

public struct AlertAction {
    public let title: String
    public let style: ActionStyle
    public let handler: AlertHandler

    public var isInput: Bool {
        switch style {
        case .urlInput, .okCancel:
            return true
        default:
            return false
        }
    }

    public init(title: String, style: ActionStyle, handler: AlertHandler = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    public var configure: AlertCellConfigClosure {
        switch style {
        case .white:
            return AlertCellPresenter.configureForWhiteAction
        case .light:
            return AlertCellPresenter.configureForLightAction
        case .dark:
            return AlertCellPresenter.configureForDarkAction
        case .okCancel:
            return AlertCellPresenter.configureForOKCancelAction
        case .urlInput:
            return AlertCellPresenter.configureForURLAction
        }
    }

}
