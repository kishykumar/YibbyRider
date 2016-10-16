//
//  LeftNavDrawerViewController.swift
//  Example
//
//  Created by Kishy Kumar on 2/18/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import MMDrawerController
import BaasBoxSDK
import CocoaLumberjack
import PINRemoteImage
import Crashlytics

public class LeftNavDrawerViewController: BaseYibbyViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var userRealNameLabelOutlet: UILabel!
    
    
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
    
    @IBAction func onAboutButtonClick(sender: AnyObject) {
        
        // Push the About View Controller
        let aboutStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.About, bundle: nil)
        let aboutViewController = aboutStoryboard.instantiateViewControllerWithIdentifier("AboutViewControllerIdentifier") as! AboutViewController
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            
            mmnvc.pushViewController(aboutViewController, animated: true)
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
        } else {
            assert(false)
        }
    }
    
    @IBAction func onSignOutButtonClick(sender: AnyObject) {
        logoutUser()
    }
    
    
    // MARK: - Setup Functions
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupViews()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Set tableview botton border in viewDidAppear because the tableView height is coming incorrect in viewDidLoad
        self.tableView.addBottomBorder()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // Modify the background color because we don't want to show the regular gray one.
        self.view.backgroundColor = UIColor.appDarkGreen1();

        // Set rounded profile pic
        self.profilePictureOutlet.setRoundedWithWhiteBorder()
    }
    
    private func setupViews() {
        setupDefaultValues()
    }
    
    private func setupDefaultValues() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let cachedImage = TemporaryCache.load(.CoverImage) {
            profilePictureOutlet.image = cachedImage
        }
        else if let imageURL = userDefaults.URLForKey(self.PROFILE_PICTURE_URL_KEY) {
            
            let client: BAAClient = BAAClient.sharedClient()
            
            if let newUrl = client.getCompleteURLWithToken(imageURL) {
                profilePictureOutlet.pin_setImageFromURL(newUrl)
            }
        }
    }
    
    // MARK: Tableview Delegate/DataSource
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mycell = tableView.dequeueReusableCellWithIdentifier("LeftNavDrawerCellIdentifier", forIndexPath: indexPath) as! LeftNavDrawerTableViewCell

        // set the label
        mycell.menuItemLabel.text = menuItems[indexPath.row]
        
        // set the icon
        mycell.menuItemIconLabelOutlet.font = UIFont(name: "FontAwesome", size: 20)
        mycell.menuItemIconLabelOutlet.text = String(format: "%C", menuItemsIconFAFormat[indexPath.row])
        
        // Cell shadow UI
        mycell.layer.shadowOpacity = 0.5
        mycell.layer.shadowRadius = 1.7
        mycell.layer.shadowColor = UIColor.blackColor().CGColor
        mycell.layer.shadowOffset = CGSize(width: 0, height: 0)
        mycell.layer.masksToBounds = false
        mycell.layer.shadowPath = UIBezierPath(rect: mycell.bounds).CGPath
        
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
        
        var selectedViewController: UIViewController = UIViewController()
        
        switch (indexPath.row) {
        case TableIndex.Payment.rawValue:
            
            let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
            selectedViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
            
            break
        case TableIndex.Trips.rawValue:
            
            let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
            selectedViewController = historyStoryboard.instantiateViewControllerWithIdentifier("HistoryViewControllerIdentifier") as! HistoryViewController

            break
        case TableIndex.Settings.rawValue:
            
            let settingsStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Settings, bundle: nil)
            selectedViewController = settingsStoryboard.instantiateViewControllerWithIdentifier("SettingsViewControllerIdentifier") as! SettingsViewController
            
            break
        case TableIndex.Promotions.rawValue:
            
            let promotionsStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Promotions, bundle: nil)
            selectedViewController = promotionsStoryboard.instantiateViewControllerWithIdentifier("PromotionsViewControllerIdentifier") as! PromotionsViewController
            
            break
        case TableIndex.Support.rawValue:
            
            let helpStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Help, bundle: nil)
            selectedViewController = helpStoryboard.instantiateViewControllerWithIdentifier("HelpViewControllerIdentifier") as! HelpViewController
            
            break
        default:
            break
        }

        // Push the selected view controller to the main navigation controller
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            
            mmnvc.pushViewController(selectedViewController, animated: true)
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
        } else {
            assert(false)
        }
    }
    
    // BaasBox logout user
    func logoutUser() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.sharedClient()
        client.logoutCaberWithCompletion(BAASBOX_RIDER_STRING, completion: {(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if (success || (error.domain == BaasBox.errorDomain() && error.code ==
                            WebInterface.BAASBOX_AUTHENTICATION_ERROR)) {
                
                // pop all the view controllers so that user starts fresh :)
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
                    mmnvc.popToRootViewControllerAnimated(false)
                }
                
                DDLogInfo("user logged out successfully \(success)")
                // if logout is successful, remove username, password from keychain
                LoginViewController.removeLoginKeyChainKeys()
                
                // Show the Signup/LoginViewController View
                
                let signupStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.SignUp,
                    bundle: nil)
                
                self.presentViewController(signupStoryboard.instantiateInitialViewController()!, animated: false, completion: nil)
                
//                let loginStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Login, bundle: nil)
//
//                if let loginViewController = loginStoryboard.instantiateViewControllerWithIdentifier("LoginViewControllerIdentifier") as? LoginViewController
//                {
//                    loginViewController.onStartup = true
//                    self.presentViewController(loginViewController, animated: true, completion: nil)
//                }
            }
            else {
                // We continue the user session if Logout hits an error
                if (error.domain == BaasBox.errorDomain()) {
                    DDLogError("Error in logout: \(error)")
                    AlertUtil.displayAlert("Error Logging out. ", message: "This is...weird.")
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func onUpdateProfilePictureAction(sender: AnyObject) {
        photoSaveCallback = { image in
            ActivityIndicatorUtil.enableActivityIndicator(self.view)
            ProfileService().updateUserProfilePicture(image,
                success: { url in
                    DDLogVerbose("Success")
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setURL(url, forKey: self.PROFILE_PICTURE_URL_KEY)

                    self.profilePictureOutlet.image = image
                },
                failure: { _, _ in
                    DDLogVerbose("Failure")
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
            })
        }
        openImagePicker()
    }
    
    // MARK: - Helpers
    
    private func openImagePicker() {
        let alertViewController = UIImagePickerController.alertControllerForImagePicker { imagePicker in
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: .None)
        }
        
        if let alertViewController = alertViewController {
            presentViewController(alertViewController, animated: true, completion: .None)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LeftNavDrawerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            DDLogVerbose("Success")

            image.copyWithCorrectOrientationAndSize() { image in
                
                self.photoSaveCallback?(image.squareImage()!.roundCorners()!)
                self.dismissViewControllerAnimated(true, completion: .None)
            }
        }
        else {
            DDLogVerbose("Failure")

            self.dismissViewControllerAnimated(true, completion: .None)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: .None)
    }
}
