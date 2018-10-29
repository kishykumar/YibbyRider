//
//  TripTableCell.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 25/02/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import UIKit
import FoldingCell
import GoogleMaps
import Font_Awesome_Swift
import Braintree
import Presentr
import BaasBoxSDK

class TripTableCell: FoldingCell {
    
    // MARK: - Properties 
    
    @IBOutlet weak var dateAndTimeLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var userIV: UIImageView!
    @IBOutlet weak var cancelledLabelOutlet: UILabel!
    
    @IBOutlet weak var dateAndTimeLbl1: UILabel!
    @IBOutlet weak var distanceInMilesLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var ridePriceLbl: UILabel!
    @IBOutlet weak var tipPriceLbl: UILabel!
    @IBOutlet weak var totalFareLabelOutlet: UILabel!
    @IBOutlet weak var cardHintOutlet: BTUICardHint!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var userIV1: UIImageView!
    @IBOutlet weak var carIV: UIImageView!
    @IBOutlet weak var fromPlaceTF: UITextField!
    @IBOutlet weak var toPlaceTF: UITextField!
    @IBOutlet weak var lostOrStolenItemBtn: UIButton!
    @IBOutlet weak var fareOrRideIssueBtn: UIButton!
    @IBOutlet weak var otherIssueBtn: UIButton!
    @IBOutlet weak var cardDetailsBtnOutlet: UIButton!
    @IBOutlet weak var gmsMapViewOpenOutlet: GMSMapView!
    
    weak var myTrip: Ride?
    weak var myViewController: TripTableVC?

    var number: Int = 0 {
        didSet {
            
            userIV.layer.borderColor = UIColor.grey5().cgColor
            userIV.layer.borderWidth = 1.0
            userIV.layer.cornerRadius = userIV.frame.size.width/2
            
            userIV1.layer.borderColor = UIColor.borderColor().cgColor
            userIV1.layer.borderWidth = 1.0
            userIV1.layer.cornerRadius = 20
            userIV1.layer.shadowOpacity = 0.5
            userIV1.layer.shadowRadius = 2
            userIV1.layer.shadowColor = UIColor.gray.cgColor
//            userIV1.layer.shadowOffset = CGSize(width: -2, height: 0)
            
            carIV.layer.borderColor = UIColor.borderColor().cgColor
            carIV.layer.borderWidth = 1.0
            carIV.layer.cornerRadius = carIV.frame.size.height/2-7
            
            //customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "defaultMarker")!, senderTextfield: fromPlaceTF)
            
            //customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "defaultMarker")!, senderTextfield: toPlaceTF)

            fromPlaceTF.layer.borderColor = UIColor.borderColor().cgColor
            fromPlaceTF.layer.borderWidth = 1.0
            fromPlaceTF.layer.cornerRadius = 7
            
            fromPlaceTF.setLeftViewFAIcon(icon: .FAMapMarker, leftViewMode: .always, textColor: .greenD1(), backgroundColor: .clear, size: nil)

            toPlaceTF.layer.borderColor = UIColor.borderColor().cgColor
            toPlaceTF.layer.borderWidth = 1.0
            toPlaceTF.layer.cornerRadius = 7

            toPlaceTF.setLeftViewFAIcon(icon: .FAMapMarker, leftViewMode: .always, textColor: .red, backgroundColor: .clear, size: nil)
            
            gmsMapViewOutlet.isUserInteractionEnabled = false
            gmsMapViewOutlet.layer.borderWidth = 1
            gmsMapViewOutlet.layer.borderColor = UIColor.greyC().cgColor
            
            gmsMapViewOpenOutlet.isUserInteractionEnabled = false
            gmsMapViewOpenOutlet.layer.borderWidth = 1
            gmsMapViewOpenOutlet.layer.borderColor = UIColor.greyC().cgColor
            
            lostOrStolenItemBtn.layer.shadowOpacity = 0.5
            lostOrStolenItemBtn.layer.shadowRadius = 2
            lostOrStolenItemBtn.layer.shadowColor = UIColor.gray.cgColor
            lostOrStolenItemBtn.layer.shadowOffset = CGSize(width: -2, height: 0)
            
            fareOrRideIssueBtn.layer.shadowOpacity = 0.5
            fareOrRideIssueBtn.layer.shadowRadius = 2
            fareOrRideIssueBtn.layer.shadowColor = UIColor.gray.cgColor
            fareOrRideIssueBtn.layer.shadowOffset = CGSize(width: -2, height: -1)
            
            otherIssueBtn.layer.shadowOpacity = 0.5
            otherIssueBtn.layer.shadowRadius = 2
            otherIssueBtn.layer.shadowColor = UIColor.gray.cgColor
            otherIssueBtn.layer.shadowOffset = CGSize(width: -2, height: -1)            
        }
    }
    
