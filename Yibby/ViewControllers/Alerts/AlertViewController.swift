//
//  AlertViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics
import UIKit

private let DesiredWidth: CGFloat = 300
let MaxHeight = UIScreen.main.applicationFrame.height - 20

// TODO: REMOVE IT LATER
public typealias ElloEmptyCompletion = () -> Void
public typealias ElloFailureCompletion = (_ error: NSError, _ statusCode: Int?) -> Void

public enum AlertType {
    case normal
    case danger
    case clear

    var backgroundColor: UIColor {
        switch self {
        case .danger: return .red
        case .clear: return .clear
        default: return .white
        }
    }

    var headerTextColor: UIColor {
        switch self {
        case .clear: return .white
        default: return .black
        }
    }

    var cellColor: UIColor {
        switch self {
        case .clear: return .clear
        default: return .white
        }
    }
}

open class AlertViewController: UIViewController {
    @IBOutlet open weak var tableView: UITableView!
    @IBOutlet open weak var topPadding: NSLayoutConstraint!
    @IBOutlet open weak var leftPadding: NSLayoutConstraint!
    @IBOutlet open weak var rightPadding: NSLayoutConstraint!

//    var keyboardWillShowObserver: NotificationObserver?
//    var keyboardWillHideObserver: NotificationObserver?

    // assign a contentView to show a message or spinner.  The contentView frame
    // size must be set.
    open var contentView: UIView? {
        willSet { willSetContentView() }
        didSet { didSetContentView() }
    }

    open var modalBackgroundColor: UIColor = .modalBackground()

    open var desiredSize: CGSize {
        if let contentView = contentView {
            return contentView.frame.size
        }
        else {
            let contentHeight = tableView.contentSize.height + totalVerticalPadding
            let height = min(contentHeight, MaxHeight)
            return CGSize(width: DesiredWidth, height: height)
        }
    }

    open var dismissable = true
    open var autoDismiss = true

    open fileprivate(set) var actions: [AlertAction] = []
    fileprivate var inputs: [String] = []
    var actionInputs: [String] {
        var retVals: [String] = []
        for (index, action) in actions.enumerated() {
            if action.isInput {
                retVals.append(inputs[index])
            }
        }
        return retVals
    }

    fileprivate let textAlignment: NSTextAlignment
    open var type: AlertType = .normal {
        didSet {
            let backgroundColor = type.backgroundColor
            view.backgroundColor = backgroundColor
            tableView.backgroundColor = backgroundColor
            headerView.backgroundColor = backgroundColor
            tableView.reloadData()
        }
    }

    open var message: String {
        get { return headerView.label.text ?? "" }
        set(text) {
            headerView.label.setLabelText(text, color: UIColor.black)
            tableView.reloadData()
        }
    }

    fileprivate let headerView: AlertHeaderView = {
        return AlertHeaderView.loadFromNib()
    }()

    fileprivate var totalHorizontalPadding: CGFloat {
        return leftPadding.constant + rightPadding.constant
    }

    fileprivate var totalVerticalPadding: CGFloat {
        return 2 * topPadding.constant
    }

    public init(message: String? = nil, textAlignment: NSTextAlignment = .center, type: AlertType = .normal) {
        self.textAlignment = textAlignment
        super.init(nibName: "AlertViewController", bundle: Bundle(for: AlertViewController.self))
        modalPresentationStyle = .custom
        transitioningDelegate = self
        headerView.label.setLabelText(message ?? "", color: type.headerTextColor)

        view.backgroundColor = type.backgroundColor
        tableView.backgroundColor = type.backgroundColor
        headerView.backgroundColor = type.backgroundColor
        self.type = type
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("This isn't implemented")
    }
}

public extension AlertViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AlertCell.nib(), forCellReuseIdentifier: AlertCell.reuseIdentifier())
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardUpdateFrame)
//        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardUpdateFrame)

        if type == .clear {
            leftPadding.constant = 5
            rightPadding.constant = 5
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isScrollEnabled = (view.frame.height == MaxHeight)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        keyboardWillShowObserver?.removeObserver()
//        keyboardWillShowObserver = nil
//        keyboardWillHideObserver?.removeObserver()
//        keyboardWillHideObserver = nil
    }

    public func dismiss(_ animated: Bool = true, completion: ElloEmptyCompletion? = .none) {
        self.dismiss(animated: animated, completion: completion)
    }
}

public extension AlertViewController {
    func addAction(_ action: AlertAction) {
        actions.append(action)
        inputs.append("")

        tableView.reloadData()
    }

    func resetActions() {
        actions = []
        inputs = []

        tableView.reloadData()
    }
}

extension AlertViewController {
    fileprivate func willSetContentView() {
        if let contentView = contentView {
            contentView.removeFromSuperview()
        }
    }

    fileprivate func didSetContentView() {
        if let contentView = contentView {
            self.tableView.isHidden = true
            self.view.addSubview(contentView)
        }
        else {
            self.tableView.isHidden = false
        }

        resize()
    }

    public func resize() {
        self.view.frame.size = self.desiredSize
        if let superview = self.view.superview {
            self.view.center = superview.center
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension AlertViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented != self { return .none }

        return AlertPresentationController(presentedViewController: presented, presentingViewController: presenting!, backgroundColor: self.modalBackgroundColor)
    }
}

// MARK: UITableViewDelegate
extension AlertViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // apparently iOS (9?) has a bug where main-queue updates take a long time. WTF.
        nextTick {
            if self.autoDismiss {
                self.dismiss()
            }

            if let action = self.actions.safeValue(indexPath.row), !action.isInput
            {
                action.handler?(action)
            }
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if message.characters.count == 0 {
            return nil
        }
        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if message.characters.count == 0 {
            return 0
        }
        let size = CGSize(width: DesiredWidth - totalHorizontalPadding, height: .greatestFiniteMagnitude)
        let height = headerView.label.sizeThatFits(size).height
        return height
    }
}

// MARK: UITableViewDataSource
extension AlertViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlertCell.reuseIdentifier(), for: indexPath) as! AlertCell

        if let action = actions.safeValue(indexPath.row), let input = inputs.safeValue(indexPath.row) {
            action.configure(cell, type, action, textAlignment)

            cell.input.text = input
            cell.onInputChanged = { text in
                self.inputs[indexPath.row] = text
            }
        }

        cell.delegate = self
        cell.backgroundColor = type.cellColor
        return cell
    }
}

extension AlertViewController: AlertCellDelegate {
    public func tappedOkButton() {
        dismiss()

        if let action = actions.find({ action in
            switch action.style {
            case .okCancel: return true
            default: return false
            }
        }) {
            action.handler?(action)
        }
    }

    public func tappedCancelButton() {
        dismiss()
    }
}
