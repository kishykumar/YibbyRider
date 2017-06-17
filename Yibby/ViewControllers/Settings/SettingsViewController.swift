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
import ObjectMapper
import GooglePlaces
import ImagePicker
import Lightbox
import BButton

class SettingsViewController: BaseYibbyViewController, UITextFieldDelegate  {

    // MARK: - Properties
    
    @IBOutlet weak var emailAddress: YibbyTextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var profileImageViewOutlet: UIImageView!
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    @IBOutlet var VW2: UIView!
    @IBOutlet var firstNameLbl: UILabel!
    @IBOutlet var lastNameLbl: UILabel!
    @IBOutlet var addHomeBtnOutlet: UIButton!
    @IBOutlet var addWorkBtnOutlet: UIButton!
    @IBOutlet var emailEditBtnOutlet: UIButton!
    @IBOutlet weak var addHomePlusButtonOutlet: UIButton!
    @IBOutlet weak var addWorkPlusButtonOutlet: UIButton!
    
    var addWorkLocation: YBLocation?
    var addHomeLocation: YBLocation?

    var addHomeSelected: Bool?
    var addWorkSelected: Bool?
    
    var profileImgFileId: String?

    var emailEditInProgress = false
    
    let imagePickerController = ImagePickerController()

    // MARK: - Actions
    
    
    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupDelegates()
        setupImagePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: bug in ImagePicker: they remove the status bar :(
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    func setupImagePicker() {
        self.imagePickerController.imageLimit = 1
    }
    
    func setupDelegates() {
        imagePickerController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupUI() {
        
        setupBackButton()
        
        VW.layer.borderColor = UIColor.appDarkGreen1().cgColor
        VW1.layer.borderColor = UIColor.appDarkGreen1().cgColor
        VW2.layer.borderColor = UIColor.appDarkGreen1().cgColor

        firstNameLbl.layer.borderColor = UIColor.appDarkGreen1().cgColor
        lastNameLbl.layer.borderColor = UIColor.appDarkGreen1().cgColor
        
        emailEditBtnOutlet.layer.borderColor = UIColor.appDarkGreen1().cgColor
        emailEditBtnOutlet.layer.borderWidth = 1.0
        emailEditBtnOutlet.layer.cornerRadius = 7.0
        
        profileImageViewOutlet.makeRounded()
        
        addHomePlusButtonOutlet.setTitleColor(UIColor.appDarkGreen1(), for: .normal)
        addWorkPlusButtonOutlet.setTitleColor(UIColor.appDarkGreen1(), for: .normal)
        
        emailAddress.removeFormatting()
    }
    
    func getProfilePicture() {
        if let profilePic = YBClient.sharedInstance().getProfile()?.profilePicture {
            if (profilePic != "") {
                if let imageUrl  = BAAFile.getCompleteURL(withToken: profilePic) {
                
                    profileImageViewOutlet.pin_setImage(from: imageUrl)
                }
            }
        }
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
                    self.phoneNo.text = profile.phoneNumber?.toPhoneNumber()
                    
                    let nameArr = profile.name?.components(separatedBy: " ")
                    
                    if let myStringArr = nameArr {
                        self.firstNameLbl.text = String(format: " %@ ", myStringArr[0])
                        self.lastNameLbl.text = myStringArr.count > 1 ? String(format: " %@  ", myStringArr[1]) : nil
                        
                        if (self.lastNameLbl.text == nil || self.lastNameLbl.text == "") {
                            self.lastNameLbl.isHidden = true
                            self.lastNameLbl.isEnabled = false
                        }
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

    @IBAction func emergencyContactsBtnAction(sender: AnyObject) {
        
        let emergencyContactsNVC = self.storyboard?.instantiateViewController(withIdentifier: "EmergencyContactsVC") as! EmergencyContactsVC
        _ = self.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
    }
    
    @IBAction func onAddHomePlusButtonClick(_ sender: UIButton) {
        addHomeSelected = true
        addWorkSelected = false
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
   
    @IBAction func addHomeBtnAction(_ sender: Any) {
        
        addHomeSelected = true
        addWorkSelected = false
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func onAddWorkPlusButtonClick(_ sender: UIButton) {
        addHomeSelected = false
        addWorkSelected = true
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func addWorkBtnAction(_ sender: Any) {
        addHomeSelected = false
        addWorkSelected = true
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func onProfileImageClick(_ sender: UITapGestureRecognizer) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func emailEditBtnAction(_ sender: Any) {
        
        if (emailEditInProgress == true) {
            emailEditBtnOutlet.setFAIcon(icon: .FAWrench, forState: .normal)
            emailEditBtnOutlet.setTitleColor(UIColor.black, for: .normal)
            emailEditBtnOutlet.layer.borderWidth = 1.0
            
            emailAddress.isUserInteractionEnabled = false
            emailAddress.resignFirstResponder()
            emailAddress.removeFormatting()
            
            if (emailAddress.text?.isEqual(YBClient.sharedInstance().getProfile()?.email))! {
                
            }
            else {
//                updateProfile()
            }
            
            emailEditInProgress = false
            
        } else {
            
            emailEditBtnOutlet.setFAIcon(icon: .FACheckCircle, forState: .normal)
//            emailEditBtnOutlet.setFATitleColor(color: UIColor.appDarkGreen1())
//            emailEditBtnOutlet.tintColor = UIColor.appDarkGreen1()
            emailEditBtnOutlet.setTitleColor(UIColor.appDarkGreen1(), for: .normal)
            emailEditBtnOutlet.layer.borderWidth = 0.0
            
            emailAddress.isUserInteractionEnabled = true
            emailAddress.becomeFirstResponder()
            emailAddress.layer.borderWidth = 1.0
            emailAddress.layer.cornerRadius = 7.0
            emailAddress.layer.borderColor = UIColor.appDarkGreen1().cgColor
            
//            self.emailAddress.padding = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)

            emailEditInProgress = true
        }

//        if (self.emailEditBtnOutlet.currentImage?.isEqual(UIImage(named: "Settings")))! {
//            self.emailEditBtnOutlet.setImage(UIImage(named: "tick"), for: .normal)
//            
//            self.emailAddress.layer.borderColor = UIColor.borderColor().cgColor
//            self.emailAddress.layer.borderWidth = 1.0
//            self.emailAddress.layer.cornerRadius = 7
//            
//            let col2 = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
//            
//            self.emailAddress.textColor = col2
//            
//            self.emailAddress.isUserInteractionEnabled = true
//
//            self.emailAddress.becomeFirstResponder()
//            
//        }
//        else
//        {
//             self.emailEditBtnOutlet.setImage(UIImage(named: "Settings"), for: .normal)
//            self.emailEditBtnOutlet.setRoundedWithWhiteBorder()
//
//            self.emailAddress.isUserInteractionEnabled = false
//
//            self.emailAddress.resignFirstResponder()
//            
//            self.emailAddress.layer.borderColor = UIColor.clear.cgColor
//            
//            self.emailAddress.textColor = UIColor.lightGray
//            
//            if (emailAddress.text?.isEqual(YBClient.sharedInstance().getProfile()?.email))!
//            {
//                
//            }
//            else
//            {
//                updateProfile()
//            }
//        }
    }
    
    // MARK: - Helpers
        
    func addHomeDetails (_ location: YBLocation) {
        
        self.addHomeLocation = location
        
        print(location.name!)
        
        addHomeBtnOutlet.setTitle(location.name!, for: UIControlState())
        
        print(location.name!)
        
        if location.name!.isEqual(YBClient.sharedInstance().getProfile()?.homeLocation?.name)
        {
            
        }
        else
        {
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
    }
    
    func addWorkDetails (_ location: YBLocation) {
        addWorkBtnOutlet.setTitle(location.name!, for: UIControlState())
        
        print(location.name!)
        
        if location.name!.isEqual(YBClient.sharedInstance().getProfile()?.workLocation?.name)
        {
            
        }
        else
        {
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

    }
}

extension SettingsViewController: GMSAutocompleteViewControllerDelegate {
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        DDLogVerbose("Place name: \(place.name)")
        DDLogVerbose("Place address: \(place.formattedAddress)")
        DDLogVerbose("Place attributions: (place.attributions)")
        
        let loc = YBLocation(coordinate: place.coordinate, name: place.formattedAddress!)
        
        if (addHomeSelected == true) {
            self.addHomeDetails(loc)
        } else if (addWorkSelected == true) {
            self.addWorkDetails(loc)
        }
        
        cleanup()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        // TODO: handle the error.
        DDLogWarn("Error: \((error as NSError).description)")
        cleanup()
    }
    
    // User canceled the operation.
    public func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        cleanup()
        self.dismiss(animated: true, completion: nil)
    }
    
    func cleanup () {
        addHomeSelected = false
        addWorkSelected = false
    }
}

extension SettingsViewController: ImagePickerDelegate {
    
    public func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    public func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePickerController.present(lightbox, animated: true, completion: nil)
    }
    
    public func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        guard images.count > 0 else { return }
        
        if let image = images.first {
            ActivityIndicatorUtil.enableActivityIndicator(self.view)
            
            ImageService.sharedInstance().uploadImage(image,
              cacheKey: .profilePicture,
              success: { (url, fileId) in
                ActivityIndicatorUtil.disableActivityIndicator(self.view)

                self.profileImgFileId = fileId
                
                // update UI here
                self.profileImageViewOutlet.image = image
              },
              failure: { error in
                DDLogError("Failure in uploading profile picture: \(error.description)")
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
                
            })
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}

//extension SettingsViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
//    
//    func showImagePickerActionSheet( btn : UIButton ) {
//        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        
//        let actionSheet = UIAlertController(title: "Choose Image", message: "", preferredStyle: .actionSheet)
//        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { action -> Void in
//            //Do some other stuff
//            picker.allowsEditing = true
//            picker.sourceType = .photoLibrary
//            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
//            self.present(picker, animated: true, completion: nil)
//            
//        })
//        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
//            //Do some other stuff
//            picker.allowsEditing = true
//            picker.sourceType = .camera
//            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
//            self.present(picker, animated: true, completion: nil)
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
//            
//        })
//        actionSheet.addAction(cameraAction)
//        actionSheet.addAction(photoLibrary)
//        actionSheet.addAction(cancelAction)
//        
//        if let presenter = actionSheet.popoverPresentationController {
//            presenter.sourceView = btn
//            presenter.sourceRect = btn.bounds
//        }
//        
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//    
//    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
//    {
//        
//        let imageSelected : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
//        print(imageSelected)
//        
//        self.uploadProfileImage(image: imageSelected)
//        
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        
//        picker.dismiss(animated: true, completion: nil)
//        
//    }
//    
//    public func uploadProfileImage(image: UIImage){
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//        
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//        ImageService.sharedInstance().uploadImage(image,
//            cacheKey: .profilePicture,
//            success: { (url, fileId) in
//                ActivityIndicatorUtil.disableActivityIndicator(self.view)
//                self.profileImgFileId = fileId
//                let client: BAAClient = BAAClient.shared()
//
//                let dictionary = ["profilePicture": fileId]
//
//                client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
//
//                if ((success) != nil) {
//                    
//                    self.getProfile()
//                    
//                    DDLogVerbose("updateProfile image: \(success)")
//                }
//                else {
//                    DDLogVerbose("updateProfile image failed: \(error)")
//                }
//
//                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
//                })
//            },
//            failure: { error in
//                DDLogError("Failure in uploading vehicleInspForm picture: \(error.description)")
//                ActivityIndicatorUtil.disableActivityIndicator(self.view)
//            })
//    }
//}

extension String {
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
}
