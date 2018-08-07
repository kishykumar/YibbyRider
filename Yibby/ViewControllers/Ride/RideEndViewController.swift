//
//  RideEndViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/14/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import CocoaLumberjack
import BaasBoxSDK
import Cosmos
import StepSlider
import AMPopTip
import GoogleMaps
import Braintree
import ActionSheetPicker_3_0

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
        
        // TODO: if the ride was more than 2 days old, sorry you can't tip now!
        // if let ride = YBClient.sharedInstance().ride {
        // if (rideDate > 2 days) {
        //  return;
        // } }

        if (sender.index != 0) {
            //rideFareLabel.textColor = UIColor.appDarkGreen1()
            moreInfoButtonOutlet.isHidden = true
            
            switch (sender.index) {
                
            case 0:
                assert(false) // zero handle in the else case
                
            case 1:
                finalTipAmount = 1.0

            case 2:
                finalTipAmount = 2.0

            case 3:
                finalTipAmount = 5.0

            case 4:
                
                ActionSheetStringPicker.show(withTitle: InterfaceString.ActionSheet.SelectTip, rows: ArrayUtil.Resource.StaticIntList1to50, initialSelection: 5, doneBlock: {
                    picker, value, index in
                    
                    if let tipAmountInt = index as? Int {
                        self.finalTipAmount = Double(tipAmountInt)
                        
                        // Other option is tip is at index=4
                        self.tipSliderViewOutlet.labels[4] = "$\(tipAmountInt)"
                        
                        self.updateFinalFareWithTip()
                    }
                    
                    return
                }, cancel: { ActionStringCancelBlock in return }, origin: tipSliderViewOutlet)
                
            default:
                break
            }
            
            updateFinalFareWithTip()
            
        } else {
            rideFareLabel.textColor = UIColor.darkGray
            moreInfoButtonOutlet.isHidden = true
            
            finalTipAmount = 0.0
            updateFinalFareWithTip()
        }
    }
    
    // MARK: - Setup
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        
        DDLogVerbose("KKDBG_REVC init")
    }
    
    deinit {
        DDLogVerbose("KKDBG_REVC DE-init")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
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
            
            let rideFareInt = Int(ride.bidPrice!)
            rideFareLabel.text = "$\(rideFareInt)"
            
            if let rideISODateTime = ride.datetime, let rideDate = TimeUtil.getDateFromISOTime(rideISODateTime) {
                let prettyDate = TimeUtil.prettyPrintDate1(rideDate)
                rideDateLbl.text = prettyDate
            }

            tipSliderViewOutlet.sliderCircleImage = BraintreeCardUtil.paymentMethodImageFromBrand(ride.paymentMethodBrand)
            
            // TODO: if the ride was more than 2 days old, sorry you can't tip now!
            // if (rideDate > 2 days) {
            // tipSliderViewOutlet.isEnabled = false
            // }
            
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
                carNumberLbl.text = driverVehicle.licensePlate?.uppercased()
                
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
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.shared()
                
                let reviewDict = ["bidId": YBClient.sharedInstance().bid!.id!,
                                  "feedback": "Hello I am here",
                                  "rating": rating,
                                  "tip": String(finalTipAmount)]

                client.postReview(BAASBOX_RIDER_STRING, jsonBody: reviewDict, completion:{(success, error) -> Void in

                    ActivityIndicatorUtil.disableActivityIndicator(self.view)

                    if ((success) != nil) {
                        DDLogVerbose("Review success: \(String(describing: success))")
                        
                        AlertUtil.displayAlertOnVC(self, title: "Thanks for taking a ride with Yibby.",
                                               message: "See you again!",
                                               completionBlock: {() -> Void in
                                                
                                                // Trigger unwind segue to MainViewController
                                                self.performSegue(withIdentifier: "unwindToMainViewController1", sender: self)
                        })
                        
                        YBClient.sharedInstance().status = .looking
                        YBClient.sharedInstance().bid = nil
                    }
                    else {
                        DDLogVerbose("Review failed: \(String(describing: error))")
                        errorBlock(success, error)
                    }
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Cosmos Rating View
    

    // MARK: - Helpers
    
    
    func updateFinalFareWithTip() {
        
        if let ride = YBClient.sharedInstance().ride {
            let rideFareInt = Int(ride.bidPrice!)
            _ = Int(finalTipAmount)
            rideFareLabel.text = "$\(rideFareInt)"
        }
    }
}
