//
//  PaymentViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Crashlytics
import Braintree

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
#endif

protocol SelectPaymentViewControllerDelegate {
    
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE

    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                    didSelectPaymentMethod method: STPPaymentMethod,
                                    controllerType: PaymentViewControllerType)
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                     didSelectPaymentMethod method: BTPaymentMethodNonce,
                                                            controllerType: PaymentViewControllerType)
#endif

    func selectPaymentViewControllerDidCancel(selectPaymentViewController: PaymentViewController)
}

enum PaymentViewControllerType: Int {
    case PickDefault = 0
    case PickForRide
    case ListPayment
}

class PaymentViewController: BaseYibbyTableViewController, AddPaymentViewControllerDelegate,
                                                    EditPaymentViewControllerDelegate,
                                                    SelectPaymentViewControllerDelegate {

    // MARK: - Properties

    var controllerType: PaymentViewControllerType = PaymentViewControllerType.ListPayment

    var totalSections: Int {
        get {
            switch (controllerType) {
            case .ListPayment:
                return 3;
            case .PickForRide:
                return 2;
            case .PickDefault:
                return 1;
            }
        }
    }
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    let cardListSection: Int = 0
    let addPaymentSection: Int = 1
    let defaultPaymentSection: Int = 2
    
    let cardCellReuseIdentifier = "cardIdentifier"
    let defaultPaymentCellReuseIdentifier = "defaultPaymentIdentifier"
    let addCardCellReuseIdentifier = "addCardIdentifier"

    var selectedIndexPath: NSIndexPath?
    
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    var selectedPaymentMethod: STPPaymentMethod?
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    var selectedPaymentMethod: BTPaymentMethodNonce?
    
#endif
    
    var delegate: SelectPaymentViewControllerDelegate?
    
    // MARK: - Actions
    
    @IBAction func saveButtonAction(sender: AnyObject) {
        
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
        let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
        let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)
    
#endif
        
        self.delegate?.selectPaymentViewController(self, didSelectPaymentMethod: paymentMethod!,
                                                   controllerType: PaymentViewControllerType.PickDefault)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        self.delegate?.selectPaymentViewControllerDidCancel(self)
    }
    
    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI () {
        if (controllerType == PaymentViewControllerType.ListPayment) {
            
            // remove the save button
            self.navigationItem.rightBarButtonItems?.removeAll()
            
            // remove the cancel button
            self.navigationItem.leftBarButtonItems?.removeAll()
            
        } else if (controllerType == PaymentViewControllerType.PickForRide) {
            
            // remove the save button
            self.navigationItem.rightBarButtonItems?.removeAll()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableView DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == cardListSection {
            let cell: CardTableCell = tableView.dequeueReusableCellWithIdentifier(cardCellReuseIdentifier, forIndexPath: indexPath) as! CardTableCell
            
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
            let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)

            if ((paymentMethod) != nil) {
                cell.cardBrandImageViewOutlet.image = paymentMethod.image
                cell.cardTextLabelOutlet.text = paymentMethod.label
            }
    
            let defaultPaymentMethod = StripePaymentService.sharedInstance().defaultPaymentMethod
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE

            let paymentMethod: BTPaymentMethodNonce? = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)
            if ((paymentMethod) != nil) {
                
                cell.cardBrandImageViewOutlet.image =
                    BTUI.braintreeTheme().vectorArtViewForPaymentInfoType(paymentMethod!.type).imageOfSize(CGSizeMake(42, 23))
                cell.cardTextLabelOutlet.text = paymentMethod?.localizedDescription
                
            }

            let defaultPaymentMethod = BraintreePaymentService.sharedInstance().defaultPaymentMethod

#endif
            
            if ((paymentMethod) != nil) {
                
                // Configure the cell based on controller type
                if (controllerType == PaymentViewControllerType.PickDefault) {
                    
                    // put a check mark on the default card
                    let selected: Bool = paymentMethod!.isEqual(defaultPaymentMethod)
                    cell.accessoryType = selected ? .Checkmark : .None
                    
                    if (selected) {
                        self.selectedIndexPath = indexPath
                    }
                    
                } else if (controllerType == PaymentViewControllerType.PickForRide) {
                    
                    // put a check mark on the currently selected card
                    let selected: Bool = paymentMethod!.isEqual(self.selectedPaymentMethod)
                    cell.accessoryType = selected ? .Checkmark : .None
                    
                    if (selected) {
                        self.selectedIndexPath = indexPath
                    }
                }
            } else {
                DDLogError("Nil payment method. This should not happen. Index: \(indexPath.row)")
            }
            return cell
        }
        else if indexPath.section == addPaymentSection {
            
            let cell: AddCardTableCell = tableView.dequeueReusableCellWithIdentifier(addCardCellReuseIdentifier, forIndexPath: indexPath) as! AddCardTableCell
            return cell
            
        } else if indexPath.section == defaultPaymentSection {
            let cell: DefaultPaymentTableCell = tableView.dequeueReusableCellWithIdentifier(defaultPaymentCellReuseIdentifier,
                                                        forIndexPath: indexPath) as! DefaultPaymentTableCell
            
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
            if let defaultPaymentMethod = StripePaymentService.sharedInstance().defaultPaymentMethod {

                if let card = defaultPaymentMethod as? STPCard {
                    cell.paymentImageOutlet.image = card.image
                    cell.paymentTextOutlet.text = String.stp_stringWithCardBrand(card.brand) + " Ending In " + card.last4()
                }
            }
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
            if let defaultPaymentMethod = BraintreePaymentService.sharedInstance().defaultPaymentMethod {
//                cell.paymentImageOutlet.image = defaultPaymentMethod.image
                cell.paymentTextOutlet.text = defaultPaymentMethod.localizedDescription
            }
#endif
            
            return cell
        }
        
        // This won't get executed as we expect the return from individual if statements
        assert(false)
        
        return UITableViewCell()
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE

        if (section == cardListSection) {
            return StripePaymentService.sharedInstance().paymentMethods.count;
        } else if (section == addPaymentSection) {
            return 1;
        } else if (section == defaultPaymentSection) {
            return (StripePaymentService.sharedInstance().defaultPaymentMethod != nil) ? 1 : 0;
        }
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
        if (section == cardListSection) {
            return BraintreePaymentService.sharedInstance().paymentMethods.count;
        } else if (section == addPaymentSection) {
            return 1;
        } else if (section == defaultPaymentSection) {
            return (BraintreePaymentService.sharedInstance().defaultPaymentMethod != nil) ? 1 : 0;
        }
    
