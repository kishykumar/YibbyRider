//
//  NotificationTVC1.swift
//  Yibby
//
//  Created by Rubi Kumari on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class NotificationTVC1: UITableViewCell {

    @IBOutlet weak var TF: UITextField!

    @IBOutlet weak var VW: UIView!

    var customTextfieldProperty = CustomizeTextfield()

    override func awakeFromNib() {
        
        setupUI()
        
        super.awakeFromNib()
        // Initialization code
    }
    private func setupUI() {
        customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "winner_prize")!, senderTextfield: self.TF)
        
        customTextfieldProperty.setRightViewImage(rightImageIcon: UIImage(named: "winner_prize")!, senderTextfield: self.TF)
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
