//
//  AddPaymentViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/12/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import Crashlytics
import BButton
import Braintree
import Stripe
import BaasBoxSDK
import CocoaLumberjack
import SwiftValidator

class AddPaymentViewController: BaseYibbyViewController,
                                CardIOPaymentViewControllerDelegate,
                                ValidationDelegate,
                                CardFieldsViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var cardFieldsViewOutlet: CardFieldsView!
    @IBOutlet weak var deleteCardButtonOutlet: YibbyButton1!
//    @IBOutlet weak var saveCardButtonOutlet: UIBarButtonItem!
//    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var scanCardButtonOutlet: UIButton!
    @IBOutlet weak var finishButtonOutlet: YibbyButton1!
    @IBOutlet weak var skipButtonOutlet: UIButton!
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    var cardViewValidationResult: CardValidationResult? = nil
    
    // TODO: Payment Type Icon
    //    var cardNumberField: BTUICardHint?
    
    // The STPAPIClient talks directly to Stripe to get the Token
    // given a payment card.
    //
    // Whereas, the StripeBackendAdapter is a protocol to talk to
    // our backend (baasbox) to handle payments.
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    var apiAdapter: StripeBackendAPIAdapter = StripeBackendAPI.sharedClient
    
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    var apiAdapter: BraintreeBackendAPIAdapter = BraintreeBackendAPI.sharedClient
    
    #endif
    
    var addDelegate : AddPaymentViewControllerDelegate?
    var editDelegate : EditPaymentViewControllerDelegate?
    var signupDelegate: SignupPaymentViewControllerDelegate?
    
    var isEditCard: Bool! = false   // implicitly unwrapped optional
    var isSignup: Bool! = false // implicitly unwrapped optional
    
    var paymentMethodToEdit: YBPaymentMethod!

    let validator = Validator()

    // MARK: - Actions
    @IBAction func deleteCardAction (_ sender: AnyObject) {
        
        if self.isSignup == true {
            assert(false)
        } else {
            
            // Raise an alert to confirm if the user actually wants to perform the action
            AlertUtil.displayChoiceAlertOnVC(self,
                 title: "Are you sure you want to delete the card?",
                 message: "",
                 completionActionString: InterfaceString.OK,
                 completionBlock: { () -> Void in
                    
                    ActivityIndicatorUtil.enableActivityIndicator(self.view)
                    
                    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
                        
                        self.editDelegate?.editPaymentViewController(self, didRemovePaymentMethod: paymentMethodToEdit, completion: {(error: NSError?) -> Void in
                            
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            
                            if let error = error {
                                self.handleCardTokenError(error)
                            }
                        })
                        
                    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
                        
                        self.editDelegate?.editPaymentViewController(editPaymentViewController: self, didRemovePaymentMethod: self.paymentMethodToEdit, completion: {(error: NSError?) -> Void in
                            
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            
                            if let error = error {
                                self.handleCardTokenError(error)
                            }
                        })
                        
                    #endif
                    
            })
        }
    }
    
    @IBAction func onSkipButtonClick(_ sender: UIButton) {
    
        sender.isUserInteractionEnabled = false
        self.signupDelegate?.signupPaymentViewControllerDidSkip(self)
    }
    
