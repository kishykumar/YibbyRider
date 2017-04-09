//
//  EmergencyContactTVC.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 02/04/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class EmergencyContactTVC: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var emailAddressTFOutlet: UITextField!
    
    @IBOutlet var phoneNoTFOutlet: UITextField!
    
    @IBOutlet var VW1: UIView!
    
    @IBOutlet var firstNameLblOutlet: YibbyPaddingLabel!
    @IBOutlet weak var lastNameLblOutlet: YibbyPaddingLabel!
    
    @IBOutlet var contactImageBtnOutlet: UIButton!
    
    @IBOutlet weak var emailEditBtnOutlet: UIButton!
    @IBOutlet weak var phoneNumberBtnOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupUI()
    }
    
    private func setupUI() {
        /*contactImageBtnOutlet.layer.cornerRadius = contactImageBtnOutlet.frame.size.width/2
        contactImageBtnOutlet.layer.masksToBounds = true*/
        
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 8
        
        self.emailAddressTFOutlet.layer.borderColor = UIColor.clear.cgColor
        
        self.emailAddressTFOutlet.textColor = UIColor.lightGray
        
        self.emailEditBtnOutlet.setRoundedWithWhiteBorder()
        self.phoneNumberBtnOutlet.setRoundedWithWhiteBorder()
    }
    
    @IBAction func emailEditBtnAction(_ sender: UIButton) {
        
        if (self.emailEditBtnOutlet.currentImage?.isEqual(UIImage(named: "Settings")))! {
            //do something here
            self.emailEditBtnOutlet.setImage(UIImage(named: "tick"), for: .normal)
            
            //
          //rahul  self.emailEditBtnOutlet.clearBorderWithColor()

            self.emailAddressTFOutlet.layer.borderColor = UIColor.borderColor().cgColor
            self.emailAddressTFOutlet.layer.borderWidth = 1.0
            self.emailAddressTFOutlet.layer.cornerRadius = 7
            
            let col2 = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
            
            self.emailAddressTFOutlet.textColor = col2
            
            self.emailAddressTFOutlet.isUserInteractionEnabled = true
            
            self.emailAddressTFOutlet.becomeFirstResponder()
            
        }
        else
        {
            self.emailEditBtnOutlet.setRoundedWithWhiteBorder()

            self.emailEditBtnOutlet.setImage(UIImage(named: "Settings"), for: .normal)
            
            self.emailAddressTFOutlet.isUserInteractionEnabled = false
            
            self.emailAddressTFOutlet.resignFirstResponder()
            
            self.emailAddressTFOutlet.layer.borderColor = UIColor.clear.cgColor
            
            self.emailAddressTFOutlet.textColor = UIColor.lightGray
            
            /*if (emailAddressTFOutlet.text?.isEqual(profileObjectModel.email))!
             {
             
             }
             else
             {
             }*/
        }
    }
    
    @IBAction func phoneNumberEditBtnAction(_ sender: UIButton) {
        
        if (self.phoneNumberBtnOutlet.currentImage?.isEqual(UIImage(named: "Settings")))! {
            //do something here
            self.phoneNumberBtnOutlet.setImage(UIImage(named: "tick"), for: .normal)
            
          //rahul  self.phoneNumberBtnOutlet.clearBorderWithColor()
            //
            
            self.phoneNoTFOutlet.layer.borderColor = UIColor.borderColor().cgColor
            self.phoneNoTFOutlet.layer.borderWidth = 1.0
            self.phoneNoTFOutlet.layer.cornerRadius = 7
            
            let col2 = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
            
            self.phoneNoTFOutlet.textColor = col2
            
            self.phoneNoTFOutlet.isUserInteractionEnabled = true
            
            self.phoneNoTFOutlet.becomeFirstResponder()
            
        }
        else
        {
            self.phoneNumberBtnOutlet.setRoundedWithWhiteBorder()
            
            self.phoneNumberBtnOutlet.setImage(UIImage(named: "Settings"), for: .normal)
            
            self.phoneNoTFOutlet.isUserInteractionEnabled = false
            
            self.phoneNoTFOutlet.resignFirstResponder()
            
            self.phoneNoTFOutlet.layer.borderColor = UIColor.clear.cgColor
            
            self.phoneNoTFOutlet.textColor = UIColor.lightGray
            
            /*if (emailAddressTFOutlet.text?.isEqual(profileObjectModel.email))!
             {
             
             }
             else
             {
             }*/
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
