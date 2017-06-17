//
//  ProfileVC.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 17/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import ObjectMapper

class ProfileVC: UIViewController {
    
    @IBOutlet weak var emailAddress: YibbyTextField!
    @IBOutlet weak var phoneNo: YibbyTextField!
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    @IBOutlet var VW2: UIView!
    
    @IBOutlet var firstNameLbl: UILabel!
    @IBOutlet var lastNameLbl: UILabel!
    
    @IBOutlet var addHomeBtnOutlet: UIButton!
    @IBOutlet var addWorkBtnOutlet: UIButton!
    
    
    var customTextfieldProperty = CustomizeTextfield()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupUI()
        
        getProfile()
    }
    
    private func setupUI() {
        setupBackButton()
        
        /*customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.emailAddress)
        
        customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.phoneNo)*/
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        VW2.layer.borderColor = UIColor.borderColor().cgColor
        VW2.layer.borderWidth = 1.0
        VW2.layer.cornerRadius = 7
        
        firstNameLbl.layer.borderColor = UIColor.lightGray.cgColor
        firstNameLbl.layer.borderWidth = 1.0
        firstNameLbl.layer.cornerRadius = 5
        
        lastNameLbl.layer.borderColor = UIColor.lightGray.cgColor
        lastNameLbl.layer.borderWidth = 1.0
        lastNameLbl.layer.cornerRadius = 5
    }
    
    func getProfile() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.getProfile(BAASBOX_RIDER_STRING, completion:{(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            DDLogVerbose("getProfile data: \(success)")

            if let success = success {
                let profileModel = Mapper<YBProfile>().map(JSONObject: success)
                
                if let profile = profileModel {

                    self.emailAddress.text = profile.email
                    self.phoneNo.text = profile.phoneNumber
                    
                    let nameArr = profile.name?.components(separatedBy: " ")
                    
                    if let myStringArr = nameArr {
                        self.firstNameLbl.text = String(format: " %@ ", myStringArr[0])
                        self.lastNameLbl.text = myStringArr.count > 1 ? String(format: " %@  ", myStringArr[1]) : nil
                    }
                    
                    self.addHomeBtnOutlet.setTitle(profile.homeLocation?.name, for: UIControlState())
                    self.addWorkBtnOutlet.setTitle(profile.workLocation?.name, for: UIControlState())
                }
                else {
                    DDLogError("Error in fetching getProfile: \(error)")
                }
                
            } else {
                // TODO: Show the alert with error
                DDLogVerbose("getProfile failed: \(error)")
            }
        })
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
        
        let emergencyContactsNVC = self.storyboard?.instantiateViewController(withIdentifier: "EmergencyContactsVC") as! EmergencyContactsVC
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
