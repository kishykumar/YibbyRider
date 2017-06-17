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


open class LeftNavDrawerViewController: BaseYibbyViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var userRealNameLabelOutlet: UILabel!
    @IBOutlet weak var aboutButtonOutlet: UIButton!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    
    var photoSaveCallback: ((UIImage) -> Void)?
    
    let menuItems: [String] =           ["TRIPS",   "PAYMENT",  "PROFILE", "NOTIFICATIONS",    "SUPPORT",      "PROMOTIONS",   "DRIVE"]
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
    
    @IBAction func onAboutButtonClick(_ sender: AnyObject) {
        
        // Push the About View Controller
        let aboutStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.About, bundle: nil)
        let aboutViewController = aboutStoryboard.instantiateViewController(withIdentifier: "AboutViewControllerIdentifier") as! AboutViewController
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
//            mmnvc.isNavigationBarHidden = false
            
            mmnvc.pushViewController(aboutViewController, animated: true)
            appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
        } else {
            assert(false)
        }
    }
    
    @IBAction func onSignOutButtonClick(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: InterfaceString.SignOut.ConfirmSignOutTitle, message: InterfaceString.SignOut.ConfirmSignOutMessage, preferredStyle:UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: InterfaceString.Cancel.uppercased(), style: UIAlertActionStyle.default)
        { action -> Void in
            // Put your code here
        })
        
        alertController.addAction(UIAlertAction(title: InterfaceString.SignOut.SignOut.uppercased(), style: UIAlertActionStyle.default)
        { action -> Void in
            // Put your code here
            self.logoutUser()
        })
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func onUpdateProfilePictureAction(_ sender: AnyObject) {
        photoSaveCallback = { image in
            ActivityIndicatorUtil.enableActivityIndicator(self.view)
            ProfileService().updateUserProfilePicture(image,
              success: { url in
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(url, forKey: self.PROFILE_PICTURE_URL_KEY)
                
                self.profilePictureOutlet.image = image
              },
              failure: { _, _ in
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
            })
        }
        openImagePicker()
    }
    
    @IBAction func onProfileButtonClick(sender: AnyObject) {
        
//        let profileStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.ProfileStoryboard, bundle: nil)
//        let profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "ProfileViewControllerIdentifier") as! ProfileVC
        
        let settingsStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Settings, bundle: nil)
        let settingsViewController = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsViewControllerIdentifier") as! SettingsViewController
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            
//            mmnvc.isNavigationBarHidden = false
            mmnvc.pushViewController(settingsViewController, animated: true)
            appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
        } else {
            assert(false)
        }
    }
    
    // MARK: - Setup Functions
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupViews()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set tableview botton border in viewDidAppear because the tableView height is coming incorrect in viewDidLoad
        self.tableView.addBottomBorder()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
