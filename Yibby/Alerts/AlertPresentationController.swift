//
//  AlertPresentationController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

open class AlertPresentationController: UIPresentationController {

    let background: UIView = {
        let background = UIView(frame: CGRect.zero)
        background.backgroundColor = UIColor.modalBackground()
        return background
    }()

    public init(presentedViewController: UIViewController, presentingViewController: UIViewController, backgroundColor: UIColor) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.background.backgroundColor = backgroundColor
    }
}

// MARK: View Lifecycle
public extension AlertPresentationController {
    override open func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        let alertViewController = presentedViewController as! AlertViewController
        alertViewController.resize()

        let gesture = UITapGestureRecognizer(target:self, action: #selector(AlertPresentationController.dismiss))
        background.addGestureRecognizer(gesture)
    }
}

// MARK: Presentation
public extension AlertPresentationController {
    override open func presentationTransitionWillBegin() {
        if let containerView = containerView {
            background.alpha = 0
            background.frame = containerView.bounds
            containerView.addSubview(background)

            let transitionCoordinator = presentingViewController.transitionCoordinator
            transitionCoordinator?.animate(alongsideTransition: { _ in
                self.background.alpha = 1
                }, completion: .none)
            if let presentedView = presentedView {
                containerView.addSubview(presentedView)
            }
        }
    }

    override open func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.background.alpha = 0
        }, completion: .none)
    }

    override open func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
}

extension AlertPresentationController {
    func dismiss() {
        let alertViewController = presentedViewController as! AlertViewController
        if alertViewController.dismissable {
            presentedViewController.dismiss(animated: true, completion: .none)
        }
    }
}
