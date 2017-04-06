//
//  CardCell.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/14/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

class CardTableCell : UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var cardBrandImageViewOutlet: UIImageView!

    @IBOutlet weak var cardTextLabelOutlet: UILabel!
    
   // @IBOutlet weak var selectedColorLbl: UILabel!
    @IBOutlet weak var selectedCardColourButton: UIButton!
    
    @IBOutlet weak var VW: UIView!
    
    @IBOutlet weak var paymentDefaultsBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        
        setupUI()
        
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setupUI() {
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7.0
        
        selectedCardColourButton.layer.borderColor = UIColor.borderColor().cgColor
        selectedCardColourButton.layer.borderWidth = 1.0
        selectedCardColourButton.layer.cornerRadius = selectedCardColourButton.frame.size.width/2
        
        selectedCardColourButton.clipsToBounds = true
        
        self.paymentDefaultsBtnOutlet.setRoundedWithWhiteBorder()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Setup functions
    
//    func configure(ride: Ride) {
//        
//    }
}
