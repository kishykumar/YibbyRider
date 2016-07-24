//
//  PaymentViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Stripe
import BaasBoxSDK
import Crashlytics

class PaymentViewController: UITableViewController, PaymentMethodsViewControllerDelegate {

    // MARK: Properties
    
    let totalSections: Int = 3
    let cardListSection: Int = 0
    let addCardSection: Int = 1
    let defaultPaymentSection: Int = 2
    
    let cardCellReuseIdentifier = "cardIdentifier"
    let defaultPaymentCellReuseIdentifier = "defaultPaymentIdentifier"
    let addCardCellReuseIdentifier = "addCardIdentifier"
    
    var paymentMethods = [STPPaymentMethod]()
    var apiAdapter: StripeBackendAPIAdapter = StripeAPIClient.sharedClient
    
    var defaultPaymentMethod: STPPaymentMethod?
    
    // MARK: Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.performSelector(#selector(PaymentViewController.loadCustomerDetails),
                             withObject:nil, afterDelay:0.0)

    }

    func loadCustomerDetails() {

        apiAdapter.retrieveCustomer({(customer: STPCustomer?, error: NSError?) -> Void in
            
            if error != nil {
                // TODO: handle error
                AlertUtil.displayAlert(error!.localizedDescription, message: "")
            }
            else {
                if let customer = customer {

                    self.paymentMethods.removeAll()
                    self.defaultPaymentMethod = nil
                    
                    for source: STPSource in customer.sources {
                        if (source is STPCard) {
                            let card: STPCard = (source as! STPCard)
                            self.paymentMethods.append(card)
                            
                            if (card.stripeID == customer.defaultSource?.stripeID) {
                                self.defaultPaymentMethod = card
                            }
                        }
                    }
                    
                    // reload the tableview in case the table datasource methods already fired
                    self.tableView.reloadData()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableView DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == cardListSection {
            let cell: CardTableCell = tableView.dequeueReusableCellWithIdentifier(cardCellReuseIdentifier, forIndexPath: indexPath) as! CardTableCell
            
            if let paymentMethod: STPPaymentMethod = self.paymentMethods.safeValue(indexPath.row) {

                cell.cardBrandImageViewOutlet.image = paymentMethod.image
                cell.cardTextLabelOutlet.text = paymentMethod.label
            } else {
                DDLogError("Nil payment method. This should not happen. Index: \(indexPath.row)")
            }
            return cell
        }
        else if indexPath.section == addCardSection {
            
            let cell: AddCardTableCell = tableView.dequeueReusableCellWithIdentifier(addCardCellReuseIdentifier, forIndexPath: indexPath) as! AddCardTableCell
            return cell
            
        } else if indexPath.section == defaultPaymentSection {
            let cell: DefaultPaymentTableCell = tableView.dequeueReusableCellWithIdentifier(defaultPaymentCellReuseIdentifier, forIndexPath: indexPath) as! DefaultPaymentTableCell
            
            if let defaultPaymentMethod = defaultPaymentMethod {
                if let card = defaultPaymentMethod as? STPCard {
                    cell.paymentImageOutlet.image = card.image
                    cell.paymentTextOutlet.text = String.stp_stringWithCardBrand(card.brand) + " Ending In " + card.last4()
                }
            }
            
            return cell
        }
        
        // This won't get executed as we expect the return from individual if statements
        assert(false)
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == cardListSection) {
            return self.paymentMethods.count;
        } else if (section == addCardSection) {
            return 1;
        } else if (section == defaultPaymentSection) {
            return (defaultPaymentMethod != nil) ? 1 : 0;
        }
        
        return 0;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == cardListSection) {
            return "Payment methods"
        } else if (section == addCardSection) {
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
            
            if let paymentMethod = self.paymentMethods.safeValue(indexPath.row) {
                let editCardViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentMethodsViewControllerIdentifier") as! PaymentMethodsViewController
                
                editCardViewController.delegate = self
                
                if let card = paymentMethod as? STPCard {
                    
                    editCardViewController.card = card
                    editCardViewController.isEditCard = true
                    self.navigationController!.pushViewController(editCardViewController, animated: true)
                }
            }
            
        } else if (indexPath.section == addCardSection) {
            
            let pmViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentMethodsViewControllerIdentifier") as! PaymentMethodsViewController
            
            pmViewController.delegate = self
            self.navigationController!.pushViewController(pmViewController, animated: true)
            
        } else if (indexPath.section == defaultPaymentSection) {
            
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rideDetail" {
//            let indexPath = self.tableView!.indexPathForSelectedRow
//            let destinationViewController: RideDetailViewController = segue.destinationViewController as! RideDetailViewController
        }
    }
    
    // MARK: PaymentMethodsViewControllerDelegate
    
    func paymentMethodsViewControllerDidCancel(paymentMethodsViewController: PaymentMethodsViewController) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    func paymentMethodsViewController(paymentMethodsViewController: PaymentMethodsViewController,
                                      didCreateToken token: STPToken, completion: STPErrorBlock) {

        self.apiAdapter.attachSourceToCustomer(token, completion: {(error: NSError?) -> Void in
            
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewControllerAnimated(true)

                // Completely reload the view as it may have changed the default payment
                self.performSelector(#selector(PaymentViewController.loadCustomerDetails),
                    withObject:nil, afterDelay:0.0)
            }
        })
    }

    func paymentMethodsViewController(paymentMethodsViewController: PaymentMethodsViewController,
                                      didRemovePaymentMethod paymentMethod: STPPaymentMethod, completion: STPErrorBlock) {
        
        if paymentMethod is STPSource {
            let source = paymentMethod as! STPSource
            self.apiAdapter.deleteSourceFromCustomer(source, completion: {(error: NSError?) -> Void in
                
                // execute the completion block first
                completion(error)
                
                if (error == nil) {
                    self.navigationController!.popViewControllerAnimated(true)

                    // Completely reload the view as it may have changed the default payment
                    self.performSelector(#selector(PaymentViewController.loadCustomerDetails),
                        withObject:nil, afterDelay:0.0)
                }
            })
        }
    }
}




