//
//  NotificationTVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class NotificationTVC: UITableViewCell {

    @IBOutlet weak var cardNoTF: UITextField!

    @IBOutlet weak var changeBtn: UIButton!

    
    var customTextfieldProperty = CustomizeTextfield()

    override func awakeFromNib() {
        
        customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.cardNoTF)

        changeBtn.layer.borderColor = UIColor.borderColor().cgColor
        changeBtn.layer.borderWidth = 1.0
        changeBtn.layer.cornerRadius = 5
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