#endif

        return 0;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == cardListSection) {
            return "Payment methods"
        } else if (section == addPaymentSection) {
            return "Add payment method"
        } else if (section == defaultPaymentSection) {
            return "Payment defaults"
        }
        return ""
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return totalSections;
    }
    
    
    //MARK: - UITableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)

        if (indexPath.section == cardListSection) {
            
            if (controllerType == PaymentViewControllerType.ListPayment) {
            
                let editCardViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("AddPaymentViewControllerIdentifier") as! AddPaymentViewController
                
                editCardViewController.editDelegate = self
                self.selectedIndexPath = indexPath

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
                let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)!
                if let card = paymentMethod as? STPCard {
                    
                    editCardViewController.cardToBeEdited = card
                    editCardViewController.isEditCard = true
                    self.navigationController!.pushViewController(editCardViewController, animated: true)
                }

#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE

                let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)!
    
                editCardViewController.cardToBeEdited = paymentMethod
                editCardViewController.isEditCard = true
                self.navigationController!.pushViewController(editCardViewController, animated: true)

#endif
            } else if (controllerType == PaymentViewControllerType.PickDefault) {
                
                let oldSelectedCell = tableView.cellForRowAtIndexPath(self.selectedIndexPath!)
                oldSelectedCell?.accessoryType = .None

                let newSelectedCell = tableView.cellForRowAtIndexPath(indexPath)
                newSelectedCell?.accessoryType = .Checkmark
                
                self.selectedIndexPath = indexPath
                
            } else if (controllerType == PaymentViewControllerType.PickForRide) {

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
                let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)

#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
                let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)!

#endif

                self.delegate?.selectPaymentViewController(self, didSelectPaymentMethod: paymentMethod,
                                                           controllerType: PaymentViewControllerType.PickForRide)
                
            }
        } else if (indexPath.section == addPaymentSection) {
            
            let apViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("AddPaymentViewControllerIdentifier") as! AddPaymentViewController
            
            apViewController.addDelegate = self
            self.navigationController!.pushViewController(apViewController, animated: true)
            
        } else if (indexPath.section == defaultPaymentSection) {
            let paymentViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
            
            paymentViewController.controllerType = PaymentViewControllerType.PickDefault
            paymentViewController.delegate = self
            
            self.navigationController!.pushViewController(paymentViewController, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rideDetail" {
//            let indexPath = self.tableView!.indexPathForSelectedRow
//            let destinationViewController: RideDetailViewController = segue.destinationViewController as! RideDetailViewController
        }
    }
    
    // MARK: AddPaymentViewControllerDelegate
    
    func addPaymentViewControllerDidCancel(addPaymentViewController: AddPaymentViewController) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    func editPaymentViewControllerDidCancel(editPaymentViewController: AddPaymentViewController) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func selectPaymentViewControllerDidCancel(selectPaymentViewController: PaymentViewController) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE

    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                      didCreateToken token: STPToken, completion: STPErrorBlock) {

        StripePaymentService.sharedInstance().attachSourceToCustomer(token, completionBlock: {(error: NSError?) -> Void in
            
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewControllerAnimated(true)

                // Completely reload the view as it may have changed the default payment
                self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                    withObject:nil, afterDelay:0.0)
            }
        })
    }
    
    // MARK: EditPaymentViewControllerDelegate
    
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                      didRemovePaymentMethod paymentMethod: STPPaymentMethod, completion: STPErrorBlock) {
    
        if paymentMethod is STPSource {
            let source = paymentMethod as! STPSource
            
            StripePaymentService.sharedInstance().deleteSourceFromCustomer(source, completionBlock: {(error: NSError?) -> Void in
                
                // execute the completion block first
                completion(error)
                
                if (error == nil) {
                    self.navigationController!.popViewControllerAnimated(true)

                    // Completely reload the view as it may have changed the default payment
                    self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                        withObject:nil, afterDelay:0.0)
                }
            })
        }
    }

