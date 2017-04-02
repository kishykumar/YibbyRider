//
//  EmergencyContactsVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 17/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class EmergencyContactsVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var addNewContactButtonOutlet: UIButton!
    
    var sectionsCount = 0

        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    sectionsCount = 1
        setupUI()
    }

    private func setupUI() {
        self.customBackButton(y: 20 as AnyObject)
        
        
        self.addNewContactButtonOutlet.layer.borderColor = UIColor.borderColor().cgColor
        self.addNewContactButtonOutlet.layer.borderWidth = 1.0
        self.addNewContactButtonOutlet.layer.cornerRadius = 8
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addContactButtonAction(_ sender: UIButton) {
        sectionsCount = sectionsCount+1
        self.TV.reloadData()
        
    }
    @IBAction func deleteContactAction(_ sender: UIButton) {
        sectionsCount = sectionsCount-1
        self.TV.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let notificationCell = tableView.dequeueReusableCell(withIdentifier: "EmergencyContactTVC", for: indexPath as IndexPath) as UITableViewCell
        
        
        notificationCell.layer.cornerRadius = 8
            return notificationCell
    }
    
    
    
    
    /*@IBAction func emailEditBtnAction(_ sender: UIButton) {
        
        if (self.emailEditBtnOutlet.currentImage?.isEqual(UIImage(named: "Settings")))! {
            //do something here
            self.emailEditBtnOutlet.setImage(UIImage(named: "tick"), for: .normal)
            
            //
            
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
            self.emailEditBtnOutlet.setImage(UIImage(named: "Settings"), for: .normal)
            
            self.emailAddressTFOutlet.isUserInteractionEnabled = false
            
            self.emailAddressTFOutlet.resignFirstResponder()
            
            self.emailAddressTFOutlet.layer.borderColor = UIColor.clear.cgColor
            
            self.emailAddressTFOutlet.textColor = UIColor.lightGray
            
//            if (emailAddressTFOutlet.text?.isEqual(profileObjectModel.email))!
//            {
//                
//            }
//            else
//            {
//            }
        }
    }*/
    override func viewDidLayoutSubviews() {
        
        
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
