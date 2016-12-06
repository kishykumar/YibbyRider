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
    
    var pickupLatLng: CLLocationCoordinate2D!
    var pickupPlaceName: String!
    
    var dropoffLatLng: CLLocationCoordinate2D!
    var dropoffPlaceName: String!
    
    var bidLow: Float!
    var bidHigh: Float!
    
    let NO_DRIVERS_FOUND_ERROR_CODE = 20099

    // MARK: - Actions
    
    @IBAction func onCancelButtonClick(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func onAcceptButtonClick(sender: AnyObject) {
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: (BAAObjectResultBlock)) -> Void in
                
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.sharedClient()
                
                client.createBid(self.bidHigh,
                    bidLow: self.bidLow, etaHigh: 0, etaLow: 0, pickupLat: self.pickupLatLng!.latitude,
                    pickupLong: self.pickupLatLng!.longitude, pickupLoc: self.pickupPlaceName,
                    dropoffLat: self.dropoffLatLng!.latitude, dropoffLong: self.dropoffLatLng!.longitude,
                    dropoffLoc: self.dropoffPlaceName, completion: {(success, error) -> Void in
                        
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if (error == nil) {
                            // check the error codes
                            if let bbCode = success["bb_code"] as? String {
                                if (Int(bbCode) == self.NO_DRIVERS_FOUND_ERROR_CODE) {
                                    
                                    // TODO: display alert that no drivers are online
                                    AlertUtil.displayAlert("No drivers online.", message: "")
                                } else {
                                    AlertUtil.displayAlert("Unexpected error. Please be patient.", message: "")
                                    DDLogVerbose("Unexpected Error: success var: \(success)")
                                }
                            } else {
                                
                                if let successData = success["data"] as? [String: NSObject] {
                                    
                                    // set the bid state
                                    
                                    let userBid: Bid = Bid(id: successData["id"] as! String,
                                        bidHigh: successData["bidHigh"] as! Int,
                                        bidLow: successData["bidLow"] as! Int,
                                        etaHigh: successData["etaHigh"] as! Int,
                                        etaLow: successData["etaLow"] as! Int,
                                        pickupLat: successData["pickupLat"] as! Double,
                                        pickupLong: successData["pickupLong"] as! Double,
                                        pickupLoc: successData["pickupLoc"] as! String,
                                        dropoffLat: successData["dropoffLat"] as! Double,
                                        dropoffLong: successData["dropoffLong"] as! Double,
                                        dropoffLoc: successData["dropoffLoc"] as! String)!
                                    
                                    BidState.sharedInstance().setOngoingBid(userBid)
                                    
                                    self.performSegueWithIdentifier("findOffersSegue", sender: nil)
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
        
        self.view.backgroundColor = UIColor.navyblue1()
        
        self.cancelButtonOutlet.color = UIColor.redColor()
        self.acceptButtonOutlet.color = UIColor.appDarkGreen1()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
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
