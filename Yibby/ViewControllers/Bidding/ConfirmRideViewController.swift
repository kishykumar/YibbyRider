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

class ConfirmRideViewController: BaseYibbyViewController {

    // MARK: - Properties
    
    @IBOutlet weak var cancelButtonOutlet: YibbyButton1!
    @IBOutlet weak var acceptButtonOutlet: YibbyButton1!
    
    var pickupLocation: YBLocation!
    var dropoffLocation: YBLocation!
    
    var bidHigh: Float!
    var currentPaymentMethod: YBPaymentMethod!
    
    let NO_DRIVERS_FOUND_ERROR_CODE = 20099

    // MARK: - Actions
    
    @IBAction func onCancelButtonClick(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onAcceptButtonClick(_ sender: AnyObject)
    /*{
        self.performSegue(withIdentifier: "findOffersSegue", sender: nil)
    }*/
    {
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.shared()
                let paymentToken = currentPaymentMethod.token

                client.createBid(self.bidHigh as NSNumber!, bidLow: 0, etaHigh: 0, etaLow: 0, pickupLat: self.pickupLocation.latitude as NSNumber!,
                    pickupLong: self.pickupLocation.longitude as NSNumber!, pickupLoc: self.pickupLocation.name!,
                    dropoffLat: self.dropoffLocation.latitude as NSNumber!, dropoffLong: self.dropoffLocation.longitude as NSNumber!,
                    dropoffLoc: self.dropoffLocation.name!,paymentMethodToken: paymentToken!, completion: {(success, error) -> Void in
                        
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if (error == nil) {
                            // check the error codes
                            if let bbCode = (success as AnyObject)["bb_code"] as? String {
                                if (Int(bbCode) == self.NO_DRIVERS_FOUND_ERROR_CODE) {
                                    
                                    // TODO: display alert that no drivers are online
                                    AlertUtil.displayAlert("No drivers online.", message: "")
                                } else {
                                    AlertUtil.displayAlert("Unexpected error. Please be patient.", message: "")
                                    DDLogVerbose("Unexpected Error: success var: \(success)")
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
                                    userBid.bidHigh = (successData["bidHigh"] as! Double)
                                    userBid.pickupLocation = pickupLoc
                                    userBid.dropoffLocation = dropoffLoc
                                    userBid.people = (successData["people"] as? Int)
                                    userBid.creationTime = (successData["_creation_date"] as! String)
                                    
                                    YBClient.sharedInstance().bid = userBid
                                    
                                    self.performSegue(withIdentifier: "findOffersSegue", sender: nil)
                                } else {
                                    AlertUtil.displayAlert("Unexpected error. Please be patient.", message: "")
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
    
    func setupUI() {
        
        //self.view.backgroundColor = UIColor.navyblue1()
        self.view.backgroundColor = UIColor(red: 39/255, green: 56/255, blue: 76/255, alpha: 1)
        
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
