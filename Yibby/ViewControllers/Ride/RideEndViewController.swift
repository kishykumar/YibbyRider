//
//  RideEndViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/14/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import BaasBoxSDK
import Cosmos
import StepSlider
import AMPopTip
import GoogleMaps
import Braintree

class RideEndViewController: BaseYibbyViewController {

    // MARK: - Properties
    
    @IBOutlet var carImage: UIImageView!
    @IBOutlet var driverImage: UIImageView!
    
    @IBOutlet var rideDateLbl: UILabel!
    @IBOutlet var carNumberLbl: UILabel!
    
    @IBOutlet weak var rideFareLabel: UILabel!
    @IBOutlet var finishBtn: UIButton!
    @IBOutlet weak var moreInfoButtonOutlet: UIButton!
    
    @IBOutlet var tipVW: UIView!
    
    @IBOutlet weak var innerContentViewOutlet: UIView!
    @IBOutlet weak var tipSliderViewOutlet: StepSlider!
    @IBOutlet weak var ratingViewOutlet: CosmosView!
    @IBOutlet weak var tripDestinationMapViewOutlet: GMSMapView!
    
    var finalTipAmount: Double = 0.0
    var popTip = PopTip()
    
    // MARK: - Actions
    @IBAction func onTipViewClick(_ sender: UIButton) {
        popTip.show(text: "New price includes tip", direction: .right, maxWidth: 200, in: innerContentViewOutlet, from: moreInfoButtonOutlet.frame)
    }
    
    @IBAction func onTipSliderValueChange(_ sender: StepSlider) {
        
        if (sender.index != 0) {
            rideFareLabel.textColor = UIColor.appDarkGreen1()
            moreInfoButtonOutlet.isHidden = false
            
            switch (sender.index) {
            case 1:
                finalTipAmount = 1.0
                break
            case 2:
                finalTipAmount = 2.0
                break
            case 3:
                finalTipAmount = 5.0
                break
            case 4:
                // TODO: Pop up for customer tip
                
                break
            default:
                
                break
            }
            
        } else {
            rideFareLabel.textColor = UIColor.darkGray
            moreInfoButtonOutlet.isHidden = true
        }
    }
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupUI() {
        
        setupMenuButton()
        
        rideFareLabel.textColor = UIColor.darkGray
        
        moreInfoButtonOutlet.isHidden = true
        
        carImage.layer.borderColor = UIColor.borderColor().cgColor
        carImage.layer.borderWidth = 2.0
        carImage.layer.cornerRadius = carImage.frame.size.width/2-4
        
        driverImage.layer.borderColor = UIColor.borderColor().cgColor
        driverImage.layer.borderWidth = 2.0
        driverImage.layer.cornerRadius = 25
        driverImage.clipsToBounds = true
        
        //finishBtn.layer.borderColor = UIColor.lightGray.cgColor
        //finishBtn.layer.borderWidth = 1.0
        finishBtn.layer.cornerRadius = 7
        
        innerContentViewOutlet.layer.shadowOpacity = 0.50
        innerContentViewOutlet.layer.shadowRadius = 5.0
        innerContentViewOutlet.layer.shadowColor = UIColor.gray.cgColor
        innerContentViewOutlet.layer.shadowOffset = CGSize.zero // CGSize(width: 0, height: -2)
        
        tipVW.layer.borderColor = UIColor.lightGray.cgColor
        tipVW.layer.borderWidth = 1.5
        tipVW.layer.cornerRadius = 7
        
        tipSliderViewOutlet.labels = ["No tip", "$1", "$2", "$5", "Other"]
        tipSliderViewOutlet.labelOrientation = .up
        tipSliderViewOutlet.labelFont = UIFont.boldSystemFont(ofSize: 16.0)
        
        popTip.bubbleColor = .clear
        popTip.textColor = .lightGray
        popTip.borderWidth = 1.0
        popTip.borderColor = .lightGray
        popTip.font = UIFont.systemFont(ofSize: 12)
        
        popTip.entranceAnimation = .none
        popTip.exitAnimation = .none
        
        tripDestinationMapViewOutlet.isUserInteractionEnabled = false
        tripDestinationMapViewOutlet.layer.borderWidth = 2.0
        tripDestinationMapViewOutlet.layer.borderColor = UIColor.borderColor().cgColor
        tripDestinationMapViewOutlet.layer.cornerRadius = tripDestinationMapViewOutlet.frame.size.width/2-4

        if let ride = YBClient.sharedInstance().ride {
            
            if let rideISODateTime = ride.datetime, let rideDate = TimeUtil.getDateFromISOTime(rideISODateTime) {
                let prettyDate = TimeUtil.prettyPrintDate1(rideDate)
                rideDateLbl.text = prettyDate
            }

            tipSliderViewOutlet.sliderCircleImage = BraintreeCardUtil.paymentMethodImageFromBrand(ride.paymentMethodBrand)
            
            if let dropoffCoordinate = ride.dropoffLocation?.coordinate() {
                let domarker = GMSMarker(position: dropoffCoordinate)
                domarker.icon = UIImage(named: "famarker_red")
                domarker.map = tripDestinationMapViewOutlet
                
                tripDestinationMapViewOutlet.camera =
                    GMSCameraPosition.camera(withLatitude: dropoffCoordinate.latitude,
                                            longitude: dropoffCoordinate.longitude,
                                            zoom: 13)
            }
            
            if let myDriver = ride.driver {
                
                if let driverProfilePic = myDriver.profilePictureFileId {
                    if (driverProfilePic != "") {
                        if let imageUrl  = BAAFile.getCompleteURL(withToken: driverProfilePic) {
                            driverImage.pin_setImage(from: imageUrl)
                        }
                    }
                }
            }
            
            if let driverVehicle = ride.vehicle {
                carNumberLbl.text = driverVehicle.licensePlate
                
                if let carPic = driverVehicle.vehiclePictureFileId {
                    if (carPic != "") {
                        if let imageUrl  = BAAFile.getCompleteURL(withToken: carPic) {
                            carImage.pin_setImage(from: imageUrl)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func finishBtnAction(_ sender: Any) {
        
        let rating = String(ratingViewOutlet.rating)
        
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        let reviewDict = ["bidId": YBClient.sharedInstance().bid!.id!,
                          "feedback": "Hello I am here",
                          "rating": rating,
                          "tip": String(finalTipAmount)]
        
            client.postReview(BAASBOX_RIDER_STRING, jsonBody: reviewDict, completion:{(success, error) -> Void in
            if ((success) != nil) {
                self.performSegue(withIdentifier: "unwindToMainViewController1", sender: self)
                DDLogVerbose("Review success: \(success)")
            }
            else {
                self.performSegue(withIdentifier: "unwindToMainViewController1", sender: self)
                DDLogVerbose("Review failed: \(error)")
            }
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Cosmos Rating View
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIButton, button === finishBtn else {
            DDLogVerbose("The finish button was not pressed, cancelling")
            return
        }
        DDLogVerbose("The finish button was pressed, success")
    }
}
