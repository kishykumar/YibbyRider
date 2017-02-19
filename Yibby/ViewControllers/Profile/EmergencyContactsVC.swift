//
//  EmergencyContactsVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 17/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class EmergencyContactsVC: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    
    @IBOutlet weak var emailAddress1: UITextField!
    @IBOutlet weak var phoneNo1: UITextField!
    
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    
    @IBOutlet var firstNameLbl: UILabel!
    @IBOutlet var lastNameLbl: UILabel!
    @IBOutlet var firstNameLbl1: UILabel!
    @IBOutlet var lastNameLbl1: UILabel!

    var customTextfieldProperty = CustomizeTextfield()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa")!, senderTextfield: self.emailAddress)
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa")!, senderTextfield: self.phoneNo)
        
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa")!, senderTextfield: self.emailAddress1)
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa")!, senderTextfield: self.phoneNo1)
        
        
        VW.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7

        firstNameLbl.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        firstNameLbl.layer.borderWidth = 1.0
        firstNameLbl.layer.cornerRadius = 5
        lastNameLbl.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        lastNameLbl.layer.borderWidth = 1.0
        lastNameLbl.layer.cornerRadius = 5
        firstNameLbl1.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        firstNameLbl1.layer.borderWidth = 1.0
        firstNameLbl1.layer.cornerRadius = 5
        lastNameLbl1.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        lastNameLbl1.layer.borderWidth = 1.0
        lastNameLbl1.layer.cornerRadius = 5

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
