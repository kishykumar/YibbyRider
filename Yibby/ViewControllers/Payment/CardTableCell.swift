//
//  CardCell.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/14/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import Braintree

class CardTableCell : UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var cardTextLabelOutlet: UILabel!
    @IBOutlet weak var selectedCardButton: UIButton!
    @IBOutlet weak var editPaymentButtonOutlet: UIButton!
    @IBOutlet weak var cardBrandViewOutlet: BTUICardHint!
    
    var myPaymentMethod: YBPaymentMethod!
    var myViewController: UIViewController!
    
    // MARK: - Actions
    
    @IBAction func onEditButtonClick(_ sender: UIButton) {
     
        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
        let editCardViewController = paymentStoryboard.instantiateViewController(withIdentifier: "AddPaymentViewControllerIdentifier") as! AddPaymentViewController

        editCardViewController.editDelegate = myViewController as! EditPaymentViewControllerDelegate?
        editCardViewController.isEditCard = true
        editCardViewController.paymentMethodToEdit = myPaymentMethod
        myViewController.navigationController!.pushViewController(editCardViewController, animated: true)
    }

    // MARK: - Setup

    override func awakeFromNib() {
        setupUI()

        super.awakeFromNib()
        // Initialization code
    }

    private func setupUI() {
        
//        VW.layer.borderColor = UIColor.borderColor().cgColor
//        VW.layer.borderWidth = 1.0
//        VW.layer.cornerRadius = 7.0
 
        selectedCardButton.layer.borderColor = UIColor.borderColor().cgColor
        selectedCardButton.layer.borderWidth = 1.0
        selectedCardButton.layer.cornerRadius = selectedCardButton.frame.size.width/2
        
        editPaymentButtonOutlet.layer.borderColor = UIColor.borderColor().cgColor
        editPaymentButtonOutlet.layer.borderWidth = 1.0
        editPaymentButtonOutlet.layer.cornerRadius = 8.0

        selectedCardButton.clipsToBounds = true
    }
}
