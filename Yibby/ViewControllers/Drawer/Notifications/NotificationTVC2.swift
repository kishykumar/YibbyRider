//
//  NotificationTVC2.swift
//  Yibby
//
//  Created by Rubi Kumari on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class NotificationTVC2: UITableViewCell {

    @IBOutlet weak var learnMoreBtn: UIButton!

    override func awakeFromNib() {
        
        learnMoreBtn.layer.borderColor = UIColor.borderColor().cgColor
        learnMoreBtn.layer.borderWidth = 1.0
        learnMoreBtn.layer.cornerRadius = 5
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