//    @IBAction func cancelButtonAction(_ sender: AnyObject) {
//        if (isEditCard == true) {
//            self.editDelegate?.editPaymentViewControllerDidCancel(self)
//        } else {
//            self.addDelegate?.addPaymentViewControllerDidCancel(self)
//        }
//    }
    
    @IBAction func scanCardAction(_ sender: AnyObject) {
        
        // if camera is disabled, display alert.
        if (CardIOUtilities.canReadCardWithCamera() == false) {
            AlertUtil.displayAlertOnVC(self,
                                       title: "Camera disabled.",
                                       message: "Please give Camera permission to Yibby.")
            return;
        }
        
        // display the cardIO view controller.
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        cardIOVC?.disableManualEntryButtons = true
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    @IBAction func finishBtnaction(_ sender: AnyObject) {
        validator.validate(self)
    }
    
//    func updatePaymentCard(nonce: String)
//    {
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//
//        BraintreePaymentService.sharedInstance().updateSourceForCustomer(nonce, oldPaymentMethod: paymentMethodToEdit.token!, completionBlock: {(error: Error?) -> Void in
//            ActivityIndicatorUtil.disableActivityIndicator(self.view)
//            if let error = error {
//                DDLogVerbose("Error PaymentMethod in: \(error)")
//                
//                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
//                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
//                    
//                    // check for authentication error and redirect the user to Login page
//                }
//                else {
//                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
//                }
//            }
//            else
//            {
//                DDLogVerbose("PaymentMethod updated successfully ")
//                
//                //back
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//        })
//    }

//    func deletePaymentCard()
//    {
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//        
//        let client: BAAClient = BAAClient.shared()
//        
//        client.deletePaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: paymentMethodToEdit.token, completion:{(success, error) -> Void in
//            
//            ActivityIndicatorUtil.disableActivityIndicator(self.view)
//            
//            if ((success) != nil) {
//                DDLogVerbose("PaymentMethod deleted successfully \(success)")
//                
//                //back
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//            else {
//                DDLogVerbose("Error PaymentMethod in: \(error)")
//                
//                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
//                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
//                    
//                    // check for authentication error and redirect the user to Login page
//                }
//                else {
//                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
//                }
//            }
//        })
//    }
    
    // MARK: - CardFieldsViewDelegate Delegate
    
    func cardTextField(cardFieldsView: CardFieldsView,
                       didEnterCardInformation information: Card,
                       withValidationResult validationResult: CardValidationResult) {
        self.cardViewValidationResult = validationResult
    }
    
    // MARK: - CardIO Delegate Functions
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        
        self.cardFieldsViewOutlet.prefillCardInformation(cardNumber: cardInfo.cardNumber, month: Int(cardInfo.expiryMonth), year: Int(cardInfo.expiryYear), cvc: cardInfo.cvv)
        
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Functions
    
    func setupUI() {
        setupBackButton()
        
        finishButtonOutlet.color = UIColor.appDarkGreen1()
        skipButtonOutlet.isHidden = true
        
        if (isEditCard == true) {
            
            deleteCardButtonOutlet.isHidden = false
            deleteCardButtonOutlet.setType(BButtonType.danger)
            
        } else if (isSignup == true) {
            self.navigationItem.hidesBackButton = true
            
            // Add the "ADD" button
            deleteCardButtonOutlet.isHidden = true
            // deleteCardButtonOutlet.setTitle(InterfaceString.Add, for: UIControlState())
            // deleteCardButtonOutlet.color = UIColor.appDarkGreen1()
            
            // TODO: Add the skip button
            skipButtonOutlet.isHidden = false
            
            // remove the cancel button
            self.navigationItem.leftBarButtonItems?.removeAll()
            
        } else {
            deleteCardButtonOutlet.isHidden = true
        }
    }
    
    func setupValidator() {
        validator.styleTransformers(success:{ (validationRule) -> Void in
            
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.appDarkGreen1().cgColor
            }
        }, error:{ (validationError) -> Void in
            
            //            validationError.errorLabel?.isHidden = false
            //            validationError.errorLabel?.text = validationError.errorMessage
            //
            //            if let textField = validationError.field as? UITextField {
            //                textField.setBottomBorder(UIColor.red)
            //            }
        })
        
        validator.registerField(cardFieldsViewOutlet.cardHolderNameTextField,
                                errorLabel: errorLabelOutlet ,
                                rules: [RequiredRule(message: "Full Name is required"), FullNameRule()])

        validator.registerField(cardFieldsViewOutlet.numberInputTextField,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Card Number is required")])
        
        validator.registerField(cardFieldsViewOutlet.monthTextField,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Month is required")])
        
        validator.registerField(cardFieldsViewOutlet.yearTextField,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Year is required")])
        
        validator.registerField(cardFieldsViewOutlet.cvcTextField,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "CVV is required")])
        
        validator.registerField(cardFieldsViewOutlet.postalCodeTextField,
                                errorLabel: self.errorLabelOutlet,
                                rules: [RequiredRule(message: "Postal code is required")])
    }
    
    func setupDelegates() {
        self.cardFieldsViewOutlet.cardFieldsViewDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        CardIOUtilities.preload()
        
        if isEditCard == true {
            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
                
                self.cardFieldsViewOutlet.numberInputTextField.placeholder = "************" + card.last4()
                
            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE

                self.cardFieldsViewOutlet.numberInputTextField.placeholder = "************" + paymentMethodToEdit.last4!
                self.cardFieldsViewOutlet.monthTextField.text = String(paymentMethodToEdit.expirationMonth!)
                self.cardFieldsViewOutlet.yearTextField.text = String(paymentMethodToEdit.expirationYear!)
                self.cardFieldsViewOutlet.postalCodeTextField.text = String(paymentMethodToEdit.postalCode!)

            #endif
        }
        
        setupUI()
        setupDelegates()
        setupValidator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.skipButtonOutlet.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ValidationDelegate Methods
    
    func validationSuccessful() {
        
        if (self.cardViewValidationResult != .Valid) {
            errorLabelOutlet.isHidden = false
            
            if let validationErrorStrings = self.cardViewValidationResult?.toString() {
                errorLabelOutlet.text = (validationErrorStrings.count != 0) ? validationErrorStrings.first : "Unrecognized Card Input Error"
            }
        } else {
            self.saveCard()
        }
    }
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        
        var errorDict: [UITextField:ValidationError] = [:]

        // put the array elements in a dictionary
        for error in errors {
        
            let (_, validationError) = error
            
            if let textField = validationError.field as? UITextField {
                errorDict[textField] = validationError
            }
        }
        
        if let validationError = errorDict[cardFieldsViewOutlet.cardHolderNameTextField] {
            cardFieldsViewOutlet.cardHolderNameTextField.layer.borderColor = UIColor.red.cgColor
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        } else if let validationError = errorDict[cardFieldsViewOutlet.numberInputTextField] {
            cardFieldsViewOutlet.numberInputTextField.layer.borderColor = UIColor.red.cgColor
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        } else if let validationError = errorDict[cardFieldsViewOutlet.monthTextField] {
            cardFieldsViewOutlet.monthTextField.layer.borderColor = UIColor.red.cgColor
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        } else if let validationError = errorDict[cardFieldsViewOutlet.yearTextField] {
            cardFieldsViewOutlet.yearTextField.layer.borderColor = UIColor.red.cgColor
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        } else if let validationError = errorDict[cardFieldsViewOutlet.cvcTextField] {
            cardFieldsViewOutlet.cvcTextField.layer.borderColor = UIColor.red.cgColor
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        } else if let validationError = errorDict[cardFieldsViewOutlet.postalCodeTextField] {
            cardFieldsViewOutlet.postalCodeTextField.layer.borderColor = UIColor.red.cgColor
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        }
    }
    
    // MARK: - Helper functions
    
    func handleCardTokenError(_ error: NSError) {
        AlertUtil.displayAlertOnVC(self, title: error.localizedDescription, message: error.localizedFailureReason ?? "")
    }
    
    func saveCard() {
        
        let number = cardFieldsViewOutlet.numberInputTextField.text
        let expMonth = cardFieldsViewOutlet.monthTextField.text
        let expYear = cardFieldsViewOutlet.yearTextField.text
        let cvc = cardFieldsViewOutlet.cvcTextField.text
        let postalcard = cardFieldsViewOutlet.postalCodeTextField.text
        let name = cardFieldsViewOutlet.cardHolderNameTextField.text

        // Define the closure for adding the card
        let addCardCodeBlock = { () -> Void in
            
            let cardClient: BTCardClient = BTCardClient(apiClient: BraintreePaymentService.sharedInstance().apiClient!)
            
            let card: BTCard = BTCard(number: number!,
                                      expirationMonth: expMonth!,
                                      expirationYear: expYear!,
                                      cvv: cvc!
            )
            
            card.postalCode = postalcard
            card.cardholderName = name
            
            cardClient.tokenizeCard(card, completion: {(tokenized: BTCardNonce?, error: Error?) -> Void in
                
                if (tokenized != nil) {
                    
                    if let error = error {
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        self.handleCardTokenError(error as NSError)
                    }
                    else {
                        
                        // TODO: We save the zipcode
                        if self.isEditCard == true {
                            
                            self.editDelegate?.editPaymentViewController(editPaymentViewController: self, didCreateNewNonce: tokenized!,
                                 oldPaymentMethod: self.paymentMethodToEdit, completion: {(error: NSError?) -> Void in
                                    
                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                    if let error = error {
                                        self.handleCardTokenError(error)
                                    }
                            })
                            
                        }
                        else if self.isSignup == true {
                            self.signupDelegate?.signupPaymentViewController(addPaymentViewController: self, didCreateNonce: tokenized!, completion: {(error: NSError?) -> Void in
                                
                                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                if let error = error {
                                    self.handleCardTokenError(error)
                                }
                            })
                        } else {
                            
                            self.addDelegate?.addPaymentViewController(addPaymentViewController: self,
                                                                       didCreateNonce: tokenized!,
                                                                       completion: {(error: NSError?) -> Void in
                                                                        
                                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                
                                if let error = error {
                                    self.handleCardTokenError(error)
                                }
                            })
                        }
                    }
                }
                else {
                    
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                    AlertUtil.displayAlertOnVC(self, title: "Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            })
        }
        
        #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
            
            let apiClient = StripePaymentService.sharedInstance().apiClient!
            
            apiClient.createTokenWithCard(cardParams, completion: {(token: STPToken?, tokenError: NSError?) -> Void in
                
                if let tokenError = tokenError {
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                    self.handleCardTokenError(tokenError)
                }
                else {
                    //                var phone: String = self.rememberMePhoneCell.contents
                    //                var email: String = self.emailCell.contents
                    
                    // TODO: We save the zipcode
                    if self.isEditCard == true {
                        
                        self.editDelegate?.editPaymentViewController(self, didCreateNewToken: token!, completion: {(error: NSError?) -> Void in
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            if let error = error {
                                self.handleCardTokenError(error)
                            }
                        })
                    } else if self.isSignup == true {
                        self.signupDelegate?.signupPaymentViewController(self, didCreateToken: token!, completion: {(error: NSError?) -> Void in
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            if let error = error {
                                self.handleCardTokenError(error)
                            }
                        })
                    } else {
                        self.addDelegate?.addPaymentViewController(self, didCreateToken: token!, completion: {(error: NSError?) -> Void in
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            if let error = error {
                                self.handleCardTokenError(error)
                            }
                        })
                    }
                }
            })
        #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
            
            ActivityIndicatorUtil.enableActivityIndicator(self.view)

            if BraintreePaymentService.sharedInstance().apiClient != nil {
                addCardCodeBlock()
            } else {
   
                BraintreePaymentService.sharedInstance().setupConfiguration({ (error: NSError?) -> Void in
                    
                    if (error != nil) {
                        DDLogError("Error in Braintree setup: \(String(describing: error))")
                        AlertUtil.displayAlertOnVC(self, title: "Payment Setup Error", message: (error?.localizedDescription) ?? "")
                    } else {
                        addCardCodeBlock()
                    }
                })
            }
        #endif
    }
}
