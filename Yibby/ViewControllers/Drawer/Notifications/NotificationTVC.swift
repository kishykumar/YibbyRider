//
//  NotificationTVC.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class NotificationTVC: UITableViewCell {

    @IBOutlet weak var cardNoTF: UITextField!

    @IBOutlet weak var changeBtn: UIButton!

    @IBOutlet weak var VW: UIView!

    
    var customTextfieldProperty = CustomizeTextfield()

    override func awakeFromNib() {
        
        setupUI()
        
        super.awakeFromNib()
        // Initialization code
    }

    private func setupUI() {

        customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.cardNoTF)
        
        changeBtn.layer.borderColor = UIColor.borderColor().cgColor
        changeBtn.layer.borderWidth = 1.0
        changeBtn.layer.cornerRadius = 5
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
