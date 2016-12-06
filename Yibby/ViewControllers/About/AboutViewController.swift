//
//  AboutViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

public class AboutViewController: BaseYibbyViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var userRealNameLabelOutlet: UILabel!
    @IBOutlet weak var aboutButtonOutlet: UIButton!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    
    var photoSaveCallback: (UIImage -> Void)?
    
    let menuItems: [String] =           ["TRIPS",   "PAYMENT",  "SETTINGS", "NOTIFICATIONS",    "SUPPORT",      "PROMOTIONS",   "DRIVE"]
    let menuItemsIconFAFormat: [Int] =  [0xf1ba,    0xf283,     0xf085,     0xf0f3,             0xf1cd,         0xf0a3,         0xf0e4]
    
    let PROFILE_PICTURE_URL_KEY = "PROFILE_PICTURE_URL_KEY"
    
    enum TableIndex: Int {
        case Trips = 0
        case Payment
        case Settings
        case Notifications
        case Support
        case Promotions
        case Drive
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Setup Functions
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupViews()
        setupDefaultValues()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
    }
    
    private func setupViews() {
        
    }
    
    private func setupDefaultValues() {
        
    }
    
    // MARK: Tableview Delegate/DataSource
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mycell = tableView.dequeueReusableCellWithIdentifier("LeftNavDrawerCellIdentifier", forIndexPath: indexPath) as! LeftNavDrawerTableViewCell
        
        // set the label
        mycell.menuItemLabel.text = menuItems[indexPath.row]
        
        // set the icon
        mycell.menuItemIconLabelOutlet.font = UIFont(name: "FontAwesome", size: 20)
        mycell.menuItemIconLabelOutlet.text = String(format: "%C", menuItemsIconFAFormat[indexPath.row])
        
        return mycell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let tHeight = tableView.bounds.height
        let height = tHeight/CGFloat(menuItems.count)
        
        return height
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
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
