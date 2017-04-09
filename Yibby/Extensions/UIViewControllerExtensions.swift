//
//  UIViewControllerExtensions.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 12/03/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import MMDrawerController

extension UIViewController {
        
    func customBackButton(y: AnyObject){
        
        self.navigationController?.navigationBar.isHidden = true
        let backButton = UIButton(frame: CGRect(x: 0, y: y as! Int, width: 50, height: 59))
        backButton.setImage(UIImage(named: "back_button_green"), for: UIControlState.normal)
        backButton.backgroundColor = UIColor.clear
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    func customMenuButton(){
        self.navigationController?.navigationBar.isHidden = true
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 20, width: 50, height: 59))
        backButton.setImage(UIImage(named: "menu_icon_green"), for: UIControlState.normal)
        backButton.backgroundColor = UIColor.clear
        backButton.addTarget(self, action: #selector(menuButtonClicked), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    func backButtonClicked(){
       _ = navigationController?.popViewController(animated: true)
    }
    func menuButtonClicked(){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
}
