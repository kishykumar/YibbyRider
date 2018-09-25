//
//  LoginViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 2/13/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import XLPagerTabStrip
import SwiftKeychainWrapper
import SwiftValidator
import PhoneNumberKit
import GoogleSignIn
import FBSDKLoginKit
import Alamofire

class LoginViewController: BaseYibbyViewController,
                            IndicatorInfoProvider,
                            GIDSignInUIDelegate,
                            GIDSignInDelegate,
                            ValidationDelegate,
                            UITextFieldDelegate {

    // MARK: - Properties
    @IBOutlet weak var phoneNumberTextFieldOutlet: PhoneNumberTextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonOutlet: YibbyButton1!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    static let PASSWORD_KEY_NAME = "PASSWORD"
    static let PHONE_NUMBER_KEY_NAME = "PHONE_NUMBER"
    
    let MAX_PHONE_NUMBER_TEXTFIELD_LENGTH = 14 // includes 10 digits, 1 paranthesis "()", 1 hyphen "-", and 1 space " "
    
    let validator = Validator()

//    var onStartup = true
    
    let testMode = false
    
    // MARK: - Actions
    @IBAction func loginAction(_ sender: UIButton) {
        submitLoginForm()
    }
    
    @IBAction func onForgotPasswordClick(_ sender: UIButton) {
        showForgotPasswordAlert()
    }
    
    // MARK: - Setup functions
    
    func setupDelegates() {
        phoneNumberTextFieldOutlet.delegate = self
        password.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func setupUI() {
        loginButtonOutlet.color = UIColor.appDarkGreen1()
        phoneNumberTextFieldOutlet.defaultRegion = "US"
        //phoneNumberTextFieldOutlet.text = "6505062136"
        //password.text = "Abcdef$123"
    }
    
    func setupValidator() {
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            
            if let textField = validationRule.field as? UITextField {
                textField.removeBottomBorder()
            }
        }, error:{ (validationError) -> Void in
            
//            validationError.errorLabel?.isHidden = false
//            validationError.errorLabel?.text = validationError.errorMessage
//            
//            if let textField = validationError.field as? UITextField {
//                textField.setBottomBorder(UIColor.red)
//            }
        })
        
        validator.registerField(phoneNumberTextFieldOutlet,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Phone number is required"),
                                        MinLengthRule(length: MAX_PHONE_NUMBER_TEXTFIELD_LENGTH,
                                                      message: "Must be at least 10 characters long")])
        
        validator.registerField(password,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Password is required")])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupDelegates()
        setupUI()
        setupValidator()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.loginButtonOutlet.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: InterfaceString.Join.Login)
    }
    
    // MARK: - KeyChain functions
    static func setLoginKeyChainKeys (_ username: String, password: String) {
        KeychainWrapper.standard.set(username, forKey: LoginViewController.PHONE_NUMBER_KEY_NAME)
        KeychainWrapper.standard.set(password, forKey: LoginViewController.PASSWORD_KEY_NAME)
    }
    
    static func removeLoginKeyChainKeys () {
        KeychainWrapper.standard.remove(key: LoginViewController.PHONE_NUMBER_KEY_NAME)
        KeychainWrapper.standard.remove(key: LoginViewController.PASSWORD_KEY_NAME)
    }
    
    static func getLoginKeyChainValues () -> (String?, String?) {
        let retrievedPhoneNumber = KeychainWrapper.standard.string(forKey: LoginViewController.PHONE_NUMBER_KEY_NAME)
        let retrievedPassword = KeychainWrapper.standard.string(forKey: LoginViewController.PASSWORD_KEY_NAME)
        return (retrievedPhoneNumber, retrievedPassword)
    }
    
    // MARK: - Helper functions
    
    fileprivate func showForgotPasswordAlert() {
        
        let alertVC = PMAlertController(title: "Enter your phone number", description: "We will send an email associated to your account to reset your password.", image: nil, style: .alert)
        
        alertVC.addPhoneNumberTextField { (textField) in
            textField?.placeholder = "Phone Number"
            textField?.keyboardType = .phonePad
        }
        
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alertVC.addAction(PMAlertAction(title: "Send", style: .default, action: { () in
            
            var phoneNumberFound = false
            if let phoneNumber = alertVC.textFields[0].text {

                if (phoneNumber != "") {
                    
                    phoneNumberFound = true
                    
                    self.dismiss(animated: true, completion: { () in
                        
                        let strippedPhoneNumber: String = phoneNumber.stripPhoneNumber()
                        
                        ActivityIndicatorUtil.enableActivityIndicator(self.view)
                        
                        let client: BAAClient = BAAClient.shared()
                        let user: BAAUser = BAAUser(dictionary: ["user":
                            ["name": strippedPhoneNumber,
                             "roles" : [],
                             "status": "",
                             "visibleByAnonymousUsers": [],
                             "visibleByRegisteredUsers": []
                            ]
                            ])
                        client.resetPassword(for: user, withCompletion: {(success, error) -> Void in
                            
                            if (success) {
                                AlertUtil.displayAlertOnVC(self, title: "Check your email!", message: "An email has been sent to the email address associated with this phone number.")
                            }
                            else {
                                AlertUtil.displayAlertOnVC(self, title: "Error!", message: (error?.localizedDescription) ?? "Please try again!")
                            }
                            
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        })
                    })
                }
            }
            
            if (phoneNumberFound == false) {
                // Underline the error
                alertVC.textFields[0].setBottomBorder(UIColor.red)
            }
            
        }))
        
        alertVC.gravityDismissAnimation = false
        alertVC.dismissWithBackgroudTouch = true
        
        self.present(alertVC, animated: true, completion: { () -> Void in
            
            // Show the keyboard as soon as the textfield alert is presented.
            alertVC.textFields[0].becomeFirstResponder()
        })
    }
    
    func submitLoginForm() {
//        emailAddress.text = "1111111111"
//        password.text = "1"
        
        // Perform text field validations
        validator.validate(self)
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
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
            ActivityIndicatorUtil.enableActivityIndicator(self.view)

            let client: BAAClient = BAAClient.shared()
            client.authenticateCaber(BAASBOX_RIDER_STRING, username: usernamei, password: passwordi, completion: {(success, error) -> Void in
                
                if (success) {
                    DDLogVerbose("user logged in successfully \(success)")
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    // if login is successful, save username, password, token in keychain
                    LoginViewController.setLoginKeyChainKeys(usernamei, password: passwordi)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        let error = appDelegate.initializeApp(true)
                        
                        DispatchQueue.main.async {
                            
                            if (error != nil) {
                                AlertUtil.displayAlertOnVC(self,
                                                           title: error!.localizedDescription, message: "Try again with logging in")
                            }

                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            self.loginButtonOutlet.isUserInteractionEnabled = true
                        }
                    }
                }
                else {
                    errorBlock(success, error)
                    
                    // enable the login button interaction if error
                    self.loginButtonOutlet.isUserInteractionEnabled = true
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                }
            })
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if user != nil && error == nil {

            let userId:NSString = user.userID as NSString      // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName:NSString = user.profile.name as NSString
            let email:NSString = user.profile.email as NSString
            let img =   user.profile.imageURL(withDimension: 200)
            DDLogVerbose("details are \(userId,fullName,email,img)")
         
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
            
        } else {
            DDLogVerbose("error signing in using google \(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
    }
    
    @IBAction func facebookAction(_ sender: Any) {
//
       AlertUtil.displayAlertOnVC(self,
                                   title: "Coming Soon!",
                                 message: "Please use our regular login flow.")
       return;
        
//        stringSocial = "facebook"
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logOut()
//        fbLoginManager.logIn(withReadPermissions: ["email","public_profile","user_friends"], from: self) { (result, error) -> Void in
//            if (error == nil){
//                let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                //if(fbloginresult.grantedPermissions.contains("email"))
//                //{
//                    self.getFBUserData()
//                    //fbLoginManager.logOut()
//                //}
//            }
//        }
    }
    
    @IBAction func GoogleAction(_ sender: Any) {
//
        AlertUtil.displayAlertOnVC(self,
                                   title: "Coming Soon!",
                                   message: "Please use our regular login flow.")
        return;
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().signIn()

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
                    print("facebook results",params)
                    print("token is", FBSDKAccessToken.current().tokenString)
//                    let user: BAAUser = BAAUser.init()
//                    user.linkToFacebook(withToken: FBSDKAccessToken.current().tokenString, completion: { (_, error) in
//                        if let error = error {
//                            DDLogVerbose("error while loging to bassbox using facebook \(error.localizedDescription)")
//                            return
//                        }
//
//                        let client: BAAClient = BAAClient.shared()
//                        DDLogVerbose("logged in with facebook \(client.currentUser)")
//
//
//                    })
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
    
    // MARK: - ValidationDelegate Methods
    
    func validationSuccessful() {
        if let formattedPhoneNumber = self.phoneNumberTextFieldOutlet.text?.stripPhoneNumber() {
        
            // disable the login button interaction
            self.loginButtonOutlet.isUserInteractionEnabled = false

            loginUser(formattedPhoneNumber, passwordi: password.text!)
        }
    }
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        
        var errorDict: [UITextField:ValidationError] = [:]
        var errorTextField: UITextField = self.phoneNumberTextFieldOutlet
        var verror: ValidationError?
        
        // put the array elements in a dictionary
        for error in errors {
            
            let (_, validationError) = error
            
            if let textField = validationError.field as? UITextField {
                errorDict[textField] = validationError
            }
        }
        
        if let validationError = errorDict[phoneNumberTextFieldOutlet] {
            errorTextField = phoneNumberTextFieldOutlet
            verror = validationError
        } else if let validationError = errorDict[self.password] {
            errorTextField = self.password
            verror = validationError
        }
        
        verror!.errorLabel?.isHidden = false
        verror!.errorLabel?.text = verror!.errorMessage
        
        errorTextField.setBottomBorder(UIColor.red)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == phoneNumberTextFieldOutlet {
            
            password.becomeFirstResponder()
            return false
            
        } else if textField == password {
            
            password.resignFirstResponder()
            return false
            
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == phoneNumberTextFieldOutlet) {
            if var str = textField.text {
                str = str + string
                if str.characters.count <= MAX_PHONE_NUMBER_TEXTFIELD_LENGTH {
                    return true
                }
                
                textField.text = str.substring(to: str.index(str.startIndex, offsetBy: MAX_PHONE_NUMBER_TEXTFIELD_LENGTH))
                return false
            }
        }
        
        return true
    }
}


