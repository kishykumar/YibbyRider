//
//  EditProfileViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 10/22/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit

open class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var userRealNameLabelOutlet: UILabel!
    @IBOutlet weak var aboutButtonOutlet: UIButton!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    
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
        setupBackButton()
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
