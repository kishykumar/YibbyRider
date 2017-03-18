//
//  SettingsViewController.swift
//  Example
//
//  Created by Kishy Kumar on 2/19/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import BaasBoxSDK
import GoogleMaps
import MMDrawerController
import BButton


open class SettingsViewController: BaseYibbyViewController,         UITextFieldDelegate,
CLLocationManagerDelegate,UIImagePickerControllerDelegate  {

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
    
    var addHomeLocation: YBLocation?
    //var addHomeMarker: GMSMarker?
    
    @IBOutlet var addHomeBtnOutlet: UIButton!
    @IBOutlet var addWorkBtnOutlet: UIButton!
    
    var addWorkLocation: YBLocation?
    //var addWorkMarker: GMSMarker?
    
    var locationManager:CLLocationManager!    
    
    var placesClient: GMSPlacesClient?
    let regionRadius: CLLocationDistance = 1000
    var addHomeSelected: Bool?
    var addWorkSelected: Bool?
    
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
        
        getProfile()
        
        profileImage.isUserInteractionEnabled = true
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
        
       /* customTextfieldProperty.setLeftViewImage(leftImageIcon: UIImage(named: "Visa")!, senderTextfield: self.emailAddress)
        
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
    
    func getProfile() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.getProfile(BAASBOX_RIDER_STRING, completion:{(success, error) -> Void in
            if ((success) != nil) {
                
                if let resultDict = success as? NSDictionary
                    
                {
                    profileObjectModel.setProfileData(responseDict: resultDict)
                    
                    self.emailAddress.text = profileObjectModel.email
                    self.phoneNo.text = profileObjectModel.phoneNo
                    
                    var myStringArr = profileObjectModel.name.components(separatedBy: " ")
                    
                    self.firstNameLbl.text = String(format: " %@ ", myStringArr[0])
                    self.lastNameLbl.text = myStringArr.count > 1 ? String(format: " %@  ", myStringArr[1]) : nil
                    
                    self.addHomeBtnOutlet.setTitle(profileObjectModel.addHomePlaceName, for: UIControlState())
                    
                self.addWorkBtnOutlet.setTitle(profileObjectModel.addWorkPlaceName, for: UIControlState())
                    
                    DDLogVerbose("getProfile Data: \(success)")
                }
                else {
                    DDLogError("Error in fetching getProfile: \(error)")
                }
                
            }
            else {
                DDLogVerbose("getProfile failed: \(error)")
            }
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
        })
    }

    
    func updateProfile() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        let dictionary = ["email": emailAddress.text]
        
        client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
            if ((success) != nil) {
                
                    self.getProfile()
                
                    DDLogVerbose("updateProfile Data: \(success)")
            }
            else {
                DDLogVerbose("updateProfile failed: \(error)")
            }
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
        })
    }
  
    override open func viewDidLayoutSubviews() {
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.masksToBounds = true
    }

    @IBAction func emergencyContactsBtnAction(sender: AnyObject) {
        
        let emergencyContactsNVC = self.storyboard?.instantiateViewController(withIdentifier: "EmergencyContactsVC") as! EmergencyContactsVC
        _ = self.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
    }
    
   
    @IBAction func addHomeBtnAction(_ sender: Any) {
        
        addHomeSelected = true
        addWorkSelected = false
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
        
        //updateProfile()
        //self.setPickupDetails(loc)
    }
    
        
    @IBAction func addWorkBtnAction(_ sender: Any) {
    
        addHomeSelected = false
        addWorkSelected = true
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
        
        //updateProfile()
        //self.setPickupDetails(loc)
    }
    
    
    @IBAction func profileImageBtnAction(_ sender: UIButton) {
        
        let pickImageClass =  PickImageClass()
        
        pickImageClass.dismissVCCompletion(viewController: self, btn: sender , completionHandler: { (response : UIImage) in
            print(response)
            
            if response != #imageLiteral(resourceName: "Visa") {
                
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.shared()
                
                
                //                - (void) uploadFile:(BAAFile *)file withPermissions:(NSDictionary *)permissions completion:(BAAObjectResultBlock)completionBlock {
                
                let dictionary = ["profilePicture": response]
                
                //- (void) uploadFileWithPermissions:(NSDictionary *)permissions completion:(BAAObjectResultBlock)completionBlock;
                
                let file: BAAFile = BAAFile()
                
                
                client.uploadFile(file, withPermissions: dictionary, completion:{(success, error) -> Void in
                    if ((success) != nil) {
                        
                        self.getProfile()
                        
                        DDLogVerbose("ProfileImage Data: \(success)")
                    }
                    else {
                        DDLogVerbose("ProfileImage failed: \(error)")
                    }
                    
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                })
            }
            //
        })

        
    }
   
    
    func addHomeDetails (_ location: YBLocation) {
        
        self.addHomeLocation = location
        
        print(location.name!)
        
        addHomeBtnOutlet.setTitle(location.name!, for: UIControlState())
        
        print(location.name!)
        
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        //let dictionary = ["email": "kumar01@gmail.com"]
        
        let dict = ["latitude":location.latitude!, "longitude":location.longitude!, "name":location.name!] as [String : Any]
        
        print(dict)
        
        let dictionary = ["homeLocation": dict]
        
        client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
            if ((success) != nil) {
                
                self.getProfile()
                
                DDLogVerbose("updateProfile addHome Data: \(success)")
            }
            else {
                DDLogVerbose("updateProfile addHome failed: \(error)")
            }
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
        })
    }
    
    func addWorkDetails (_ location: YBLocation) {
        addWorkBtnOutlet.setTitle(location.name!, for: UIControlState())
        
        print(location.name!)
        
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        //let dictionary = ["email": "kumar01@gmail.com"]
        
        let dict = ["latitude":location.latitude!, "longitude":location.longitude!, "name":location.name!] as [String : Any]
        
        print(dict)
        
        let dictionary = ["workLocation": dict]
        
        client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
            if ((success) != nil) {
                
                self.getProfile()
                
                DDLogVerbose("updateProfile addWork Data: \(success)")
            }
            else {
                DDLogVerbose("updateProfile addWork failed: \(error)")
            }
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
        })

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
    extension SettingsViewController: GMSAutocompleteViewControllerDelegate {
        
        public func viewController(_ viewController: GMSAutocompleteViewController!, didAutocompleteWith place: GMSPlace!) {
            
            DDLogVerbose("Place name: \(place.name)")
            DDLogVerbose("Place address: \(place.formattedAddress)")
            DDLogVerbose("Place attributions: (place.attributions)")
            
            let loc = YBLocation(coordinate: place.coordinate, name: place.formattedAddress)
            
            if (addHomeSelected == true) {
                self.addHomeDetails(loc)
            } else if (addWorkSelected == true) {
                self.addWorkDetails(loc)
            }
            
            cleanup()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        public func viewController(_ viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: Error!) {
            
            // TODO: handle the error.
            DDLogWarn("Error: \((error as NSError).description)")
            cleanup()
        }
        
        // User canceled the operation.
        public func wasCancelled(_ viewController: GMSAutocompleteViewController!) {
            cleanup()
            self.dismiss(animated: true, completion: nil)
        }
        
        func cleanup () {
            addHomeSelected = false
            addWorkSelected = false
        }
    }
    
    /*extension SettingsViewController: GMSMapViewDelegate {
        
        // MARK: - GMSMapViewDelegate
        public func mapView(_ mapView: GMSMapView!, didTap marker: GMSMarker!) -> Bool {
            
            if (marker == pickupMarker) {
                addHomeSelected = true
            }
            else if (marker == dropoffMarker) {
                addWorkSelected = true
            }
            
            // This view controller lets a user pick address
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            self.present(autocompleteController, animated: true, completion: nil)
            
            // default marker action is false, but we don't want that.
            return true
        }
    }*/

