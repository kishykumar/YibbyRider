//
//  NotificationTVC2.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class NotificationTVC2: UITableViewCell {

    @IBOutlet weak var learnMoreBtn: UIButton!

    @IBOutlet weak var VW: UIView!

    override func awakeFromNib() {
        
        setupUI()
        
        super.awakeFromNib()
        // Initialization code
    }

    private func setupUI() {
        learnMoreBtn.layer.borderColor = UIColor.borderColor().cgColor
        learnMoreBtn.layer.borderWidth = 1.0
        learnMoreBtn.layer.cornerRadius = 5
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
