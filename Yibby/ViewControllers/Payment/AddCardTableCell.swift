//
//  AddCardTableCell.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/18/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit

class AddCardTableCell : UITableViewCell {
    
    @IBOutlet weak var yibbyCodeTF: UITextField!
    
    @IBOutlet weak var VW: UIView!
    
    // MARK: - Properties
    
    override func awakeFromNib() {
        
        setupUI()
        
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setupUI() {
        
        /*VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7.0*/
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y:  yibbyCodeTF.frame.height - 1, width: yibbyCodeTF.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.borderColor().cgColor
        yibbyCodeTF.borderStyle = UITextBorderStyle.none
        yibbyCodeTF.layer.addSublayer(bottomLine)
    }
    
    // MARK: - Setup functions
    
    //    func configure(ride: Ride) {
    //
    //    }
}