    // MARK: - Actions
    @IBAction func onCarDetailsButtonClick(_ sender: UIButton) {
        
        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
        let carDetailsViewController = historyStoryboard.instantiateViewController(withIdentifier: "CarDetailsChildView") as! CarDetailsChildView
        
        if let ride = self.myTrip {
            carDetailsViewController.carModelStr = "\(ride.vehicle!.make!) \(ride.vehicle!.model!)"
            carDetailsViewController.carNumberStr = ride.vehicle?.licensePlate
            carDetailsViewController.view.backgroundColor = .clear
        }
        
        presentTopHalfController(vc: carDetailsViewController)
    }
    
    @IBAction func onLostStolenButtonClick(_ sender: UIButton) {
        
        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
        let fareIssueViewController = historyStoryboard.instantiateViewController(withIdentifier: "FareIssueViewController") as! FareIssueViewController
        
        if let vc = self.myViewController {
            _ = vc.navigationController?.pushViewController(fareIssueViewController, animated: true)
        }
        
//        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
//        let lostViewController = historyStoryboard.instantiateViewController(withIdentifier: "LostItemViewControllerIdentifier") as! LostItemViewController
//        lostViewController.myTrip = self.myTrip
//
//        if let vc = self.myViewController {
//            _ = vc.navigationController?.pushViewController(lostViewController, animated: true)
//        }
    }
    
    @IBAction func onFareOrRideIssueButtonClick(_ sender: UIButton) {
        
        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
        let fareIssueViewController = historyStoryboard.instantiateViewController(withIdentifier: "FareIssueViewController") as! FareIssueViewController
        
        if let vc = self.myViewController {
            _ = vc.navigationController?.pushViewController(fareIssueViewController, animated: true)
        }
    }
    
    @IBAction func onOtherIssueButtonClick(_ sender: UIButton) {
        
        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
        let fareIssueViewController = historyStoryboard.instantiateViewController(withIdentifier: "FareIssueViewController") as! FareIssueViewController
        
        if let vc = self.myViewController {
            _ = vc.navigationController?.pushViewController(fareIssueViewController, animated: true)
        }
    }
    
    // MARK: - Setup
    
    public func configure(_ ride: Ride) {
        
        /********* IMPORTANT NOTE **********/
        // Any new field added to this function should be reset in resetAllContent as tableview cells are reused
        
        self.userNameLbl.text = ride.driver?.firstName?.capitalized
        
        if let rideISODateTime = ride.datetime, let rideDate = TimeUtil.getDateFromISOTime(rideISODateTime) {
            let prettyDate = TimeUtil.prettyPrintDate1(rideDate)
            self.dateAndTimeLbl1.text = prettyDate
            self.dateAndTimeLbl.text = prettyDate
        }
        
        self.fromPlaceTF.text = ride.pickupLocation?.name
        self.toPlaceTF.text = ride.dropoffLocation?.name
        
        if let tip = ride.tip, let ridePrice = ride.bidPrice {
            self.totalPriceLbl.text = "$\(ridePrice + tip)"
            self.tipPriceLbl.text = "$\(tip)"
            self.totalFareLabelOutlet.text = "$\(ridePrice + tip)"
            self.ridePriceLbl.text = "$\(ridePrice)"
        }
        
        self.gmsMapViewOutlet.clear()
        self.gmsMapViewOpenOutlet.clear()
        
        if let dropoffCoordinate = ride.dropoffLocation?.coordinate(),
            let pickupCoordinate = ride.pickupLocation?.coordinate() {
            
            // Markers for gmsMapViewOutlet
            
            let domarker = GMSMarker(position: dropoffCoordinate)
            domarker.icon = UIImage(named: "famarker_red")
            domarker.map = self.gmsMapViewOutlet
            
            let pumarker = GMSMarker(position: pickupCoordinate)
            pumarker.icon = UIImage(named: "famarker_green")
            pumarker.map = self.gmsMapViewOutlet
            
            adjustGMSCameraFocus(mapView: self.gmsMapViewOutlet, pickupMarker: pumarker, dropoffMarker: domarker)
            
            // Markers for gmsMapViewOpenOutlet
            
            let domarkerOpen = GMSMarker(position: dropoffCoordinate)
            domarkerOpen.icon = UIImage(named: "famarker_red")
            domarkerOpen.map = self.gmsMapViewOpenOutlet
            
            let pumarkerOpen = GMSMarker(position: pickupCoordinate)
            pumarkerOpen.icon = UIImage(named: "famarker_green")
            pumarkerOpen.map = self.gmsMapViewOpenOutlet
            
            adjustGMSCameraFocus(mapView: self.gmsMapViewOpenOutlet, pickupMarker: pumarkerOpen, dropoffMarker: domarkerOpen)
        }
        
        if let profilePictureFileId = ride.driver?.profilePictureFileId {
            setPicture(imageView: self.userIV, ride: ride, fileId: profilePictureFileId)
            setPicture(imageView: self.userIV1, ride: ride, fileId: profilePictureFileId)
        }
        
        if let vehiclePictureFileId = ride.vehicle?.vehiclePictureFileId {
            setPicture(imageView: self.carIV, ride: ride, fileId: vehiclePictureFileId)
        }
        
        if let metresTravelled = ride.tripDistance {
            var milesTravelled: Int = (Int(metresTravelled) + 1608) / 1609
            
            if (milesTravelled == 0) {
                milesTravelled = 1
            }
            
            self.distanceInMilesLbl.text = "\(String(describing: milesTravelled)) miles"
        }
        
        if let rideTime = ride.rideTime {
            let rideMins: Int = (rideTime + 59) / 60
            self.timeLbl.text = "\(String(describing: rideMins)) mins"
        }
        
        if let paymentMethodBrand = ride.paymentMethodBrand, let paymentMethodLast4 = ride.paymentMethodLast4 {
            self.cardNumberLbl.text = "*\(paymentMethodLast4)"
            
            let paymentMethodType: BTUIPaymentOptionType =
                BraintreeCardUtil.paymentMethodTypeFromBrand(paymentMethodBrand)
            self.cardHintOutlet.setCardType(paymentMethodType, animated: false)
        } else {
            let paymentMethodType: BTUIPaymentOptionType =
                BraintreeCardUtil.paymentMethodTypeFromBrand("Visa")
            self.cardHintOutlet.setCardType(paymentMethodType, animated: false)
            self.cardNumberLbl.text = "*9999"
        }
        
        if (ride.cancelled != RideCancelled.notCancelled.rawValue) {
            self.cancelledLabelOutlet.isHidden = false
        }
    }
    
