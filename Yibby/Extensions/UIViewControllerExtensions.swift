//
//  UIViewControllerExtensions.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 12/03/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import MMDrawerController
import CocoaLumberjack

extension UIViewController {
        
    func setupBackButton() {
        let app: UIApplication = UIApplication.shared
        self.navigationController?.navigationBar.isHidden = true
        let backButton = UIButton(frame: CGRect(x: 0, y: app.statusBarFrame.size.height, width: 50, height: 59))
        backButton.setImage(UIImage(named: "back_button_green"), for: UIControlState.normal)
        backButton.backgroundColor = UIColor.clear
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        self.navigationController?.view.addSubview(backButton)
        
        return;
        
//        let image : UIImage? = UIImage.init(named: "back_button_green")!.withRenderingMode(.alwaysOriginal)
//        let barButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backButtonClicked))
//        setupButtonOnNavigationBarInternal(barButton: barButton)
        
        let image = UIImage.init(named: "back_button_green")!
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(button)
        
        let topGuide = self.topLayoutGuide
        DDLogVerbose("KKDBG_topLayoutlen1: \(topGuide.length)")
        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topGuide, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        self.view.addConstraints([horizontalConstraint, verticalConstraint])
    }
    
    func setupMenuButton() {
        
        let image = UIImage.init(named: "menu_icon_green")!
//        let menuImageView = UIImageView(image: image)
//        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .custom)
//        button.backgroundColor = UIColor.clear
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(menuButtonClicked), for: .touchUpInside)
//        button.setTitle("Hello", for: .normal)
        
//        button.setImage(image , for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(button)
        
        let topGuide = self.topLayoutGuide

        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topGuide, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        
        self.view.addConstraints([horizontalConstraint, verticalConstraint])
//        self.view.layoutSubviews() // this must be done for some reason to avoid a crash
    }
    
    @objc private func backButtonClicked(){
       _ = navigationController?.popViewController(animated: true)
    }
    
    @objc private func menuButtonClicked() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    private func setupButtonOnNavigationBarInternal(barButton: UIBarButtonItem) {
        let app: UIApplication = UIApplication.shared
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(app.statusBarFrame.size.height-4, -8, -(app.statusBarFrame.size.height-4), 8)
        
        // Make nav bar transparent
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        //do something
        print("scrolled\n")
    }
}

extension UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView){
        print("scrolled\n")
    }
}

//public extension UITableViewDelegate {
//    //ReverseExtension also supports handling UITableViewDelegate.
//     func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
//    }
//}

//extension UITableViewController {
//    
//    @objc func scrollViewDidScroll(_ scrollView: UIScrollView){
//        var frame: CGRect = self.floatingView.frame
//        frame.origin.y = scrollView.contentOffset.y
//        floatingView.frame = frame
//        
//        view.bringSubviewToFront(floatingView)
//    }
//}