#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                  didCreateNonce paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock) {
        
        BraintreePaymentService.sharedInstance().attachSourceToCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
            
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewControllerAnimated(true)
                
                // Completely reload the view as it may have changed the default payment
                self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                    withObject:nil, afterDelay:0.0)
            }
        })
    }
    
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                   didRemovePaymentMethod paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock) {
        
        BraintreePaymentService.sharedInstance().deleteSourceFromCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
            
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewControllerAnimated(true)
                
                // Completely reload the view as it may have changed the default payment
                self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                    withObject:nil, afterDelay:0.0)
            }
        })
    }
    
#endif

#if YIBBY_USE_STRIPE_PAYMENT_SERVICE

    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                  didCreateNewToken token: STPToken, completion: STPErrorBlock) {
        
        let oldSource = StripePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)

        StripePaymentService.sharedInstance().updateSourceForCustomer(token,
                                                                      oldSource: oldSource as! STPSource,
                                                                      completionBlock: {(error: NSError?) -> Void in

            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewControllerAnimated(true)
                
                // Completely reload the view as it may have changed the default payment
                self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                    withObject:nil, afterDelay:0.0)
            }
        })
    }
    
    // MARK: SelectPaymentViewControllerDelegate
    
    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                    didSelectPaymentMethod method: STPPaymentMethod,
                                    controllerType: PaymentViewControllerType) {
        
        if (controllerType == PaymentViewControllerType.PickDefault) {
            
            if method is STPSource {
                let source = method as! STPSource
                
                StripePaymentService.sharedInstance().selectDefaultCustomerSource(source, completionBlock: {(error: NSError?) -> Void in
                    
                    if (error == nil) {
                        self.navigationController!.popViewControllerAnimated(true)

                        // Completely reload the view as it may have changed the default payment
                        self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                            withObject:nil, afterDelay:0.0)
                    } else {
                        AlertUtil.displayAlert(error!.localizedDescription,
                            message: error!.localizedFailureReason ?? "Default could not be changed.")
                    }
                })
            }
        } else if (controllerType == PaymentViewControllerType.PickForRide) {
            
        }
    }
    
    func reloadCustomerDetails() {
    
        StripePaymentService.sharedInstance().loadCustomerDetails({
            // reload the tableview in case the table datasource methods already fired
            self.tableView.reloadData()
        })
    }
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                   didCreateNewToken paymentMethod: BTPaymentMethodNonce, completion: BTErrorBlock) {
        
        let oldPaymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)
        
        BraintreePaymentService.sharedInstance().updateSourceForCustomer(paymentMethod,
                                                                         oldPaymentMethod: oldPaymentMethod!,
                                                                         completionBlock: {(error: NSError?) -> Void in
                                                                        
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewControllerAnimated(true)
                
                // Completely reload the view as it may have changed the default payment
                self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                    withObject:nil, afterDelay:0.0)
            }
        })
    }
    
    // MARK: SelectPaymentViewControllerDelegate
    
    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                     didSelectPaymentMethod paymentMethod: BTPaymentMethodNonce,
                                                            controllerType: PaymentViewControllerType) {
        
        if (controllerType == PaymentViewControllerType.PickDefault) {
            
            BraintreePaymentService.sharedInstance().selectDefaultCustomerSource(paymentMethod, completionBlock: {(error: NSError?) -> Void in
                
                if (error == nil) {
                    self.navigationController!.popViewControllerAnimated(true)
                    
                    // Completely reload the view as it may have changed the default payment
                    self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
                        withObject:nil, afterDelay:0.0)
                } else {
                    AlertUtil.displayAlert(error!.localizedDescription,
                        message: error!.localizedFailureReason ?? "Default could not be changed.")
                }
            })
        } else if (controllerType == PaymentViewControllerType.PickForRide) {
            
        }
    }

    func reloadCustomerDetails() {
        
        BraintreePaymentService.sharedInstance().loadCustomerDetails({
            // reload the tableview in case the table datasource methods already fired
            self.tableView.reloadData()
        })
        
    }
    
#endif

}




