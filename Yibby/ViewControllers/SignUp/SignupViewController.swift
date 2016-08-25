//
//  SignupViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 2/28/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import XLPagerTabStrip

class SignupViewController: BaseYibbyViewController, IndicatorInfoProvider {

    // MARK: - Properties
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var emailAddressOutlet: UITextField!
    @IBOutlet weak var phoneNumberOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    
    let ACTIVITY_INDICATOR_TAG: Int = 1

    // MARK: - Actions
    @IBAction func submitFormButton(sender: UIButton) {
        if (emailAddressOutlet.text == "" || passwordOutlet.text == "") {
            AlertUtil.displayAlert("error in form", message: "Please enter email and password")
        } else {
            createUser(emailAddressOutlet.text!, passwordi: passwordOutlet.text!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: BaasBox Functions
    
    // BaasBox create user
    func createUser(usernamei: String, passwordi: String) {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)

        let client: BAAClient = BAAClient.sharedClient()
        client.createCaberWithUsername(BAASBOX_RIDER_STRING, username: usernamei, password: passwordi, completion: {(success, error) -> Void in
            if (success) {
                DDLogVerbose("Success signing up: \(success)")

                // if login is successful, save username, password, token in keychain
                LoginViewController.setKeyChainKeys(usernamei, password: passwordi)
                
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.initializeMainViewController()
                appDelegate.sendGCMTokenToServer()
                self.presentViewController(appDelegate.centerContainer!, animated: true, completion: nil)
            }
            else {
                DDLogVerbose("Signup failed: \(error)")
                AlertUtil.displayAlert("Signup failed.", message: "Please try again.")
            }
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
        })
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Sign up")
    }
}
