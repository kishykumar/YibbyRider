//
//  TripViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import BaasBoxSDK
import GoogleMaps

class TripViewController: BaseYibbyViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tripProgressLabelOutlet: UILabel!
    @IBOutlet weak var etaLabelOutlet: UILabel!
    @IBOutlet weak var driverLocMapViewOutlet: GMSMapView!

    var bid: Bid!

    // MARK: - Actions
    
    @IBAction func cancelRideAction(_ sender: AnyObject) {
        
        
        return;
        
        // show a selection box for cancellation reasons
        
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
                // enable the loading activity indicator
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.shared()
                
                client.cancelRiderRide(self.bid.id, completion: {(success, error) -> Void in
                    
                    // diable the loading activity indicator
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                    if (error == nil) {

//                        let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
//                        
//                        let rideEndViewController = rideStoryboard.instantiateViewControllerWithIdentifier("RideEndViewControllerIdentifier") as! RideEndViewController
//                        
//                        // get the navigation VC and push the new VC
//                        self.navigationController!.pushViewController(rideEndViewController, animated: true)
                    }
                    else {
                        errorBlock(success, error)
                    }
                })
        })
    }
    
    // MARK: - Setup functions 
    
    func initProperties() {
        self.bid = (YBClient.sharedInstance().getBid())!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        initProperties()
    }

    fileprivate func setupUI() {
    self.customBackButton(y: 20 as AnyObject)
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
