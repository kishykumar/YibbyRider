//
//  BaseYibbyViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 8/20/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import MMDrawerController
import CocoaLumberjack

open class BaseYibbyViewController: UIViewController {

    // MARK: - Properties
    
    let MENU_BUTTON_TAG = 6368 // MENU on number pad
    let BACK_BUTTON_TAG = 2225 // BACK on number pad
    
    // MARK: - Actions
    
    // MARK: - Setup functions
    
    override open func viewDidLoad() {
        super.viewDidLoad()

//        let app: UIApplication = UIApplication.shared
//        DDLogVerbose("KKDBG_status bar frame \(app.statusBarFrame.size.height)")
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.appBackgroundColor1();
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(statusBarFrameChanged),
//            name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
//            object: nil)
    }

//    func statusBarFrameChanged() {
//        let app: UIApplication = UIApplication.shared
//        DDLogVerbose("KKDBG_status bar changed \(app.statusBarFrame.size.height)")
//    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Following problems were dealth with when setting up menu and back button:
    // 1. Can't have navigation bar back button image because the button image overlays the status bar.
    //
    // 2. Problem with appending back button view to self.view because of scroll view issue. It moves along with that.
    //    NOTE: Now it's fixed and this is the solution. :)
    //
    // 3. Problem with appending back button to self.navigationController.view?
    //
    // 4. Problem with adding constraints because of the same reason as #2.

//    func setupBackButton() {
//        let app: UIApplication = UIApplication.shared
//
//        self.navigationController?.navigationBar.isHidden = true
//        
//        let backImage = UIImage.init(named: "back_button_green")!
//        let backButton = UIButton(type: .custom)
//        backButton.setImage(backImage, for: .normal)
//        
//        // get the image size and apply it to the button frame
//        let frame = CGRect(x: 0.0, y: 20.0, width: backImage.size.width, height: backImage.size.height)
//        backButton.frame = frame
//        
//        backButton.backgroundColor = UIColor.clear
//        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
//        backButton.tag = BACK_BUTTON_TAG
//        self.view.addSubview(backButton)
//    }
    
//    func setupMenuButton() {
//        let app: UIApplication = UIApplication.shared
//        
//        self.navigationController?.navigationBar.isHidden = true
//        
//        let menuImage = UIImage.init(named: "menu_icon_green")!
//        let menuButton = UIButton(type: .custom)
//        menuButton.setImage(menuImage, for: .normal)
//        
//        // get the image size and apply it to the button frame
////        let frame = CGRect(x: 0.0, y: app.statusBarFrame.size.height, width: menuImage.size.width, height: menuImage.size.height)
//        let frame = CGRect(x: 0.0, y: 20.0, width: menuImage.size.width, height: menuImage.size.height)
//        menuButton.frame = frame
//        
//        menuButton.backgroundColor = UIColor.clear
//        menuButton.addTarget(self, action: #selector(menuButtonClicked), for: .touchUpInside)
//        menuButton.tag = MENU_BUTTON_TAG
//        self.view.addSubview(menuButton)
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
