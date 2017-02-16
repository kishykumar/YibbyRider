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
    
    var customTextfieldProperty = CustomizeTextfield()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa"), senderTextfield: self.emailAddress)
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa"), senderTextfield: self.phoneNo)
        
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa"), senderTextfield: self.emailAddress1)
        
        customTextfieldProperty.setLeftViewImage(UIImage(named: "Visa"), senderTextfield: self.phoneNo1)
        
        
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
