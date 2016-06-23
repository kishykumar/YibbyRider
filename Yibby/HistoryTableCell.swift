//
//  HistoryTableCell.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/16/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps

class HistoryTableCell : UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var tripGMSMapViewOutlet: GMSMapView!
    @IBOutlet weak var driveImageViewOutlet: UIImageView!
    @IBOutlet weak var dateTimeLabelOutlet: UILabel!
    @IBOutlet weak var driverNameLabelOutlet: UILabel!
    @IBOutlet weak var ridePriceLabelOutlet: UILabel!
    
    // MARK: Setup functions
    func configure(ride: Ride) {
        self.dateTimeLabelOutlet?.text = "02/09/16 at 2:09 PM"
        self.driverNameLabelOutlet?.text = "Jayson Gru"
        self.ridePriceLabelOutlet?.text = "$10"
        
        self.driveImageViewOutlet?.image = UIImage(named: "logoMain")
    }
}
