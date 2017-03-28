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
import SwiftKeychainWrapper
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: BaseYibbyViewController, IndicatorInfoProvider,GIDSignInUIDelegate,GIDSignInDelegate {

    // MARK: - Properties
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonOutlet: YibbyButton1!
    
    static let PASSWORD_KEY_NAME = "PASSWORD"
    static let EMAIL_ADDRESS_KEY_NAME = "EMAIL_ADDRESS"
    
    var onStartup = true
    
    let testMode = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: InterfaceString.Join.Login)
    }
    
    // MARK: - Actions
    @IBAction func loginAction(_ sender: AnyObject) {
        submitLoginForm()
    }
    
    // MARK: - KeyChain functions
    static func setLoginKeyChainKeys (_ username: String, password: String) {
        let ret = KeychainWrapper.standard.set(username, forKey: LoginViewController.EMAIL_ADDRESS_KEY_NAME)
        print("Keychain set value for email : \(ret)")
        KeychainWrapper.standard.set(password, forKey: LoginViewController.PASSWORD_KEY_NAME)
    }
    
    static func removeLoginKeyChainKeys () {
        KeychainWrapper.standard.remove(key: LoginViewController.EMAIL_ADDRESS_KEY_NAME)
        KeychainWrapper.standard.remove(key: LoginViewController.PASSWORD_KEY_NAME)
    }
    
    static func getLoginKeyChainValues () -> (String?, String?) {
        let retrievedEmailAddress = KeychainWrapper.standard.string(forKey: LoginViewController.EMAIL_ADDRESS_KEY_NAME)
        let retrievedPassword = KeychainWrapper.standard.string(forKey: LoginViewController.PASSWORD_KEY_NAME)
        return (retrievedEmailAddress, retrievedPassword)
    }
    
    // MARK: - Helper functions
    
    func submitLoginForm() {
        
        loginUser("k", passwordi: "k")
        //MainViewController.initMainViewController(self, animated: true)
        
        /*let validateText = TextfieldValidations()
        
        let allData = validateText.validateEmptyTextfieldsOnly(superView: self.emailAddress.superview!)
        
        print("allData :: \(allData)")
        if allData.boolValue == false {
            
            AlertUtil.displayAlert("error in form", message: "\(allData.textPlaceHolder)")
            
        }else{
            
            loginUser(emailAddress.text!, passwordi: password.text!)
        }*/
        
//        if (emailAddress.text == "" || password.text == "") {
//            AlertUtil.displayAlert("error in form", message: "Please enter email and password")
//        } else {
//            loginUser(emailAddress.text!, passwordi: password.text!)
//        }
    }
    
    
    
//    (void)getProfile: (NSString *)type
//    completion: (BAAObjectResultBlock)completionBlock {
    
    
    /*func getProfile(_ type: String!, completion completionBlock: BaasBoxSDK.BAAObjectResultBlock!)
    
     createCaber:(NSString *)type
     name: (NSString *)name
     email: (NSString *)email
     phoneNumber: (NSString *)phoneNumber
     password:(NSString *)password
     completion:(BAABooleanResultBlock)completionBlock
     
    func createUser(_ usernamei: String, emaili: String, phoneNumberi: String, passwordi: String) {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.createCaber(BAASBOX_RIDER_STRING, name: usernamei, email: emaili, phoneNumber: phoneNumberi, password: passwordi, completion:{(success, error) -> Void in
            if (success || self.testMode) {
                DDLogVerbose("Success signing up: \(success)")*/
                
                
                
                
    // BaasBox login user
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
        //print("Sign in presented")
    }
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        // print("Sign in dismissed")
    }
    func loginUser(_ usernamei: String, passwordi: String) {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)

        let client: BAAClient = BAAClient.shared()
        client.authenticateCaber(BAASBOX_RIDER_STRING, username: usernamei, password: passwordi, completion: {(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if (success) {
                DDLogVerbose("user logged in successfully \(success)")
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                
                // if login is successful, save username, password, token in keychain
                LoginViewController.setLoginKeyChainKeys(usernamei, password: passwordi)
                
                if (self.onStartup) {
                    // switch to Main View Controller
                    MainViewController.initMainViewController(self, animated: true)
                } else {
                    appDelegate.sendGCMTokenToServer()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                DDLogVerbose("Error logging in: \(error)")

                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
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
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if user != nil {
            
            
            let userId:NSString = user.userID as NSString                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName:NSString = user.profile.name as NSString
         
            let email:NSString = user.profile.email as NSString
            let img =   user.profile.imageURL(withDimension: 200)
         
         
            // WebserviceForSocialRes(id: userId , reg: "s", email: email, userNmae: fullName)
        /*    let params = [
                "name": givenName ,
                "social_id": userId as String ,
                "Email": email as String,
                "lat": self.strLat,
                "long": self.strLong,
                "social_username": givenName,
                "social_type": "google",
                "social_pic": String(describing: img!),
                "location": self.location,
                "deviceid":"12345678"
            ]
            print(params)
            let url = URLBASE + URLSOCIALLOGIN
            self.WebserviceForSignIn(params as NSDictionary, url: url)*/
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
    }
    @IBAction func facebookAction(_ sender: Any) {
        stringSocial = "facebook"
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email","public_profile","user_friends"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
            }
        }
        
    }
    @IBAction func GoogleAction(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().signIn()

    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: {
                (connection, result, error) -> Void in
                if (error == nil){
                    
                  //  self.stotLoader()
                    let resultdict = result as! NSDictionary
                    
                    print(result)
                    let params = [
                        "name": resultdict.value(forKey: "name") as! String,
                        "social_id": resultdict.value(forKey: "id") as! String ,
                        "Email": resultdict.value(forKey: "email") as! String,
                        //"lat": self.strLat,
                      //  "long": self.strLong,
                        "social_username": resultdict.value(forKey: "name") as! String,
                        "social_type": "facebook",
                        "social_pic": resultdict.value(forKeyPath: "picture.data.url") as! String,
                       // "location": self.location,
                        "deviceid":"12345678"
                    ]
                    print(params)
                   // let url = URLBASE + URLSOCIALLOGIN
                    //self.WebserviceForSignIn(params as NSDictionary, url: url)
                    
                }
                else
                {
                   // self.stotLoader()
                    
                }
            })
            
            
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
