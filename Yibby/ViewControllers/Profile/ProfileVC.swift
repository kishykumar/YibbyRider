//
//  ProfileVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 17/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    @IBOutlet var VW2: UIView!

    @IBOutlet var firstNameLbl: UILabel!
    @IBOutlet var lastNameLbl: UILabel!
    
    var customTextfieldProperty = CustomizeTextfield()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa")!, senderTextfield: self.emailAddress)
        
      customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa")!, senderTextfield: self.phoneNo)
        
        VW.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        VW2.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW2.layer.borderWidth = 1.0
        VW2.layer.cornerRadius = 7
        firstNameLbl.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        firstNameLbl.layer.borderWidth = 1.0
        firstNameLbl.layer.cornerRadius = 5
        lastNameLbl.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        lastNameLbl.layer.borderWidth = 1.0
        lastNameLbl.layer.cornerRadius = 5
    }
    
    override func viewDidLayoutSubviews() {
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func emergencyContactsBtnAction(sender: AnyObject) {
        
        let emergencyContactsNVC = self.storyboard?.instantiateViewControllerWithIdentifier("EmergencyContactsVC") as! EmergencyContactsVC
        _ = self.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
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
