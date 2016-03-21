//
//  LoginViewController.swift
//  Example
//
//  Created by Kishy Kumar on 2/13/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK

class LoginViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    static let PASSWORD_KEY_NAME = "PASSWORD"
    static let EMAIL_ADDRESS_KEY_NAME = "EMAIL_ADDRESS"
    
    let ACTIVITY_INDICATOR_TAG: Int = 1
    
    // MARK: functions
    @IBAction func loginAction(sender: AnyObject) {
        
        
        if (emailAddress.text == "" || password.text == "") {
            Util.displayAlert(self, title: "error in form", message: "Please enter email and password")
        } else {
            
            Util.enableActivityIndicator(self.view, tag: ACTIVITY_INDICATOR_TAG)
            
            loginUser(emailAddress.text!, passwordi: password.text!)
        }
    }
    
    // MARK: KeyChain functions
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
    
    // BaasBox login user
    func loginUser(usernamei: String, passwordi: String) {
        let client: BAAClient = BAAClient.sharedClient()
        client.authenticateUser(usernamei, password: passwordi, completion: {(success, error) -> Void in
            
            Util.disableActivityIndicator(self.view, tag: self.ACTIVITY_INDICATOR_TAG)
            
            if (success) {
                print("user logged in successfully \(success)")
                
                // if login is successful, save username, password, token in keychain
                LoginViewController.setKeyChainKeys(usernamei, password: passwordi)
                
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.initializeMainViewController()
                appDelegate.sendGCMTokenToServer()
                self.presentViewController(appDelegate.centerContainer!, animated: true, completion: nil)
            }
            else {
                Util.displayAlert(self, title: "Username/password incorrect", message: "Please reenter user credentials and try again.")
            }
        })
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}
