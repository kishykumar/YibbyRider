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
    
    var customTextfieldProperty = CustomizeTextfield()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa"), senderTextfield: self.emailAddress)
        
      customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa"), senderTextfield: self.phoneNo)
        
        
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