//        self.userRealNameLabelOutlet.text = YBClient.sharedInstance().getProfile()?.name
//        self.getProfilePicture()
        super.viewWillAppear(animated)
    }
    
    
    func getProfilePicture() {
        if let profilePic = YBClient.sharedInstance().getProfile()?.profilePicture {
            if (profilePic != "") {
                if let imageUrl  = BAAFile.getCompleteURL(withToken: profilePic) {
                    
                    profilePictureOutlet.pin_setImage(from: imageUrl)
                }
            }
        }
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupUI() {
        
        // Modify the background color because we don't want to show the regular gray one.
        self.view.backgroundColor = UIColor.appDarkGreen1();
        
        // Set rounded profile pic
        self.profilePictureOutlet.setRoundedWithWhiteBorder()
        
//        self.profilePictureOutlet.layer.cornerRadius = self.profilePictureOutlet.frame.size.height / 2;
//        self.profilePictureOutlet.layer.borderWidth = 2.0
//        self.profilePictureOutlet.layer.borderColor = UIColor.white.cgColor
//        self.profilePictureOutlet.layer.masksToBounds = true
//        self.profilePictureOutlet.clipsToBounds = true
        
        if let userRealName = YBClient.sharedInstance().getProfile()?.name {
            if (userRealName != "") {
                self.userRealNameLabelOutlet.text = userRealName
            } else {
                self.userRealNameLabelOutlet.text = "Yibby User"
            }
        }
    }
    
    fileprivate func setupViews() {
        setupDefaultValues()
    }
    
    fileprivate func setupDefaultValues() {
        let userDefaults = UserDefaults.standard
        
        if let cachedImage = TemporaryCache.load(.coverImage) {
            profilePictureOutlet.image = cachedImage
        }
        else if let imageURL = userDefaults.url(forKey: self.PROFILE_PICTURE_URL_KEY) {
            
            let client: BAAClient = BAAClient.shared()
            
            if let newUrl = client.getCompleteURL(withToken: imageURL) {
                profilePictureOutlet.pin_setImage(from: newUrl)
            }
        }
    }
    
    // MARK: Tableview Delegate/DataSource
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mycell = tableView.dequeueReusableCell(withIdentifier: "LeftNavDrawerCellIdentifier", for: indexPath) as! LeftNavDrawerTableViewCell
        
        // set the label
        mycell.menuItemLabel.text = menuItems[indexPath.row]
        
        // set the icon
        mycell.menuItemIconLabelOutlet.font = UIFont(name: "FontAwesome", size: 20)
        mycell.menuItemIconLabelOutlet.text = String(format: "%C", menuItemsIconFAFormat[indexPath.row])
        
        // Cell shadow UI
        mycell.layer.shadowOpacity = 0.5
        mycell.layer.shadowRadius = 1.7
        mycell.layer.shadowColor = UIColor.black.cgColor
        mycell.layer.shadowOffset = CGSize(width: 0, height: 0)
        mycell.layer.masksToBounds = false
        mycell.layer.shadowPath = UIBezierPath(rect: mycell.bounds).cgPath
        
        return mycell
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tHeight = tableView.bounds.height
        let height = tHeight/CGFloat(menuItems.count)
        
        return height
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedViewController: UIViewController = UIViewController()
        
        switch (indexPath.row) {
        case TableIndex.payment.rawValue:
            
            let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
            selectedViewController = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentViewControllerIdentifier") as! PaymentViewController
            
            break
        case TableIndex.trips.rawValue:
            
            let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
            selectedViewController = historyStoryboard.instantiateViewController(withIdentifier: "TripTableVC") as! TripTableVC
            
            //selectedViewController = historyStoryboard.instantiateViewController(withIdentifier: "HistoryViewControllerIdentifier") as! HistoryViewController
            
            break
            
        case TableIndex.notifications.rawValue:
            let settingsStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Drawer, bundle: nil)
            selectedViewController = settingsStoryboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
            
            break
            
        case TableIndex.settings.rawValue:
            
            let settingsStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Settings, bundle: nil)
            selectedViewController = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsViewControllerIdentifier") as! SettingsViewController
            
            break
        case TableIndex.promotions.rawValue:
            
            let promotionsStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Promotions, bundle: nil)
            selectedViewController = promotionsStoryboard.instantiateViewController(withIdentifier: "PromotionsViewControllerIdentifier") as! PromotionsViewController
            
            break
        case TableIndex.support.rawValue:
            
            let helpStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Help, bundle: nil)
            selectedViewController = helpStoryboard.instantiateViewController(withIdentifier: "HelpViewControllerIdentifier") as! HelpViewController
            
            break
        default:
            break
        }
        
        // Push the selected view controller to the main navigation controller
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
//            mmnvc.isNavigationBarHidden = false
            mmnvc.pushViewController(selectedViewController, animated: true)
            appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            
        } else {
            assert(false)
        }
    }
    
    // BaasBox logout user
    func logoutUser() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        client.logoutCaber(withCompletion: BAASBOX_RIDER_STRING, completion: {(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if (success || ((error as! NSError).domain == BaasBox.errorDomain() && (error as! NSError).code ==
                WebInterface.BAASBOX_AUTHENTICATION_ERROR)) {
                
                // pop all the view controllers so that user starts fresh :)
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
                    mmnvc.popToRootViewController(animated: false)
                }
                
                DDLogInfo("user logged out successfully \(success)")
                // if logout is successful, remove username, password from keychain
                LoginViewController.removeLoginKeyChainKeys()
                
                // Show the Signup/LoginViewController View
                
                let signupStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.SignUp,
                                                                  bundle: nil)
                
                self.present(signupStoryboard.instantiateInitialViewController()!, animated: false, completion: nil)
            }
            else {
                // We continue the user session if Logout hits an error
                if ((error as! NSError).domain == BaasBox.errorDomain()) {
                    DDLogError("Error in logout: \(error)")
                    AlertUtil.displayAlert("Error Logging out. ", message: "This is...weird.")
                }
                else {
                    AlertUtil.displayAlert("Connectivity or Server Issues.", message: "Please check your internet connection or wait for some time.")
                }
            }
        })
    }
    
    // MARK: - Helpers
    
    fileprivate func openImagePicker() {
        let alertViewController = UIImagePickerController.alertControllerForImagePicker { imagePicker in
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: .none)
        }
        
        if let alertViewController = alertViewController {
            present(alertViewController, animated: true, completion: .none)
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
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            DDLogVerbose("Success")
            
            image.copyWithCorrectOrientationAndSize() { image in
                
                self.photoSaveCallback?(image.squareImage()!.roundCorners()!)
                self.dismiss(animated: true, completion: .none)
            }
        }
        else {
            DDLogVerbose("Failure")
            
            self.dismiss(animated: true, completion: .none)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: .none)
    }
}
