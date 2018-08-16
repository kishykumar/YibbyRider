//
//  PaymentsViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/20/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Crashlytics
import Braintree
import SwiftMessages

protocol SelectPaymentViewControllerDelegate {
    
    func selectPaymentViewController(selectPaymentViewController: PaymentsViewController,
                                     didSelectPaymentMethod method: YBPaymentMethod)
    
    func selectPaymentViewControllerDidCancel(_ selectPaymentViewController: PaymentsViewController)
}

enum PaymentsViewControllerType: Int {
    case pickForRide = 0
    case listPayment
}

class PaymentsViewController: BaseYibbyViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            AddPaymentViewControllerDelegate,
                            EditPaymentViewControllerDelegate {

    // MARK: - Properties
    @IBOutlet weak var paymentsTableViewOutlet: UITableView!
    @IBOutlet weak var paymentDefaultsViewOutlet: YibbyBorderedUIView!
    @IBOutlet weak var paymentsTableViewHeightConstraintOutlet: NSLayoutConstraint!
    @IBOutlet weak var paymentsTableHeaderLabelOutlet: UILabel!
    
    var controllerType: PaymentsViewControllerType = PaymentsViewControllerType.listPayment

    let paymentMethodCellIdentifier = "paymentMethodCellIdentifier"
    var selectedIndexPath: IndexPath!
    var selectedPaymentMethod: YBPaymentMethod?
    var delegate: SelectPaymentViewControllerDelegate?

    // MARK: - Actions

    @IBAction func onAddCardClick(_ sender: UIButton) {
        
        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
        let apViewController =
            paymentStoryboard.instantiateViewController(withIdentifier: "AddPaymentViewControllerIdentifier")
                as! AddPaymentViewController

        apViewController.addDelegate = self
        self.navigationController!.pushViewController(apViewController, animated: true)
    }

    @IBAction func cancelButtonAction(_ sender: AnyObject){
        self.delegate?.selectPaymentViewControllerDidCancel(self)
    }

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupDelegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        paymentsTableViewHeightConstraintOutlet.constant = self.paymentsTableViewOutlet.contentSize.height
    }
    
    func setupUI () {
        
        setupBackButton()
        
        if (controllerType == PaymentsViewControllerType.pickForRide) {
            
            paymentsTableHeaderLabelOutlet.text = "Payment Selection"
            
        } else if (controllerType == PaymentsViewControllerType.listPayment) {
            
            self.selectedPaymentMethod = YBClient.sharedInstance().defaultPaymentMethod
            
        }
    }
    
    func setupDelegates() {
        paymentsTableViewOutlet.delegate = self
        paymentsTableViewOutlet.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listedPaymentMethods = YBClient.sharedInstance().paymentMethods

        let cell: CardTableCell = tableView.dequeueReusableCell(withIdentifier: paymentMethodCellIdentifier, for: indexPath) as! CardTableCell

        let paymentMethod = listedPaymentMethods[indexPath.row]
        
        let paymentMethodType: BTUIPaymentOptionType =
            BraintreeCardUtil.paymentMethodTypeFromBrand(paymentMethod.type)
        cell.cardBrandViewOutlet.setCardType(paymentMethodType, animated: false)
        
        cell.cardTextLabelOutlet.text = "*\(paymentMethod.last4!)"
        
        if paymentMethod.token == self.selectedPaymentMethod?.token {
            self.selectedIndexPath = indexPath
            cell.selectedCardButton.backgroundColor = UIColor.appDarkGreen1()
        } else {
            cell.selectedCardButton.backgroundColor = UIColor.white
        }
        
        if (controllerType == PaymentsViewControllerType.listPayment) {
            
        } else if (controllerType == PaymentsViewControllerType.pickForRide) {
            
            // hide the edit button during payment selection
            cell.editPaymentButtonOutlet.isHidden = true
            
        }

        cell.myPaymentMethod = paymentMethod
        cell.myViewController = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let listedPaymentMethods = YBClient.sharedInstance().paymentMethods

        return  listedPaymentMethods.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listedPaymentMethods = YBClient.sharedInstance().paymentMethods
        
        tableView.deselectRow(at: indexPath, animated: true)

        if (controllerType == PaymentsViewControllerType.listPayment) {
            
            let defaultPaymentMethod = listedPaymentMethods[indexPath.row]
            self.selectedPaymentMethod = defaultPaymentMethod
            
            // Change the default Payment Method at the server
            ActivityIndicatorUtil.enableActivityIndicator(self.view)
            BraintreePaymentService.sharedInstance().selectDefaultCustomerSource(defaultPaymentMethod, completionBlock: { (error: NSError?) -> Void in
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                
                if (error == nil) {
                    DDLogVerbose("makeDefaultPaymentMethod in successfully \(String(describing: error))")
                    ToastUtil.displayToastOnVC(self,
                                               title: "Payment Method changed",
                                               body: "Your default payment method has been changed.",
                                               theme: .success,
                                               presentationStyle: .bottom,
                                               duration: .seconds(seconds: 2),
                                               windowLevel: UIWindowLevelNormal)
                    self.reloadTable()
                } else {
                    DDLogVerbose("Error makeDefaultPaymentMethod in: \(String(describing: error))")
                    ToastUtil.displayToastOnVC(self,
                                               title: "Error",
                                               body: "There was some error in changing payment method. Please try again",
                                               theme: .error,
                                               presentationStyle: .bottom,
                                               duration: .seconds(seconds: 2),
                                               windowLevel: UIWindowLevelNormal)
                }
            })

        } else if (controllerType == PaymentsViewControllerType.pickForRide) {

            let newSelectedPaymentMethod = listedPaymentMethods.safeValue(indexPath.row)
            
            // unselect the old one
            if (self.selectedIndexPath != nil) {
                let oldCell = tableView.cellForRow(at: self.selectedIndexPath) as! CardTableCell
                oldCell.selectedCardButton.backgroundColor = UIColor.white
            }
            
            // select the new one
            let newCell = tableView.cellForRow(at: indexPath) as! CardTableCell
            self.selectedPaymentMethod = newSelectedPaymentMethod
            newCell.selectedCardButton.backgroundColor = UIColor.appDarkGreen1()
            
            self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: newSelectedPaymentMethod!)
        }
    }

    // MARK: - AddPaymentViewControllerDelegate

    func addPaymentViewControllerDidCancel(_ addPaymentViewController: AddPaymentViewController) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
                                  didCreateNonce paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock) {

        BraintreePaymentService.sharedInstance().attachSourceToCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in

            // execute the completion block first
            completion(error)

            if (error == nil) {
                self.navigationController!.popViewController(animated: true)
                self.reloadTable()
            }
        })
    }
    
    // MARK: - EditPaymentViewControllerDelegate
    
    func editPaymentViewControllerDidCancel(_ editPaymentViewController: AddPaymentViewController) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                   didRemovePaymentMethod paymentMethod: YBPaymentMethod, completion: @escaping BTErrorBlock) {

        BraintreePaymentService.sharedInstance().deleteSourceFromCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
            
            // execute the completion block first
            completion(error)
            
            if (error == nil) {
                self.navigationController!.popViewController(animated: true)
                self.reloadTable()
            }
        })
    }
    
    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
                                   didCreateNewNonce nonce: BTPaymentMethodNonce,
                                   oldPaymentMethod: YBPaymentMethod,
                                   completion: @escaping BTErrorBlock) {

        BraintreePaymentService.sharedInstance().updateSourceForCustomer(nonce,
            oldPaymentMethod: oldPaymentMethod,
            completionBlock: {(error: Error?) -> Void in

                // execute the completion block first
                completion(error as NSError?)

                if (error == nil) {
                    self.navigationController!.popViewController(animated: true)
                    self.reloadTable()
                }
        })
    }
    
    // MARK: - Helpers
    
    func reloadTable() {
        self.selectedPaymentMethod = YBClient.sharedInstance().defaultPaymentMethod
        self.paymentsTableViewOutlet.reloadData()
        
        // We need to layout the view again because of the tableview height constraint update
        self.view.setNeedsLayout()
    }
}
