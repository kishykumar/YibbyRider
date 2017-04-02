//
//  TripTableCell.swift
//  Yibby
//
//  Created by Rubi Kumari on 25/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import FoldingCell

class TripTableCell: FoldingCell {
    
    @IBOutlet weak var dateAndTimeLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    
    @IBOutlet weak var dateAndTimeLbl1: UILabel!
    @IBOutlet weak var distanceInMilesLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var ridePriceLbl: UILabel!
    @IBOutlet weak var tipPriceLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    
    
    @IBOutlet weak var userIV: UIImageView!
    @IBOutlet weak var userIV1: UIImageView!
    @IBOutlet weak var carIV: UIImageView!
    
    @IBOutlet weak var fromPlaceTF: UITextField!
    @IBOutlet weak var toPlaceTF: UITextField!
    
    
    @IBOutlet weak var lostOrStolenItemBtn: UIButton!
    @IBOutlet weak var fareOrRideIssueBtn: UIButton!
    @IBOutlet weak var otherIssueBtn: UIButton!
    
    @IBOutlet weak var cardDetailsBtnOutlet: UIButton!
    
    var customTextfieldProperty = CustomizeTextfield()

    var number: Int = 0 {
        didSet {
            
            userIV.layer.borderColor = UIColor.grey5().cgColor
            userIV.layer.borderWidth = 1.0
            userIV.layer.cornerRadius = userIV.frame.size.width/2
            
            userIV1.layer.borderColor = UIColor.borderColor().cgColor
            userIV1.layer.borderWidth = 1.0
            userIV1.layer.cornerRadius = 20
            
            carIV.layer.borderColor = UIColor.borderColor().cgColor
            carIV.layer.borderWidth = 1.0
            carIV.layer.cornerRadius = carIV.frame.size.height/2-7
            
            customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "defaultMarker")!, senderTextfield: fromPlaceTF)
            
            customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "defaultMarker")!, senderTextfield: toPlaceTF)
            
            fromPlaceTF.layer.borderColor = UIColor.borderColor().cgColor
            fromPlaceTF.layer.borderWidth = 1.0
            fromPlaceTF.layer.cornerRadius = 7
            
            toPlaceTF.layer.borderColor = UIColor.borderColor().cgColor
            toPlaceTF.layer.borderWidth = 1.0
            toPlaceTF.layer.cornerRadius = 7
            
            
            //      closeNumberLabel.text = String(number)
            //      openNumberLabel.text = String(number)
        }
    }
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.borderWidth = 1.0
        foregroundView.layer.masksToBounds = true
        
        foregroundView.layer.borderColor = UIColor.borderColor()
            .cgColor
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}

// MARK: Actions
extension TripTableCell {
    
    /*@IBAction func lostOrStolenItemBtnAction(_ sender: AnyObject) {
        print(sender.tag)
        print("lostOrStolenItemBtn tap")
        
        let emergencyContactsNVC = self.storyboard?.instantiateViewController(withIdentifier: "LostOrStolenItemVC") as! LostOrStolenItemVC
        _ = self.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
    }
    
    @IBAction func fareOrRideIssueBtnAction(_ sender: AnyObject) {
        print(sender.tag)
        print("fareOrRideIssueBtn tap")
    }
    
    @IBAction func otherIssueBtnAction(_ sender: AnyObject) {
        print(sender.tag)
        print("otherIssueBtn tap")
    }*/
}

