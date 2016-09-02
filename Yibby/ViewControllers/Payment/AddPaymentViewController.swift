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

protocol AddPaymentViewControllerDelegate {
    
    /**
     *  Called when the user cancels adding a card. You should dismiss (or pop) the view controller at this point.
     *
     *  @param addPaymentViewController the view controller that has been cancelled
     */

    func addPaymentViewControllerDidCancel(addPaymentViewController: AddPaymentViewController)
    
    /**
     *  This is called when the user successfully adds a card and tokenizes it with Stripe. You should send the token to your backend to store it on a customer, and then call the provided `completion` block when that call is finished. If an error occurred while talking to your backend, call `completion(error)`, otherwise, call `completion(nil)` and then dismiss (or pop) the view controller.
     *
     *  @param addPaymentViewController the view controller that successfully created a token
     *  @param token                 the Stripe token that was created. @see STPToken
     *  @param completion            call this callback when you're done sending the token to your backend
     */

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                      didCreateToken token: STPToken, completion: STPErrorBlock)
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                  didCreateNonce paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock)
#endif
    
}

protocol EditPaymentViewControllerDelegate {

    func editPaymentViewControllerDidCancel(editPaymentViewController: AddPaymentViewController)

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                  didCreateNewToken token: STPToken, completion: STPErrorBlock)
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                    didCreateNewToken token: BTPaymentMethodNonce, completion: BTErrorBlock)
#endif

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                   didRemovePaymentMethod paymentMethod: STPPaymentMethod, completion: STPErrorBlock)

#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                    didRemovePaymentMethod paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock)
#endif
}

class AddPaymentViewController: BaseYibbyViewController, CardIOPaymentViewControllerDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var cardFieldsViewOutlet: CardFieldsView!
    @IBOutlet weak var deleteCardButtonOutlet: BButton!
    
    
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

    var isEditCard: Bool! = false   // implicitly unwrapped optional
    
    // MARK: - Actions
    @IBAction func deleteCardAction(sender: AnyObject) {
        
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
    
            self.editDelegate?.editPaymentViewController(self, didRemovePaymentMethod: self.cardToBeEdited!, completion: {(error: NSError?) -> Void in
                
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                
                if let error = error {
                    self.handleCardTokenError(error)
                }
            })
    
#endif
            
        })
    }
    
    @IBAction func saveButtonAction(sender: AnyObject) {
        
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let cardParams = STPCardParams()
        
        cardParams.number = cardFieldsViewOutlet.numberInputTextField.text
        cardParams.expMonth = UInt(cardFieldsViewOutlet.monthTextField.text!)!
        cardParams.expYear = UInt(cardFieldsViewOutlet.yearTextField.text!)!
        cardParams.cvc = cardFieldsViewOutlet.cvcTextField.text
        
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
    
        let cardClient: BTCardClient = BTCardClient(APIClient: BraintreePaymentService.sharedInstance().apiClient!)
    
        let card: BTCard = BTCard(number: cardParams.number!,
                                  expirationMonth: String(cardParams.expMonth),
                                  expirationYear: String(cardParams.expYear),
                                  cvv: cardParams.cvc!)
    
        cardClient.tokenizeCard(card, completion: {(tokenized: BTCardNonce?, error: NSError?) -> Void in
            
            if let error = error {
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                self.handleCardTokenError(error)
            }
            else {
                //                var phone: String = self.rememberMePhoneCell.contents
                //                var email: String = self.emailCell.contents
                
                // TODO: We save the zipcode
                if self.isEditCard == true {
                    
                    self.editDelegate?.editPaymentViewController(self, didCreateNewToken: tokenized!, completion: {(error: NSError?) -> Void in
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if let error = error {
                            self.handleCardTokenError(error)
                        }
                    })
                } else {
                    self.addDelegate?.addPaymentViewController(self, didCreateNonce: tokenized!, completion: {(error: NSError?) -> Void in
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if let error = error {
                            self.handleCardTokenError(error)
                        }
                    })
                }
            }
        })

#endif
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        if (isEditCard == true) {
            self.editDelegate?.editPaymentViewControllerDidCancel(self)
        } else {
            self.addDelegate?.addPaymentViewControllerDidCancel(self)
        }
    }
    
    @IBAction func scanCardAction(sender: AnyObject) {
        
        // if camera is disabled, display alert.
        if (CardIOUtilities.canReadCardWithCamera() == false) {
            AlertUtil.displayAlert("Camera disabled.", message: "Please give Camera permission to Yibby.")
            return;
        }
        
        // display the cardIO view controller.
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC.modalPresentationStyle = .FormSheet
        cardIOVC.disableManualEntryButtons = true
        presentViewController(cardIOVC, animated: true, completion: nil)
    }
    
    // MARK: - CardIO Delegate Functions
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            
            let cardParams: STPCardParams = STPCardParams()
            
            cardParams.number = info.cardNumber
            cardParams.expMonth = info.expiryMonth
            cardParams.expYear = info.expiryYear
            cardParams.cvc = info.cvv
            
            self.cardFieldsViewOutlet.numberInputTextField.placeholder = cardParams.number
            self.cardFieldsViewOutlet.monthTextField.placeholder = String(cardParams.expMonth)
            self.cardFieldsViewOutlet.yearTextField.placeholder = String(cardParams.expYear)
            self.cardFieldsViewOutlet.cvcTextField.placeholder = cardParams.cvc
        }
        
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Setup Functions 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        CardIOUtilities.preload()
        
        if let card = cardToBeEdited {
            
            // cardParams.number will have the last 4 of the card
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
            self.cardFieldsViewOutlet.numberInputTextField.placeholder = "************" + card.last4()
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
            self.cardFieldsViewOutlet.numberInputTextField.placeholder = "************" + card.localizedDescription
#endif

        }
        
        if (isEditCard == true) {
            deleteCardButtonOutlet.hidden = false
        } else {
            deleteCardButtonOutlet.hidden = true
        }
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

    // MARK: - Helpers
    
    
    func handleCardTokenError(error: NSError) {
        AlertUtil.displayAlert(error.localizedDescription, message: error.localizedFailureReason ?? "")
    }
    
}
