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
import Braintree
import DigitsKit
import SwiftValidator
import PhoneNumberKit
import AccountKit

class SignupViewController: BaseYibbyViewController,
                            IndicatorInfoProvider,
                            ValidationDelegate,
                            SignupPaymentViewControllerDelegate,
                            UITextFieldDelegate,
                            AKFViewControllerDelegate {

    // MARK: - Properties
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var emailAddressOutlet: UITextField!
    @IBOutlet weak var phoneNumberOutlet: PhoneNumberTextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var signupButtonOutlet: YibbyButton1!
    @IBOutlet weak var tandcButtonOutlet: UIButton!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    // flag to test creating the same user without calling the webserver.
    fileprivate let testMode = false
    
    fileprivate let MAX_PHONE_NUMBER_TEXTFIELD_LENGTH = 14 // includes 10 digits, 1 paranthesis "()", 1 hyphen "-", and 1 space " "

    fileprivate let validator = Validator()

    fileprivate var accountKit: AKFAccountKit!
    fileprivate var formattedPhoneNumber: String?
    
    // MARK: - Actions
    
    @IBAction func submitFormButton(_ sender: UIButton) {
        submitForm()
    }
    
    @IBAction func tncButtonAction(_ sender: AnyObject) {
        let url = URL(string: "https://google.com")!
        UIApplication.shared.openURL(url)
    }
    
    // MARK: - Setup functions
    
    func setupUI() {
        signupButtonOutlet.color = UIColor.appDarkGreen1()
        
        let attrTitle = NSAttributedString(string: InterfaceString.Button.TANDC,
                            attributes: [NSForegroundColorAttributeName : UIColor.appDarkGreen1(),
                            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 12.0),
                            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        tandcButtonOutlet.setAttributedTitle(attrTitle, for: UIControlState())
        
        phoneNumberOutlet.defaultRegion = "US"
    }
    
    func setupDelegates() {
        nameOutlet.delegate = self
        emailAddressOutlet.delegate = self
        phoneNumberOutlet.delegate = self
        passwordOutlet.delegate = self
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
        
        validator.registerField(nameOutlet, errorLabel: errorLabelOutlet , rules: [RequiredRule(message: "Full Name is required"), FullNameRule()])
        
        validator.registerField(emailAddressOutlet,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Email Address is required"), EmailRule()])
        
        validator.registerField(phoneNumberOutlet,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Phone number is required"),
                                        MinLengthRule(length: MAX_PHONE_NUMBER_TEXTFIELD_LENGTH,
                                                      message: "Must be at least 10 characters long")])
        
        validator.registerField(passwordOutlet,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Password is required"), YBPasswordRule()])
    }

    fileprivate func initProperties() {
        self.accountKit = AKFAccountKit(responseType: .accessToken)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initProperties()
        setupDelegates()
        setupUI()
        setupValidator()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.signupButtonOutlet.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ValidationDelegate Methods
    
    func validationSuccessful() {

        var formattedPhoneNumber = self.phoneNumberOutlet.text
        
        formattedPhoneNumber =
            formattedPhoneNumber?.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
        formattedPhoneNumber =
            formattedPhoneNumber?.replacingOccurrences(of: ")", with: "", options: .literal, range: nil)
        formattedPhoneNumber =
            formattedPhoneNumber?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        formattedPhoneNumber =
            formattedPhoneNumber?.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
        
        self.formattedPhoneNumber = formattedPhoneNumber
        verifyPhoneNumber(formattedPhoneNumber!)
        
//        let digits = Digits.sharedInstance()
//        let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
//        // configuration?.phoneNumber = self.txtPhone.text!
//
//        let digitsAppearance = DGTAppearance()
//
//        digitsAppearance.accentColor = UIColor.appDarkGreen1()
//        digitsAppearance.applyUIAppearanceColors()
//        configuration?.appearance = digitsAppearance
//        configuration?.phoneNumber = formattedPhoneNumber
//
//        digits.authenticate(with: nil, configuration: configuration!) { session, error in
//
//            if((error?.localizedDescription) != nil) {
//                digits.logOut()
//            }
//            else {
//                digits.logOut()
//
//                // self.phoneNumberOutlet.text =  (session?.phoneNumber)!
//
//                self.createUser(self.nameOutlet.text!, emaili: self.emailAddressOutlet.text!,
//                                phoneNumberi: formattedPhoneNumber!, passwordi: self.passwordOutlet.text!)
//            }
//            // Country selector will be set to Spain and phone number field will be set to 5555555555
//        }
    }
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        
        var errorDict: [UITextField:ValidationError] = [:]
        var errorTextField: UITextField = self.nameOutlet
        var verror: ValidationError?
        
        // put the array elements in a dictionary
        for error in errors {
            
            let (_, validationError) = error
            
            if let textField = validationError.field as? UITextField {
                errorDict[textField] = validationError
            }
        }
        
        if let validationError = errorDict[nameOutlet] {
            errorTextField = nameOutlet
            verror = validationError
        } else if let validationError = errorDict[self.phoneNumberOutlet] {
            errorTextField = self.phoneNumberOutlet
            verror = validationError
        } else if let validationError = errorDict[self.emailAddressOutlet] {
            errorTextField = self.emailAddressOutlet
            verror = validationError
        } else if let validationError = errorDict[self.passwordOutlet] {
            errorTextField = self.passwordOutlet
            verror = validationError
        }
        
        verror!.errorLabel?.isHidden = false
        verror!.errorLabel?.text = verror!.errorMessage
        
        errorTextField.setBottomBorder(UIColor.red)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - Helper Functions
    
    fileprivate func verifyPhoneNumber(_ formattedPhoneNumber: String) {
        
        let prefillPhoneNumber = AKFPhoneNumber(countryCode: "+1", phoneNumber: formattedPhoneNumber)
        let inputState: String = UUID().uuidString
        
        if let viewController = self.accountKit.viewControllerForPhoneLogin(with: prefillPhoneNumber, state: inputState) as? AKFViewController {
            prepareLoginViewController(viewController)
            
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
        loginViewController.delegate = self
        loginViewController.enableGetACall = true
    }
    
    func submitForm() {
        validator.validate(self)
    }
  
    // BaasBox create user
    
    func createUser(_ usernamei: String, emaili: String, phoneNumberi: String, passwordi: String) {
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
            ActivityIndicatorUtil.enableActivityIndicator(self.view)

            let client: BAAClient = BAAClient.shared()
            
            client.createCaber(BAASBOX_RIDER_STRING, name: usernamei, email: emaili, phoneNumber: phoneNumberi, password: passwordi, completion:{(success, error) -> Void in
                if (success || self.testMode) {
                    DDLogVerbose("Success signing up: \(success)")
                    
                    // if login is successful, save username, password, token in keychain
                    LoginViewController.setLoginKeyChainKeys(usernamei, password: passwordi)
                    
                    let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
                    let apViewController = paymentStoryboard.instantiateViewController(withIdentifier: "AddPaymentViewControllerIdentifier") as! AddPaymentViewController
                    
                    apViewController.signupDelegate = self
                    apViewController.isSignup = true
                    
                    self.navigationController!.pushViewController(apViewController, animated: true)
                }
                else {
                    DDLogVerbose("Signup failed: \(String(describing: error))")
                    errorBlock(success, error)
                }
                self.signupButtonOutlet.isUserInteractionEnabled = true
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
            })
        })
    }

    // MARK: - IndicatorInfoProvider
 
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: InterfaceString.Join.Signup)
    }

    // MARK: - SignupPaymentViewControllerDelegate

    func signupPaymentViewControllerDidSkip(_ addPaymentViewController: AddPaymentViewController) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initializeApp()
    }
    
    func signupPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                     didCreateNonce paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock) {

        
        BraintreePaymentService.sharedInstance().attachSourceToCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
            
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.initializeApp()
            }
        })
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameOutlet {
            
            phoneNumberOutlet.becomeFirstResponder()
            return false
            
        } else if textField == phoneNumberOutlet {
            
            emailAddressOutlet.becomeFirstResponder()
            return false
            
        } else if textField == emailAddressOutlet {
            
            passwordOutlet.becomeFirstResponder()
            return false

        } else if textField == passwordOutlet {
            
            passwordOutlet.resignFirstResponder()
            return false
            
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == phoneNumberOutlet) {
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
    
    // MARK: - AKFViewControllerDelegate extension
    
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        // login success
        DDLogVerbose("Login Success")
        
        accountKit.logOut()
        
        // disable login button
        self.signupButtonOutlet.isUserInteractionEnabled = false
        
        self.createUser(self.nameOutlet.text!, emaili: self.emailAddressOutlet.text!,
                        phoneNumberi: self.formattedPhoneNumber!, passwordi: self.passwordOutlet.text!)
    }
    
    func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
        // login failed
        DDLogVerbose("\(viewController) did fail with error: \(error)")
        accountKit.logOut()
    }
}
