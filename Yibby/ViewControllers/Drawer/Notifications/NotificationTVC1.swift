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

    var customTextfieldProperty = CustomizeTextfield()

    override func awakeFromNib() {
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "winner_prize")!, senderTextfield: self.TF)
        
        customTextfieldProperty.setRightViewImage(UIImage(named: "winner_prize")!, senderTextfield: self.TF)

        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
