//
//  QuickExtensions.swift
//  Ello
//
//  Created by Colin Gray on 4/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable
import Yibby
import Quick
import Nimble
import Nimble_Snapshots


func showController(_ viewController: UIViewController) -> UIWindow {
    let frame: CGRect
    let view = viewController.view
    if view?.frame.size.width > 0 && view?.frame.size.height > 0 {
        frame = CGRect(origin: CGPoint.zero, size: (view?.frame.size)!)
    }
    else {
        frame = UIScreen.main.bounds
    }
    
    if #available(iOS 9.0, *) {
        viewController.loadViewIfNeeded()
    }
    
    let window = UIWindow(frame: frame)
    window.makeKeyAndVisible()
    window.rootViewController = viewController
    viewController.view.layoutIfNeeded()
    return window
}

func showView(_ view: UIView) -> UIWindow {
    let controller = UIViewController()
    controller.view.frame.size = view.frame.size
    view.frame.origin = CGPoint.zero
    controller.view.addSubview(view)
    return showController(controller)
}

public enum SnapshotDevice {
//    case Pad_Landscape
    case pad_Portrait
    case phone4_Portrait
    case phone5_Portrait
    case phone6_Portrait
    case phone6Plus_Portrait
    
    static let all: [SnapshotDevice] = [
//        .Pad_Landscape,
        .pad_Portrait,
        .phone4_Portrait,
        .phone5_Portrait,
        .phone6_Portrait,
        .phone6Plus_Portrait,
        ]
    
    var description: String {
        switch self {
//        case Pad_Landscape: return "iPad in Landscape"
        case .pad_Portrait: return "iPad in Portrait"
        case .phone4_Portrait: return "iPhone4 in Portrait"
        case .phone5_Portrait: return "iPhone5 in Portrait"
        case .phone6_Portrait: return "iPhone6 in Portrait"
        case .phone6Plus_Portrait: return "iPhone6Plus in Portrait"
        }
    }
    
    var size: CGSize {
        switch self {
//        case Pad_Landscape: return CGSize(width: 1024, height: 768)
        case .pad_Portrait: return CGSize(width: 768, height: 1024)
        case .phone4_Portrait: return CGSize(width: 320, height: 480)
        case .phone5_Portrait: return CGSize(width: 320, height: 568)
        case .phone6_Portrait: return CGSize(width: 375, height: 667)
        case .phone6Plus_Portrait: return CGSize(width: 414, height: 736)
        }
    }
}

func validateAllSnapshots(_ subject: Snapshotable, named name: String? = nil, record: Bool = false, file: String = #file, line: UInt = #line) {
    for device in SnapshotDevice.all {
        context(device.description) {
            describe("view") {
                it("should match the screenshot", file: file, line: line) {
                    prepareForSnapshot(subject, size: device.size)
                    
                    let localName: String?
                    if let name = name {
                        localName = "\(name) on \(device.description)"
                    }
                    else {
                        localName = nil
                    }
                    expect(subject, file: file, line: line).to(record ? recordSnapshot(named: localName) : haveValidSnapshot(named: localName))
                }
            }
        }
    }
}

func prepareForSnapshot(_ subject: Snapshotable, device: SnapshotDevice) {
    prepareForSnapshot(subject, size: device.size)
}

func prepareForSnapshot(_ subject: Snapshotable, size: CGSize) {
    let parent = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
    let view = subject.snapshotObject!
    view.frame = parent.bounds
    parent.addSubview(view)
    view.layoutIfNeeded()
    showView(view)
}


public extension UIStoryboard {
    
    class func storyboardWithId(_ identifier: String, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: Bundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier(identifier)
    }
    
}

public func haveRegisteredIdentifier<T: UITableView>(_ identifier: String) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "\(identifier) should be registered"
        let tableView = try! actualExpression.evaluate() as! UITableView
        tableView.reloadData()
        // Using the side effect of a runtime crash when dequeing a cell here, if it works :thumbsup:
        let _ = tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(row: 0, section: 0))
        return true
    }
}

public func beVisibleIn<S: UIView>(_ view: UIView) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be visible in \(view)"
        let childView = try! actualExpression.evaluate()
        if let childView = childView {
            if childView.isHidden || childView.alpha < 0.01 || childView.frame.size.width < 0.1 || childView.frame.size.height < 0.1 {
                return false
            }
            
            var parentView: UIView? = childView.superview
            while parentView != nil {
                if let parentView = parentView, parentView == view {
                    return true
                }
                parentView = parentView!.superview
            }
        }
        return false
    }
}

//public func checkRegions(regions: [OmnibarRegion], contain text: String) {
//    for region in regions {
//        if let regionText = region.text where regionText.string.contains(text) {
//            expect(regionText.string).to(contain(text))
//            return
//        }
//    }
//    fail("could not find \(text) in regions \(regions)")
//}
//
//public func checkRegions(regions: [OmnibarRegion], notToContain text: String) {
//    for region in regions {
//        if let regionText = region.text where regionText.string.contains(text) {
//            expect(regionText.string).notTo(contain(text))
//        }
//    }
//}
//
//public func checkRegions(regions: [OmnibarRegion], equal text: String) {
//    for region in regions {
//        if let regionText = region.text where regionText.string == text {
//            expect(regionText.string) == text
//            return
//        }
//    }
//    fail("could not find \(text) in regions \(regions)")
//}
//
//public func haveImageRegion<S: OmnibarScreenProtocol>() -> NonNilMatcherFunc<S> {
//    return NonNilMatcherFunc { actualExpression, failureMessage in
//        failureMessage.postfixMessage = "have image"
//        
//        if let screen = try! actualExpression.evaluate() {
//            for region in screen.regions {
//                if region.image != nil {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//}
//
//public func haveImageRegion<S: OmnibarScreenProtocol>(equal image: UIImage) -> NonNilMatcherFunc<S> {
//    return NonNilMatcherFunc { actualExpression, failureMessage in
//        failureMessage.postfixMessage = "have image that equals \(image)"
//        
//        if let screen = try! actualExpression.evaluate() {
//            for region in screen.regions {
//                if let regionImage = region.image where regionImage == image {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//}

private func allSubviews(_ view: UIView) -> [UIView] {
    return view.subviews + view.subviews.flatMap { allSubviews($0) }
}

public func subviewThatMatches(_ view: UIView, test: (UIView) -> Bool) -> UIView? {
    for subview in allSubviews(view) {
        if test(subview) {
            return subview
        }
    }
    return nil
}

public func haveSubview<V: UIView>(thatMatches test: @escaping (UIView) -> Bool) -> NonNilMatcherFunc<V> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have subview that matches"
        
        let view = try! actualExpression.evaluate()
        if let view = view {
            return subviewThatMatches(view, test: test) != nil
        }
        return false
    }
}