    public func resetAllContent() {
        self.userNameLbl.text = ""
        self.dateAndTimeLbl1.text = ""
        self.dateAndTimeLbl.text = ""
        
        self.fromPlaceTF.text = ""
        self.toPlaceTF.text = ""
        
        self.totalPriceLbl.text = "$0.00"
        self.tipPriceLbl.text = "$0.00"
        self.totalFareLabelOutlet.text = "$0.00"
        self.ridePriceLbl.text = "$0.00"

        self.gmsMapViewOutlet.clear()
        self.gmsMapViewOpenOutlet.clear()
        
        self.carIV.image = UIImage(named: "driver_car")
        self.userIV.image = UIImage(named: "account")
        self.userIV1.image = UIImage(named: "account")
        
        self.distanceInMilesLbl.text = "0 miles"
        self.timeLbl.text = "0 mins"
        
        let paymentMethodType: BTUIPaymentOptionType =
            BraintreeCardUtil.paymentMethodTypeFromBrand("Visa")
        self.cardHintOutlet.setCardType(paymentMethodType, animated: false)
        self.cardNumberLbl.text = "*9999"

        self.cancelledLabelOutlet.isHidden = true
    }
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.borderWidth = 1.0
        foregroundView.layer.masksToBounds = true
        
        foregroundView.layer.borderColor = UIColor.borderColor()
            .cgColor
        
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1.0
        containerView.layer.masksToBounds = true
        
        containerView.layer.borderColor = UIColor.borderColor().cgColor
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    // MARK: - Helpers
    
    fileprivate func adjustGMSCameraFocus(mapView: GMSMapView, pickupMarker: GMSMarker, dropoffMarker: GMSMarker) {
        
        let bounds = GMSCoordinateBounds(coordinate: (pickupMarker.position),
                                         coordinate: (dropoffMarker.position))
        
        //        if let markerHeight = pickupMarker.icon?.size.height, let markerWidth = pickupMarker.icon?.size.width {
        let insets = UIEdgeInsets(top: 50.0,
                                  left: 10.0,
                                  bottom: 20.0,
                                  right: 10.0)
        
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        mapView.moveCamera(update)
        //        }
    }
    
    fileprivate func setPicture(imageView: UIImageView, ride: Ride, fileId: String) {
        
        if (fileId == "") {
            return;
        }
        
        if let newUrl = BAAFile.getCompleteURL(withToken: fileId) {
            imageView.pin_setImage(from: newUrl)
        }
    }
    
    fileprivate func presentTopHalfController(vc: UIViewController) {
        if let customVc = self.myViewController {
            let presenter = customVc.presenter
            presenter.presentationType = .topHalf
            presenter.transitionType = nil
            presenter.dismissTransitionType = nil
            presenter.dismissAnimated = true
            presenter.dismissOnSwipe = true
            presenter.dismissOnSwipeDirection = .top
            customVc.customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
        }
    }
}

