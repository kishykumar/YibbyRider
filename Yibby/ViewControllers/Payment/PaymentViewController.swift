////
////  PaymentViewController.swift
////  Yibby
////
////  Created by Kishy Kumar on 4/5/16.
////  Copyright © 2016 MyComp. All rights reserved.
////
//
//import UIKit
//import CocoaLumberjack
//import Crashlytics
//import Braintree
//import BaasBoxSDK
//
//#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//    
//#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//    
//#endif
//
//protocol SelectPaymentViewControllerDelegate {
//    
//    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//    
//    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
//    didSelectPaymentMethod method: STPPaymentMethod,
//    controllerType: PaymentViewControllerType)
//    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
//                                     didSelectPaymentMethod method: BTPaymentMethodNonce,
//                                     controllerType: PaymentViewControllerType)
//    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
//                                     didSelectPaymentMethod method: PaymentDetailsObject,
//                                     controllerType: PaymentViewControllerType)
//    #endif
//    
//    func selectPaymentViewControllerDidCancel(_ selectPaymentViewController: PaymentViewController)
//}
//
//enum PaymentViewControllerType: Int {
//    case pickDefault = 0
//    case pickForRide
//    case listPayment
//}
//
//class PaymentViewController: BaseYibbyTableViewController, AddPaymentViewControllerDelegate,
//EditPaymentViewControllerDelegate, SelectPaymentViewControllerDelegate {
//    
//    
//    // MARK: - Properties
//    var arrCardList = NSArray()
//    var controllerType: PaymentViewControllerType = PaymentViewControllerType.listPayment
//    
//    var totalSections: Int {
//        get {
//            switch (controllerType) {
//            case .listPayment:
//                return 3;
//            case .pickForRide:
//                return 2;
//            case .pickDefault:
//                return 1;
//            }
//        }
//    }
//    
//    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
//    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
//    
//    let cardListSection: Int = 0
//    let addPaymentSection: Int = 1
//    let defaultPaymentSection: Int = 2
//    
//    let cardCellReuseIdentifier = "cardIdentifier"
//    let defaultPaymentCellReuseIdentifier = "defaultPaymentIdentifier"
//    let addCardCellReuseIdentifier = "addCardIdentifier"
//    
//    var selectedIndexPath: IndexPath?
//    
//    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//    
//    var selectedPaymentMethod: STPPaymentMethod?
//    
//    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//    
//    var selectedPaymentMethod: BTPaymentMethodNonce?
//    
//    #endif
//    
//    var delegate: SelectPaymentViewControllerDelegate?
//    
//    // MARK: - Actions
//    
//    @IBAction func saveButtonAction(_ sender: AnyObject) {
//        
//        #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//            
//            let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)
//            
//        #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//            
//            let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)
//            
//        #endif
//        
//        self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: paymentMethod!, controllerType: PaymentViewControllerType.pickDefault)
//    }
//    
//    @IBAction func cancelButtonAction(_ sender: AnyObject){
//        self.delegate?.selectPaymentViewControllerDidCancel(self)
//    }
//    
//    // MARK: - Setup Functions
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = false
//        reloadCustomerDetails()
//        // getPayment()
//        setupUI()
//    }
//    
//    func setupUI () {
//        
//        
//        if (controllerType == PaymentViewControllerType.listPayment) {
//            
//            // remove the save button
//            self.navigationItem.rightBarButtonItems?.removeAll()
//            
//            // remove the cancel button and show the back button
//            self.navigationItem.leftBarButtonItems?.removeAll()
//            
//            setupBackButton()
//            
//            
//        } else if (controllerType == PaymentViewControllerType.pickForRide) {
//            
//            // remove the save button
//            self.navigationItem.rightBarButtonItems?.removeAll()
//        }
//        
//        //self.SetBackBarButtonCustom()
//    }
//    
//    func SetBackBarButtonCustom()
//    {
//        //Back buttion
//        let btnLeftMenu: UIButton = UIButton()
//        btnLeftMenu.setImage(UIImage(named: "back_button_green"), for: UIControlState())
//        
//        btnLeftMenu.addTarget(self, action: #selector(onClcikBack), for: .touchUpInside)
//        
//        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 50, height: 59)
//        
//        let barButton = UIBarButtonItem(customView: btnLeftMenu)
//        self.navigationItem.leftBarButtonItem = barButton
//    }
//    
//    func onClcikBack()
//    {
//        _ = self.navigationController?.popViewController(animated: true)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    // MARK: - UITableView DataSource
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if indexPath.section == cardListSection {
//            let cell: CardTableCell = tableView.dequeueReusableCell(withIdentifier: cardCellReuseIdentifier, for: indexPath) as! CardTableCell
//            
//            
//            cell.selectedCardColourButton.backgroundColor = UIColor.clear
//            
//            cell.selectedCardColourButton.tag = indexPath.row
//            
//            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                
//                let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)
//                
//                if ((paymentMethod) != nil) {
//                    cell.cardBrandImageViewOutlet.image = paymentMethod.image
//                    cell.cardTextLabelOutlet.text = paymentMethod.label
//                    
//                }
//                
//                let defaultPaymentMethod = StripePaymentService.sharedInstance().defaultPaymentMethod
//                
//            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                
//                
//                
//                /*cell.cardBrandImageViewOutlet.image =
//                 BTUI.braintreeTheme().vectorArtView(forPaymentInfoType: paymentMethod!.type).image(of: CGSize(width: 42, height: 23))
//                 cell.cardTextLabelOutlet.text = paymentMethod?.localizedDescription
//                 */
//                
//                
//                var paymentObjectModel = PaymentDetailsObject()
//                paymentObjectModel = self.arrCardList[indexPath.row] as! PaymentDetailsObject
//                
//                cell.cardBrandImageViewOutlet.image =
//                    BTUI.braintreeTheme().vectorArtView(forPaymentInfoType: paymentObjectModel.type).image(of: CGSize(width: 42, height: 23))
//                cell.cardTextLabelOutlet.text = "*\(paymentObjectModel.last4)"
//                
//                if paymentObjectModel.isDefault == "1"
//                {
//                    self.selectedIndexPath = indexPath
//                    cell.selectedCardColourButton.backgroundColor = UIColor.borderColor()
//                }
//                
//                
//                
//                let defaultPaymentMethod = BraintreePaymentService.sharedInstance().defaultPaymentMethod
//                
//            #endif
//            /*
//             if ((paymentMethod) != nil) {
//             
//             // Configure the cell based on controller type
//             if (controllerType == PaymentViewControllerType.pickDefault) {
//             
//             // put a check mark on the default card
//             let selected: Bool = paymentMethod!.isEqual(defaultPaymentMethod)
//             cell.accessoryType = selected ? .checkmark : .none
//             
//             DDLogVerbose("paymentMethod: \(paymentMethod) defaultPaymentMethod: \(defaultPaymentMethod) selected: \(selected)")
//             
//             if (selected) {
//             self.selectedIndexPath = indexPath
//             cell.selectedCardColourButton.backgroundColor = UIColor.borderColor()
//             }
//             
//             } else if (controllerType == PaymentViewControllerType.pickForRide) {
//             
//             // put a check mark on the currently selected card
//             let selected: Bool = paymentMethod!.isEqual(self.selectedPaymentMethod)
//             cell.accessoryType = selected ? .checkmark : .none
//             
//             if (selected) {
//             self.selectedIndexPath = indexPath
//             cell.selectedCardColourButton.backgroundColor = UIColor.borderColor()
//             }
//             
//             }
//             /*else
//             {
//             if (indexPath.row == 0) {
//             self.selectedIndexPath = indexPath
//             cell.selectedCardColourButton.backgroundColor = UIColor.borderColor()
//             }
//             }*/
//             } else {
//             DDLogError("Nil payment method. This should not happen. Index: \(indexPath.row)")
//             }
//             */
//            cell.paymentDefaultsBtnOutlet.tag = indexPath.row
//            
//            return cell
//        }
//        else if indexPath.section == addPaymentSection {
//            
//            let cell: AddCardTableCell = tableView.dequeueReusableCell(withIdentifier: addCardCellReuseIdentifier, for: indexPath) as! AddCardTableCell
//            return cell
//            
//        } else if indexPath.section == defaultPaymentSection {
//            let cell: DefaultPaymentTableCell = tableView.dequeueReusableCell(withIdentifier: defaultPaymentCellReuseIdentifier,
//                                                                              for: indexPath) as! DefaultPaymentTableCell
//            
//            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                if let defaultPaymentMethod = StripePaymentService.sharedInstance().defaultPaymentMethod {
//                    
//                    if let card = defaultPaymentMethod as? STPCard {
//                        cell.paymentImageOutlet.image = card.image
//                        cell.paymentTextOutlet.text = String.stp_stringWithCardBrand(card.brand) + " Ending In " + card.last4()
//                    }
//                }
//            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                if let defaultPaymentMethod = BraintreePaymentService.sharedInstance().defaultPaymentMethod {
//                    //                cell.paymentImageOutlet.image = defaultPaymentMethod.image
//                    cell.paymentTextOutlet.text = defaultPaymentMethod.localizedDescription
//                }
//            #endif
//            
//            return cell
//        }
//        
//        // This won't get executed as we expect the return from individual if statements
//        assert(false)
//        
//        return UITableViewCell()
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//            
//            if (section == cardListSection) {
//                return arrCardList.count
//                // return StripePaymentService.sharedInstance().paymentMethods.count;
//            } else if (section == addPaymentSection) {
//                return 1;
//            } else if (section == defaultPaymentSection) {
//                return (StripePaymentService.sharedInstance().defaultPaymentMethod != nil) ? 1 : 0;
//            }
//            
//        #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//            
//            if (section == cardListSection) {
//                return  arrCardList.count
//                return BraintreePaymentService.sharedInstance().paymentMethods.count;
//            } else if (section == addPaymentSection) {
//                return 1;
//            } else if (section == defaultPaymentSection) {
//                return (BraintreePaymentService.sharedInstance().defaultPaymentMethod != nil) ? 1 : 0;
//            }
//            
//        #endif
//        
//        return 0;
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 38))
//        
//        var headerLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 38))
//        headerLbl.textAlignment = .center
//        
//        if (section == cardListSection) {
//            
//            headerLbl.text = "Payment methods"
//        } else if (section == addPaymentSection) {
//            headerLbl.text = "Add payment method"
//        } else if (section == defaultPaymentSection) {
//            headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
//            
//            headerLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
//            
//            //headerLbl.text = "Payment defaults"
//            headerLbl.text = ""
//        }
//        
//        headerView.addSubview(headerLbl)
//        
//        return headerView
//    }
//    //    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//    //        let header = view as! UITableViewHeaderFooterView
//    //        header.textLabel?.textColor = UIColor.white
//    //        header.textLabel?.textAlignment =
//    //        if (section == cardListSection) {
//    //            header.textLabel?.text = "Payment methods"
//    //        } else if (section == addPaymentSection) {
//    //            header.textLabel?.text = "Add payment method"
//    //        } else if (section == defaultPaymentSection) {
//    //            header.textLabel?.text = "Payment defaults"
//    //        }
//    //
//    //        return header
//    //    }
//    
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if (section == cardListSection) {
//            return "Payment methods"
//        } else if (section == addPaymentSection) {
//            return "Add payment method"
//        } else if (section == defaultPaymentSection) {
//            return "Payment defaults"
//        }
//        return ""
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // Return the number of sections.
//        return totalSections;
//    }
//    
//    
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if indexPath.section == cardListSection {
//            print("cardListSection")
//            return 60
//        }
//        else if indexPath.section == addPaymentSection {
//            print("addPaymentSection")
//            return 120
//        }
//        else if indexPath.section == defaultPaymentSection {
//            print("defaultPaymentSection")
//            return 0
//        }
//        return 0
//    }
//    
//    
//    //MARK: - UITableView Delegate
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
//        
//        if (indexPath.section == cardListSection) {
//            
//            if (controllerType == PaymentViewControllerType.listPayment) {
//                
//                let editCardViewController = paymentStoryboard.instantiateViewController(withIdentifier: "AddPaymentViewControllerIdentifier") as! AddPaymentViewController
//                
//                editCardViewController.editDelegate = self
//                self.selectedIndexPath = indexPath
//                
//                #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                    
//                    let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)!
//                    if let card = paymentMethod as? STPCard {
//                        
//                        editCardViewController.cardToBeEdited = card
//                        editCardViewController.isEditCard = true
//                        self.navigationController!.pushViewController(editCardViewController, animated: true)
//                    }
//                    
//                #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                    
//                    
//                    var paymentObjectModel = PaymentDetailsObject()
//                    paymentObjectModel = self.arrCardList[indexPath.row] as! PaymentDetailsObject
//                    editCardViewController.isEditCard = true
//                    editCardViewController.updatecardToken = paymentObjectModel.token
//                    editCardViewController.Cardmodel = paymentObjectModel
//                    self.navigationController!.pushViewController(editCardViewController, animated: true)
//                    
//                #endif
//            } else if (controllerType == PaymentViewControllerType.pickDefault) {
//                
//                let oldSelectedCell = tableView.cellForRow(at: self.selectedIndexPath!)
//                oldSelectedCell?.accessoryType = .none
//                
//                let newSelectedCell = tableView.cellForRow(at: indexPath)
//                newSelectedCell?.accessoryType = .checkmark
//                
//                self.selectedIndexPath = indexPath
//                
//            } else if (controllerType == PaymentViewControllerType.pickForRide) {
//                /*
//                
//                #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                    
//                    let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)
//                    
//                #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                    
//                    let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)!
//                    
//                #endif
//                
//                self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: paymentMethod,
//                                                           controllerType: PaymentViewControllerType.pickForRide)
// */
//                #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                    
//                    let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)
//                    
//                #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                    
//                    //let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue((sender as AnyObject).tag)!
//                    let paymentMethod = arrCardList.object(at:indexPath.row) as! PaymentDetailsObject
//                    
//                #endif
//                
//                // self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: paymentMethod,controllerType: PaymentViewControllerType.pickForRide)
//                self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: paymentMethod, controllerType: PaymentViewControllerType.pickForRide)
//                
//            }
//        } else if (indexPath.section == addPaymentSection) {
//            
//            let apViewController = paymentStoryboard.instantiateViewController(withIdentifier: "AddPaymentViewControllerIdentifier") as! AddPaymentViewController
//            
//            apViewController.addDelegate = self
//            self.navigationController!.pushViewController(apViewController, animated: true)
//            
//        } else if (indexPath.section == defaultPaymentSection) {
//            let paymentViewController = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentViewControllerIdentifier") as! PaymentViewController
//            
//            paymentViewController.controllerType = PaymentViewControllerType.pickDefault
//            paymentViewController.delegate = self
//            
//            self.navigationController!.pushViewController(paymentViewController, animated: true)
//        }
//    }
//    func getPayment()
//    {
//        
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//        
//        let client: BAAClient = BAAClient.shared()
//        client.getPaymentMethods(BAASBOX_RIDER_STRING, completion:{(success, error) -> Void in
//            if ((success) != nil) {
//                
//                //let bid = PaymentObjectModels(JSONString: jsonCustomString)!
//                if let resultArray = success as? Array<Any>
//                {
//                    let paymentObjectModel = PaymentDetailsObject()
//                    self.arrCardList = paymentObjectModel.savePaymentCardDetails(responseArr: resultArray as NSArray)
//                    //self.arrCardList = success as! NSArray
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                    
//                    print(success as Any)
//                    DDLogVerbose("getPayment Data: \(success)")
//                }
//                else {
//                    DDLogError("Error in fetching Get Method: \(error)")
//                }
//                
//            }
//            else {
//                DDLogVerbose("getPayment failed: \(error)")
//            }
//            
//            ActivityIndicatorUtil.disableActivityIndicator(self.view)
//        })
//        
//        
//    }
//    // MARK: - Payment defaults Button Action
//    
//    @IBAction func paymentDefaultsSettingBtnAction(_ sender: AnyObject) {
//        
//        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
//        
//        if (controllerType == PaymentViewControllerType.listPayment) {
//            
//            let editCardViewController = paymentStoryboard.instantiateViewController(withIdentifier: "AddPaymentViewControllerIdentifier") as! AddPaymentViewController
//            
//            editCardViewController.editDelegate = self
//            
//            let index = NSIndexPath(row: (sender as AnyObject).tag, section: 0)
//            self.selectedIndexPath = index as IndexPath
//            
//            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                
//                let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)!
//                if let card = paymentMethod as? STPCard {
//                    
//                    editCardViewController.cardToBeEdited = card
//                    editCardViewController.isEditCard = true
//                    self.navigationController!.pushViewController(editCardViewController, animated: true)
//                }
//                
//            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                
//                let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue((sender as AnyObject).tag)!
//                
//                editCardViewController.cardToBeEdited = paymentMethod
//                editCardViewController.isEditCard = true
//                self.navigationController!.pushViewController(editCardViewController, animated: true)
//                
//            #endif
//        } else if (controllerType == PaymentViewControllerType.pickDefault) {
//            
//            let oldSelectedCell = tableView.cellForRow(at: self.selectedIndexPath!)
//            oldSelectedCell?.accessoryType = .none
//            
//            let index = NSIndexPath(row: (sender as AnyObject).tag, section: 0)
//            
//            let newSelectedCell = tableView.cellForRow(at: index as IndexPath)
//            newSelectedCell?.accessoryType = .checkmark
//            
//            self.selectedIndexPath = index as IndexPath
//            
//        } else if (controllerType == PaymentViewControllerType.pickForRide) {
//            
//            #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//                
//                let paymentMethod = StripePaymentService.sharedInstance().paymentMethods.safeValue(indexPath.row)
//                
//            #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//                
//                //let paymentMethod = BraintreePaymentService.sharedInstance().paymentMethods.safeValue((sender as AnyObject).tag)!
//                let paymentMethod = arrCardList.object(at: (sender as AnyObject).tag) as! PaymentDetailsObject
//                
//            #endif
//            
//           // self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: paymentMethod,controllerType: PaymentViewControllerType.pickForRide)
//            self.delegate?.selectPaymentViewController(selectPaymentViewController: self, didSelectPaymentMethod: paymentMethod, controllerType: PaymentViewControllerType.pickForRide)
//            
//        }
//    }
//    
//    
//    
//    @IBAction func paymentDefaultsSelectedcardColorBtnAction(_ sender: UIButton) {
//        
//        let  paymentObjectModel = self.arrCardList[sender.tag] as! PaymentDetailsObject
//        
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//        
//        let client: BAAClient = BAAClient.shared()
//        client.makeDefaultPaymentMethod(BAASBOX_RIDER_STRING, paymentMethodToken: paymentObjectModel.token, completion: {(success, error) -> Void in
//            
//            ActivityIndicatorUtil.disableActivityIndicator(self.view)
//            
//            if ((success) != nil) {
//                DDLogVerbose("makeDefaultPaymentMethod in successfully \(success)")
//                
//                DispatchQueue.main.async {
//                    self.getPayment()
//                    // self.tableView.reloadData()
//                }
//            }
//            else {
//                DDLogVerbose("Error makeDefaultPaymentMethod in: \(error)")
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
//    // MARK: - Navigation
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "rideDetail" {
//            //            let indexPath = self.tableView!.indexPathForSelectedRow
//            //            let destinationViewController: RideDetailViewController = segue.destinationViewController as! RideDetailViewController
//        }
//    }
//    
//    // MARK: - AddPaymentViewControllerDelegate
//    
//    func addPaymentViewControllerDidCancel(_ addPaymentViewController: AddPaymentViewController) {
//        self.navigationController!.popViewController(animated: true)
//    }
//    
//    func editPaymentViewControllerDidCancel(_ editPaymentViewController: AddPaymentViewController) {
//        self.navigationController!.popViewController(animated: true)
//    }
//    
//    func selectPaymentViewControllerDidCancel(_ selectPaymentViewController: PaymentViewController) {
//        self.navigationController!.popViewController(animated: true)
//    }
//    
//    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//    
//    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
//    didCreateToken token: STPToken, completion: STPErrorBlock) {
//    
//    StripePaymentService.sharedInstance().attachSourceToCustomer(token, completionBlock: {(error: NSError?) -> Void in
//    
//    // execute the completion block first
//    completion(error)
//    
//    if (error == nil) {
//    self.navigationController!.popViewControllerAnimated(true)
//    
//    // Completely reload the view as it may have changed the default payment
//    self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
//    withObject:nil, afterDelay:0.0)
//    }
//    })
//    }
//    
//    // MARK: - EditPaymentViewControllerDelegate
//    
//    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
//    didRemovePaymentMethod paymentMethod: STPPaymentMethod, completion: STPErrorBlock) {
//    
//    if paymentMethod is STPSource {
//    let source = paymentMethod as! STPSource
//    
//    StripePaymentService.sharedInstance().deleteSourceFromCustomer(source, completionBlock: {(error: NSError?) -> Void in
//    
//    // execute the completion block first
//    completion(error)
//    
//    if (error == nil) {
//    self.navigationController!.popViewControllerAnimated(true)
//    
//    // Completely reload the view as it may have changed the default payment
//    self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
//    withObject:nil, afterDelay:0.0)
//    }
//    })
//    }
//    }
//    
//    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//    
//    func addPaymentViewController(addPaymentViewController: AddPaymentViewController,
//                                  didCreateNonce paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock) {
//        
//        BraintreePaymentService.sharedInstance().attachSourceToCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
//            
//            // execute the completion block first
//            completion(error)
//            
//            if (error == nil) {
//                self.navigationController!.popViewController(animated: true)
//                
//                // Completely reload the view as it may have changed the default payment
//                self.perform(#selector(PaymentViewController.reloadCustomerDetails),
//                             with:nil, afterDelay:0.0)
//            }
//        })
//    }
//    
//    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
//                                   didRemovePaymentMethod paymentMethod: String, completion: @escaping BTErrorBlock) {
//        
//        BraintreePaymentService.sharedInstance().deleteSourceFromCustomer(paymentMethod, completionBlock: {(error: NSError?) -> Void in
//            
//            // execute the completion block first
//            completion(error)
//            
//            if (error == nil) {
//                self.navigationController!.popViewController(animated: true)
//                
//                // Completely reload the view as it may have changed the default payment
//                self.perform(#selector(PaymentViewController.reloadCustomerDetails),
//                             with:nil, afterDelay:0.0)
//            }
//        })
//    }
//    
//    #endif
//    
//    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
//    
//    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
//    didCreateNewToken token: STPToken, completion: STPErrorBlock) {
//    
//    let oldSource = StripePaymentService.sharedInstance().paymentMethods.safeValue(selectedIndexPath!.row)
//    
//    StripePaymentService.sharedInstance().updateSourceForCustomer(token,
//    oldSource: oldSource as! STPSource,
//    completionBlock: {(error: NSError?) -> Void in
//    
//    // execute the completion block first
//    completion(error)
//    
//    if (error == nil) {
//    self.navigationController!.popViewControllerAnimated(true)
//    
//    // Completely reload the view as it may have changed the default payment
//    self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
//    withObject:nil, afterDelay:0.0)
//    }
//    })
//    }
//    
//    // MARK: - SelectPaymentViewControllerDelegate
//    
//    func selectPaymentViewController(selectPaymentViewController: PaymentViewController, didSelectPaymentMethod method: STPPaymentMethod, controllerType: PaymentViewControllerType) {
//    
//    if (controllerType == PaymentViewControllerType.PickDefault) {
//    
//    if method is STPSource {
//    let source = method as! STPSource
//    
//    StripePaymentService.sharedInstance().selectDefaultCustomerSource(source, completionBlock: {(error: NSError?) -> Void in
//    
//    if (error == nil) {
//    self.navigationController!.popViewControllerAnimated(true)
//    
//    // Completely reload the view as it may have changed the default payment
//    self.performSelector(#selector(PaymentViewController.reloadCustomerDetails),
//    withObject:nil, afterDelay:0.0)
//    } else {
//    AlertUtil.displayAlert(error!.localizedDescription,
//    message: error!.localizedFailureReason ?? "Default could not be changed.")
//    }
//    })
//    }
//    } else if (controllerType == PaymentViewControllerType.PickForRide) {
//    
//    }
//    }
//    
//    func reloadCustomerDetails() {
//    
//    StripePaymentService.sharedInstance().loadCustomerDetails({
//    // reload the tableview in case the table datasource methods already fired
//    self.tableView.reloadData()
//    })
//    }
//    
//    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
//    
//    func editPaymentViewController(editPaymentViewController: AddPaymentViewController,
//                                   didCreateNewToken paymentMethod: BTPaymentMethodNonce, completion: @escaping BTErrorBlock) {
//        //rahul
//        
//        var paymentObjectModel = PaymentDetailsObject()
//        paymentObjectModel = self.arrCardList[selectedIndexPath!.row] as! PaymentDetailsObject
//        
//        BraintreePaymentService.sharedInstance().updateSourceForCustomer(paymentMethod,
//                                                                         oldPaymentMethod: paymentObjectModel.token,
//                                                                         completionBlock: {(error: Error?) -> Void in
//                                                                            
//                                                                            // execute the completion block first
//                                                                            completion(error as NSError?)
//                                                                            
//                                                                            if (error == nil) {
//                                                                                self.navigationController!.popViewController(animated: true)
//                                                                                
//                                                                                // Completely reload the view as it may have changed the default payment
//                                                                                self.perform(#selector(PaymentViewController.reloadCustomerDetails),
//                                                                                             with:nil, afterDelay:0.0)
//                                                                            }
//        })
//    }
//    
//    // MARK: - SelectPaymentViewControllerDelegate
//    
//    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
//                                     didSelectPaymentMethod paymentMethod: BTPaymentMethodNonce,
//                                     controllerType: PaymentViewControllerType) {
//        
//        if (controllerType == PaymentViewControllerType.pickDefault) {
//            
//            BraintreePaymentService.sharedInstance().selectDefaultCustomerSource(paymentMethod, completionBlock: {(error: NSError?) -> Void in
//                
//                if (error == nil) {
//                    self.navigationController!.popViewController(animated: true)
//                    
//                    // Completely reload the view as it may have changed the default payment
//                    self.perform(#selector(PaymentViewController.reloadCustomerDetails),
//                                 with:nil, afterDelay:0.0)
//                } else {
//                    AlertUtil.displayAlert(error!.localizedDescription,
//                                           message: error!.localizedFailureReason ?? "Default could not be changed.")
//                }
//            })
//        } else if (controllerType == PaymentViewControllerType.pickForRide) {
//            
//        }
//    }
//    func selectPaymentViewController(selectPaymentViewController: PaymentViewController, didSelectPaymentMethod method: PaymentDetailsObject, controllerType: PaymentViewControllerType) {
//        
//    }
//    func reloadCustomerDetails() {
//        BraintreePaymentService.sharedInstance().loadCustomerDetails({(arrlist: NSArray?,error: NSError?) -> Void in
//            ActivityIndicatorUtil.enableActivityIndicator(self.view)
//            
//            if (error == nil) {
//                let paymentObjectModel = PaymentDetailsObject()
//                self.arrCardList = paymentObjectModel.savePaymentCardDetails(responseArr: arrlist! as NSArray)
//                //self.arrCardList = success as! NSArray
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//            else {
//                DDLogError("Error in fetching Get Method: \(error)")
//            }
//            
//            ActivityIndicatorUtil.disableActivityIndicator(self.view)
//        })
//    }
//    #endif
//}
//
//
//
//
