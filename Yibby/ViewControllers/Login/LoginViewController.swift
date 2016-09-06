//
//  LoginViewController.swift
//  Example
//
//  Created by Kishy Kumar on 2/13/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import XLPagerTabStrip

class LoginViewController: BaseYibbyViewController, IndicatorInfoProvider {

    // MARK: - Properties
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonOutlet: YibbyButton1!
    
    static let PASSWORD_KEY_NAME = "PASSWORD"
    static let EMAIL_ADDRESS_KEY_NAME = "EMAIL_ADDRESS"
    
    var onStartup = true
    
    // MARK: - Setup functions
    
    func setupDelegates() {
        emailAddress.delegate = self
        password.delegate = self
    }
    
    func setupUI() {
        loginButtonOutlet.color = UIColor.appDarkGreen1()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupDelegates()
        setupUI()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Login")
    }
    
    // MARK: - Actions
    @IBAction func loginAction(sender: AnyObject) {
        submitLoginForm()
    }
    
    // MARK: - KeyChain functions
    static func setKeyChainKeys (username: String, password: String) {
        KeychainWrapper.setString(username, forKey: LoginViewController.EMAIL_ADDRESS_KEY_NAME)
        KeychainWrapper.setString(password, forKey: LoginViewController.PASSWORD_KEY_NAME)
    }
    
    static func removeKeyChainKeys () {
        KeychainWrapper.removeObjectForKey(LoginViewController.EMAIL_ADDRESS_KEY_NAME)
        KeychainWrapper.removeObjectForKey(LoginViewController.PASSWORD_KEY_NAME)
    }
    
    static func getKeyChainKeys () -> (String?, String?) {
        let retrievedEmailAddress = KeychainWrapper.stringForKey(LoginViewController.EMAIL_ADDRESS_KEY_NAME)
        let retrievedPassword = KeychainWrapper.stringForKey(LoginViewController.PASSWORD_KEY_NAME)
        return (retrievedEmailAddress, retrievedPassword)
    }
    
    // MARK: - Helper functions
    
    func submitLoginForm() {
        if (emailAddress.text == "" || password.text == "") {
            AlertUtil.displayAlert("error in form", message: "Please enter email and password")
        } else {
            loginUser(emailAddress.text!, passwordi: password.text!)
        }
    }
    
    // BaasBox login user
    func loginUser(usernamei: String, passwordi: String) {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)

        let client: BAAClient = BAAClient.sharedClient()
        client.authenticateCaber(BAASBOX_RIDER_STRING, username: usernamei, password: passwordi, completion: {(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if (success) {
                DDLogVerbose("user logged in successfully \(success)")
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                // if login is successful, save username, password, token in keychain
                LoginViewController.setKeyChainKeys(usernamei, password: passwordi)
                
                appDelegate.sendGCMTokenToServer()
                
                if (self.onStartup) {
                    // switch to Main View Controller
                    MainViewController.initMainViewController(self, animated: true)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            else {
                DDLogVerbose("Error logging in: \(error)")

                if (error.domain == BaasBox.errorDomain() && error.code ==
                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {

                    // check for authentication error and redirect the user to Login page
                    AlertUtil.displayAlert("Username/password incorrect", message: "Please reenter user credentials and try again.")
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == emailAddress {
            
            password.becomeFirstResponder()
            return false
            
        } else if textField == password {
            
            password.resignFirstResponder()
            return false
            
        }
        
        return true
    }
}