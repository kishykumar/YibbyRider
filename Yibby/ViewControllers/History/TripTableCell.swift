//
//  TripTableCell.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 25/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import FoldingCell
import GoogleMaps
import Font_Awesome_Swift
import Braintree
import Presentr

class TripTableCell: FoldingCell {
    
    // MARK: - Properties 
    
    @IBOutlet weak var dateAndTimeLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var userIV: UIImageView!
    
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
    
    var myTrip: Ride!
    var myViewController: TripTableVC!

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
        
        // loginSubView.selectedIndex = sender.tag
        carDetailsViewController.carModelStr = myTrip.vehicle?.make
        carDetailsViewController.carNumberStr = myTrip.vehicle?.licensePlate
        carDetailsViewController.view.backgroundColor = .clear
        
        presentTopHalfController(vc: carDetailsViewController)
    }
    
    @IBAction func onLostStolenButtonClick(_ sender: UIButton) {
        
        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
        let emergencyContactsNVC = historyStoryboard.instantiateViewController(withIdentifier: "LostOrStolenItemVC") as! LostOrStolenItemVC
        _ = myViewController.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
    }
    
    @IBAction func onFareOrRideIssueButtonClick(_ sender: UIButton) {
        print("fareOrRideIssueBtn tap")
    }
    
    @IBAction func onOtherIssueButtonClick(_ sender: UIButton) {
        print("otherIssueBtn tap")
    }
    
    // MARK: - Setup
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.borderWidth = 1.0
        foregroundView.layer.masksToBounds = true
        
        foregroundView.layer.borderColor = UIColor.borderColor()
            .cgColor
        
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1.0
        containerView.layer.masksToBounds = true
        
        containerView.layer.borderColor = UIColor.borderColor()
            .cgColor
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    // MARK: - Helpers
    
    fileprivate func presentTopHalfController(vc: UIViewController) {
        let presenter = myViewController.presenter
        
        presenter.presentationType = .topHalf
        presenter.transitionType = nil
        presenter.dismissTransitionType = nil
        presenter.dismissAnimated = true
        presenter.dismissOnSwipe = true
        presenter.dismissOnSwipeDirection = .top
        myViewController.customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
    }
}

