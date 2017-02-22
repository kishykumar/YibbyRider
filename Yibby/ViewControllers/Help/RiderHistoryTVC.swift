//
//  RiderHistoryTVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class RiderHistoryTVC: UITableViewCell {

    @IBOutlet weak var riderHistoryDate: UILabel!
    @IBOutlet weak var riderHistoryPrice: UILabel!
    @IBOutlet weak var riderHistoryName: UILabel!

    @IBOutlet var riderHistoryImage: UIImageView!
    @IBOutlet var riderHistoryMapImage: UIImageView!

    @IBOutlet var riderHistoryVW: UIView!

    override func awakeFromNib() {
        
        riderHistoryImage.layer.borderColor = UIColor.greyA().cgColor
        riderHistoryImage.layer.borderWidth = 1.0
        riderHistoryImage.layer.cornerRadius = 22.0
        
        riderHistoryVW.layer.borderColor = UIColor.borderColor().cgColor
        riderHistoryVW.layer.borderWidth = 1.0
        riderHistoryVW.layer.cornerRadius = 7
        
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
