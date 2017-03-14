//
//  SettingsViewController.swift
//  Example
//
//  Created by Kishy Kumar on 2/19/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

open class SettingsViewController: BaseYibbyViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var userRealNameLabelOutlet: UILabel!
    @IBOutlet weak var aboutButtonOutlet: UIButton!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    @IBOutlet var VW2: UIView!
    
    @IBOutlet var firstNameLbl: UILabel!
    @IBOutlet var lastNameLbl: UILabel!
    
    var customTextfieldProperty = CustomizeTextfield()
    
    var photoSaveCallback: ((UIImage) -> Void)?
    
    let menuItems: [String] =           ["TRIPS",   "PAYMENT",  "SETTINGS", "NOTIFICATIONS",    "SUPPORT",      "PROMOTIONS",   "DRIVE"]
    let menuItemsIconFAFormat: [Int] =  [0xf1ba,    0xf283,     0xf085,     0xf0f3,             0xf1cd,         0xf0a3,         0xf0e4]
    
    let PROFILE_PICTURE_URL_KEY = "PROFILE_PICTURE_URL_KEY"
    
    enum TableIndex: Int {
        case trips = 0
        case payment
        case settings
        case notifications
        case support
        case promotions
        case drive
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Setup Functions
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupViews()
        setupDefaultValues()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupUI() {
        
        self.customBackButton(y: 20 as AnyObject)
        
        customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.emailAddress)
        
        customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.phoneNo)
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        VW2.layer.borderColor = UIColor.borderColor().cgColor
        VW2.layer.borderWidth = 1.0
        VW2.layer.cornerRadius = 7
        firstNameLbl.layer.borderColor = UIColor.borderColor().cgColor
        firstNameLbl.layer.borderWidth = 1.0
        firstNameLbl.layer.cornerRadius = 5
        lastNameLbl.layer.borderColor = UIColor.borderColor().cgColor
        lastNameLbl.layer.borderWidth = 1.0
        lastNameLbl.layer.cornerRadius = 5
    }
    
    fileprivate func setupViews() {
        
    }
    
    fileprivate func setupDefaultValues() {
        
    }
    
    // MARK: Tableview Delegate/DataSource
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let mycell = tableView.dequeueReusableCell(withIdentifier: "LeftNavDrawerCellIdentifier", for: indexPath) as! LeftNavDrawerTableViewCell
        
        // set the label
        mycell.menuItemLabel.text = menuItems[indexPath.row]
        
        // set the icon
        mycell.menuItemIconLabelOutlet.font = UIFont(name: "FontAwesome", size: 20)
        mycell.menuItemIconLabelOutlet.text = String(format: "%C", menuItemsIconFAFormat[indexPath.row])
        
        return mycell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let tHeight = tableView.bounds.height
        let height = tHeight/CGFloat(menuItems.count)
        
        return height
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAtIndexPath indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    // MARK: - Helpers
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
