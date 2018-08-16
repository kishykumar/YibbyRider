//
//  ConfirmRideViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import BaasBoxSDK
import GoogleMaps
import OHHTTPStubs

class ConfirmRideViewController: BaseYibbyViewController {

    // MARK: - Properties
    
    @IBOutlet weak var cancelButtonOutlet: YibbyButton1!
    @IBOutlet weak var acceptButtonOutlet: YibbyButton1!
    
    var pickupLocation: YBLocation!
    var dropoffLocation: YBLocation!
    
    var bidPrice: Float!
    var numPeople: Int = 4
    var currentPaymentMethod: YBPaymentMethod!
    
    let NO_DRIVERS_FOUND_ERROR_CODE = 20099

    // MARK: - Actions
    
    @IBAction func onCancelButtonClick(_ sender: AnyObject) {
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAcceptButtonClick(_ sender: AnyObject) {
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
                ActivityIndicatorUtil.enableActivityIndicator(self.view, title: "Finding offers")
                
                let client: BAAClient = BAAClient.shared()

                client.createBid(self.bidPrice as NSNumber?,
                                 pickupLat: self.pickupLocation.latitude as NSNumber?,
                                 pickupLong: self.pickupLocation.longitude as NSNumber?,
                                 pickupLoc: self.pickupLocation.name!,
                                 dropoffLat: self.dropoffLocation.latitude as NSNumber?,
                                 dropoffLong: self.dropoffLocation.longitude as NSNumber?,
                                 dropoffLoc: self.dropoffLocation.name!,
                                 paymentMethodToken: currentPaymentMethod.token!,
                                 paymentMethodBrand: currentPaymentMethod.type!,
                                 paymentMethodLast4: currentPaymentMethod.last4!,
                                 numPeople: numPeople as NSNumber?,
                                 completion: {(success, error) -> Void in
                        
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if (error == nil) {
                            // check the internal error codes even if it's success as we may not have any drivers
                            if let bbCode = (success as AnyObject)["bb_code"] as? Int {
                                if (bbCode == self.NO_DRIVERS_FOUND_ERROR_CODE) {
                                    
                                    AlertUtil.displayAlertOnVC(self,
                                                               title: "No drivers online.",
                                                               message: "", completionBlock: {
                                          
                                        self.navigationController!.dismiss(animated: true, completion: nil)
                                    })
                                    
                                } else {
                                    DDLogVerbose("Unexpected Error: success var: \(String(describing: success))")
                                    
                                    AlertUtil.displayAlertOnVC(self,
                                                               title: "Unexpected error. Please be patient and try again.",
                                                               message: "", completionBlock: {
                                                                
                                        self.navigationController!.dismiss(animated: true, completion: nil)
                                    })
                                }
                            } else {
                                
                                if let successData = (success as AnyObject)["data"] as? [String: NSObject] {
                                    
                                    let pickupLoc = YBLocation(lat: successData["pickupLat"] as! Double,
                                                                    long: successData["pickupLong"] as! Double,
                                                                    name: successData["pickupLoc"] as! String)
                                    
                                    let dropoffLoc = YBLocation(lat: successData["dropoffLat"] as! Double,
                                                                    long: successData["dropoffLong"] as! Double,
                                                                    name: successData["dropoffLoc"] as! String)
                                    
                                    // set the bid state
                                    let userBid = Bid()
                                    userBid.id = (successData["id"] as! String)
                                    userBid.bidPrice = (successData["bidPrice"] as! Double)
                                    userBid.pickupLocation = pickupLoc
                                    userBid.dropoffLocation = dropoffLoc
                                    userBid.people = (successData["people"] as? Int)
                                    userBid.creationTime = (successData["_creation_date"] as! String)

                                    DDLogVerbose("createBid received bidID: \(String(describing: userBid.id))")
                                    YBClient.sharedInstance().status = .ongoingBid
                                    YBClient.sharedInstance().bid = userBid
                                    
                                    
                                    self.performSegue(withIdentifier: "findOffersSegue", sender: nil)
                                } else {
                                    
                                    AlertUtil.displayAlertOnVC(self,
                                                               title: "Unexpected error. Please be patient and try again.",
                                                               message: "", completionBlock: {
                                                                
                                        self.navigationController!.dismiss(animated: true, completion: nil)
                                    })
                                }
                            }
                        }
                        else {
                            errorBlock(success, error)
                        }
                })
        })
    }

    // MARK: - Setup
    
    fileprivate func setupUI() {
        self.cancelButtonOutlet.color = UIColor.red
        self.acceptButtonOutlet.color = UIColor.appDarkGreen1()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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

}
