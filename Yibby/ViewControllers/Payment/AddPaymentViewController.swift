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


class AddPaymentViewController: BaseYibbyViewController, CardIOPaymentViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var cardFieldsViewOutlet: CardFieldsView!
    @IBOutlet weak var deleteCardButtonOutlet: YibbyButton1!
    @IBOutlet weak var saveCardButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var scanCardButtonOutlet: UIButton!
    @IBOutlet weak var finishButtonOutlet: YibbyButton1!
    
    var nonceStr = String()
    
    // TODO: Payment Type Icon
    //    var cardNumberField: BTUICardHint?
    
    // The STPAPIClient talks directly to Stripe to get the Token
    // given a payment card.
    //
    // Whereas, the StripeBackendAdapter is a protocol to talk to
    // our backend (baasbox) to handle payments.
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    var apiAdapter: StripeBackendAPIAdapter = StripeBackendAPI.sharedClient
    var cardToBeEdited: STPCard?
    
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    var apiAdapter: BraintreeBackendAPIAdapter = BraintreeBackendAPI.sharedClient
    var cardToBeEdited: BTPaymentMethodNonce?
    
    #endif
    
    var addDelegate : AddPaymentViewControllerDelegate?
    var editDelegate : EditPaymentViewControllerDelegate?
    var signupDelegate: SignupPaymentViewControllerDelegate?
    
    var isEditCard: Bool! = false   // implicitly unwrapped optional
    var isSignup: Bool! = false // implicitly unwrapped optional
    var updatecardToken = String()
    var Cardmodel = PaymentDetailsObject()

    // MARK: - Actions
    @IBAction func deleteCardAction(_ sender: AnyObject) {
        
        if self.isSignup == true {
            
            // add this card
            saveCard()
            return;
            
        } else {
            
            // Raise an alert to confirm if the user actually wants to perform the action
            AlertUtil.displayChoiceAlert("Are you sure you want to delete the card?",
                                         message: "",
                                         completionActionString: InterfaceString.OK,
                                         completionBlock: { () -> Void in
                                            
                                            ActivityIndicatorUtil.enableActivityIndicator(self.view)
                                            
                                            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
                                                
                                                self.editDelegate?.editPaymentViewController(self, didRemovePaymentMethod: self.cardToBeEdited!, completion: {(error: NSError?) -> Void in
                                                    
                                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                                    
                                                    if let error = error {
                                                        self.handleCardTokenError(error)
                                                    }
                                                })
                                                
                                            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
                                                
                                                self.editDelegate?.editPaymentViewController(editPaymentViewController: self, didRemovePaymentMethod: self.updatecardToken, completion: {(error: NSError?) -> Void in
                                                    
                                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                                    
                                                    if let error = error {
                                                        self.handleCardTokenError(error)
                                                    }
                                                })
                                                
                                            #endif
                                            
            })
        }
    }
    
    @IBAction func saveButtonAction(_ sender: AnyObject) {
        
        if isSignup == true {
            
            // skip this step
            self.signupDelegate?.signupPaymentViewControllerDidSkip(self)
            
            return;
        }
        
        saveCard()
    }
    
    @IBAction func cancelButtonAction(_ sender: AnyObject) {
        if (isEditCard == true) {
            self.editDelegate?.editPaymentViewControllerDidCancel(self)
        } else {
            self.addDelegate?.addPaymentViewControllerDidCancel(self)
        }
    }
    
    @IBAction func scanCardAction(_ sender: AnyObject) {
        
        // if camera is disabled, display alert.
        if (CardIOUtilities.canReadCardWithCamera() == false) {
            AlertUtil.displayAlert("Camera disabled.", message: "Please give Camera permission to Yibby.")
            return;
        }
        
        // display the cardIO view controller.
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        cardIOVC?.disableManualEntryButtons = true
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    @IBAction func finishBtnaction(_ sender: AnyObject)
    {
        
        if cardToBeEdited != nil {
            // updatePaymentCard()
            self.saveCard()
            
        }
        else{
            self.saveCard()
        }
        //_ = navigationController?.popViewController(animated: true)
        
    }
    
    func updatePaymentCard(nonce: String)
    {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
    
        BraintreePaymentService.sharedInstance().updateSourceForCustomerstring(nonce, oldPaymentMethod: self.updatecardToken, completionBlock: {(error: Error?) -> Void in
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            if let error = error {
                DDLogVerbose("Error PaymentMethod in: \(error)")
                
                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                    
                    // check for authentication error and redirect the user to Login page
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
            else
            {
                DDLogVerbose("PaymentMethod updated successfully ")
                
                //back
                _ = self.navigationController?.popViewController(animated: true)
            }
        })
        
      /*  let client: BAAClient = BAAClient.shared()
        
        client.updatePaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: "4phrcj", paymentMethodNonce: self.nonceStr, completion: {(success, error) -> Void in
            
            print(success as Any)
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if ((success) != nil) {
                DDLogVerbose("PaymentMethod updated successfully \(success)")
                
                //back
                _ = self.navigationController?.popViewController(animated: true)
            }
            else {
                DDLogVerbose("Error PaymentMethod in: \(error)")
                
                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                    
                    // check for authentication error and redirect the user to Login page
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })*/
    }
    
    
 
    
    func deletePaymentCard()
    {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.deletePaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: updatecardToken, completion:{(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if ((success) != nil) {
                DDLogVerbose("PaymentMethod deleted successfully \(success)")
                
                //back
                _ = self.navigationController?.popViewController(animated: true)
            }
            else {
                DDLogVerbose("Error PaymentMethod in: \(error)")
                
                if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                    
                    // check for authentication error and redirect the user to Login page
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })
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
        
        finishButtonOutlet.color = UIColor(red: 45/255, green: 195/255, blue: 89/255, alpha: 1)
        
        if (isEditCard == true) {
            
            deleteCardButtonOutlet.isHidden = false
            deleteCardButtonOutlet.setType(BButtonType.danger)
            
        } else if (isSignup == true) {
            self.navigationItem.hidesBackButton = true
            
            deleteCardButtonOutlet.isHidden = false
            deleteCardButtonOutlet.setTitle(InterfaceString.Add, for: UIControlState())
            deleteCardButtonOutlet.color = UIColor.appDarkGreen1()
            
            saveCardButtonOutlet.title = InterfaceString.Skip
            
            // remove the cancel button
            self.navigationItem.leftBarButtonItems?.removeAll()
            
        } else {
            deleteCardButtonOutlet.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        CardIOUtilities.preload()
        
             if isEditCard == true {
            // cardParams.number will have the last 4 of the card
            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
                self.cardFieldsViewOutlet.numberInputTextField.placeholder = "************" + card.last4()
            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
                self.cardFieldsViewOutlet.numberInputTextField.placeholder = "************" + Cardmodel.last4
                self.cardFieldsViewOutlet.monthTextField.text = Cardmodel.expirationMonth
                self.cardFieldsViewOutlet.yearTextField.text = Cardmodel.expirationYear
                self.cardFieldsViewOutlet.postalCodeTextField.text = Cardmodel.postalCode

            #endif
            
        }
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
    
    // MARK: - Helper functions
    
    func handleCardTokenError(_ error: NSError) {
        AlertUtil.displayAlert(error.localizedDescription, message: error.localizedFailureReason ?? "")
    }
    
    func isInputCardValid() -> Bool {
        //        cardFieldsViewOutlet.numberInputTextField.
        //        cardFieldsViewOutlet.monthTextField.isInputValid(cardFieldsViewOutlet.monthTextField.text!, partiallyValid: <#T##Bool#>)
        return true;
    }
    
    func saveCard() {
        
        if !isInputCardValid() {
            return;
        }
        
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let number = cardFieldsViewOutlet.numberInputTextField.text
        let expMonth = cardFieldsViewOutlet.monthTextField.text
        let expYear = cardFieldsViewOutlet.yearTextField.text
        let cvc = cardFieldsViewOutlet.cvcTextField.text
        let postalcard = cardFieldsViewOutlet.postalCodeTextField.text
        let name = cardFieldsViewOutlet.cardHolderNameTextField.text

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
            
            let cardClient: BTCardClient = BTCardClient(apiClient: BraintreePaymentService.sharedInstance().apiClient!)
            
            let card: BTCard = BTCard(number: number!,
                                      expirationMonth: expMonth!,
                                      expirationYear: expYear!,
                                      cvv: cvc!
                                      )
            card.postalCode = postalcard
            card.cardholderName = name
            
            cardClient.tokenizeCard(card, completion: {(tokenized: BTCardNonce?, error: Error?) -> Void in
                
                if (tokenized != nil)
                {
                self.nonceStr = (tokenized?.nonce as AnyObject) as! String
                
                if let error = error {
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                    self.handleCardTokenError(error as NSError)
                }
                else {
                    //                var phone: String = self.rememberMePhoneCell.contents
                    //                var email: String = self.emailCell.contents
                    
                    // TODO: We save the zipcode
                    if self.isEditCard == true {
                        
                                                self.editDelegate?.editPaymentViewController(editPaymentViewController: self, didCreateNewToken: tokenized!, completion: {(error: NSError?) -> Void in
                                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                                    if let error = error {
                                                        self.handleCardTokenError(error)
                                                    }
                                                })
                        
                      //  self.updatePaymentCard(nonce: (tokenized?.nonce)!)
                        
                        
                    }
                    else if self.isSignup == true {
                        self.signupDelegate?.signupPaymentViewController(addPaymentViewController: self, didCreateNonce: tokenized!, completion: {(error: NSError?) -> Void in
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            if let error = error {
                                self.handleCardTokenError(error)
                            }
                        })
                    } else {
                        self.addDelegate?.addPaymentViewController(addPaymentViewController: self, didCreateNonce: tokenized!, completion: {(error: NSError?) -> Void in
                            
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            
                            if error != nil
                            {
                                DDLogVerbose("Error PaymentMethod in: \(error)")
                                
                                if (error?.domain == BaasBox.errorDomain() && error?.code ==
                                    WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
                                    
                                    // check for authentication error and redirect the user to Login page
                                }
                                else {
                                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                                }
                                
                            }
                            else
                            {
                                DDLogVerbose("PaymentMethod added successfully ")
                                
                                //back
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            
                            
                            
                            
                        })
                    }
                }
                }
                else
                {
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)

                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")

                }
            })
            
        #endif
    }
    
    /*
     func saveCard() {
     
     if !isInputCardValid() {
     return;
     }
     
     ActivityIndicatorUtil.enableActivityIndicator(self.view)
     
     let number = cardFieldsViewOutlet.numberInputTextField.text
     let expMonth = cardFieldsViewOutlet.monthTextField.text
     let expYear = cardFieldsViewOutlet.yearTextField.text
     let cvc = cardFieldsViewOutlet.cvcTextField.text
     
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
     
     let cardClient: BTCardClient = BTCardClient(apiClient: BraintreePaymentService.sharedInstance().apiClient!)
     
     let card: BTCard = BTCard(number: number!,
     expirationMonth: expMonth!,
     expirationYear: expYear!,
     cvv: cvc!)
     
     cardClient.tokenizeCard(card, completion: {(tokenized: BTCardNonce?, error: Error?) -> Void in
     
     print(BTCardNonce.self)
     print(tokenized?.nonce as Any)
     
     
     let client: BAAClient = BAAClient.shared()
     
     client.addPaymentMethod(BAASBOX_RIDER_STRING, paymentMethodNonce: tokenized?.nonce, completion: {(success, error) -> Void in
     
     print(success as Any)
     ActivityIndicatorUtil.disableActivityIndicator(self.view)
     
     if ((success) != nil) {
     DDLogVerbose("PaymentMethod added successfully \(success)")
     
     //back
     _ = self.navigationController?.popViewController(animated: true)
     }
     else {
     DDLogVerbose("Error PaymentMethod in: \(error)")
     
     if ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
     WebInterface.BAASBOX_AUTHENTICATION_ERROR) {
     
     // check for authentication error and redirect the user to Login page
     }
     else {
     AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
     }
     }
     })
     
     
     if let error = error {
     ActivityIndicatorUtil.disableActivityIndicator(self.view)
     self.handleCardTokenError(error as NSError)
     }
     else {
     //                var phone: String = self.rememberMePhoneCell.contents
     //                var email: String = self.emailCell.contents
     
     // TODO: We save the zipcode
     if self.isEditCard == true {
     
     self.editDelegate?.editPaymentViewController(editPaymentViewController: self, didCreateNewToken: tokenized!, completion: {(error: NSError?) -> Void in
     ActivityIndicatorUtil.disableActivityIndicator(self.view)
     if let error = error {
     self.handleCardTokenError(error)
     }
     })
     } else if self.isSignup == true {
     self.signupDelegate?.signupPaymentViewController(addPaymentViewController: self, didCreateNonce: tokenized!, completion: {(error: NSError?) -> Void in
     ActivityIndicatorUtil.disableActivityIndicator(self.view)
     if let error = error {
     self.handleCardTokenError(error)
     }
     })
     } else {
     self.addDelegate?.addPaymentViewController(addPaymentViewController: self, didCreateNonce: tokenized!, completion: {(error: NSError?) -> Void in
     ActivityIndicatorUtil.disableActivityIndicator(self.view)
     
     //self.addPaymentCard(nonce:  tokenized?.nonce as Any as AnyObject)
     
     
     
     
     if let error = error {
     self.handleCardTokenError(error)
     }
     })
     }
     }
     })
     
     #endif
     }*/
    
}
