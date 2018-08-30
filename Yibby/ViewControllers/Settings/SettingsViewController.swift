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
import SwiftValidator

public struct ProfileNotifications {
    static let profilePictureUpdated = TypedNotification<String>(name: "com.Yibby.Profile.updateProfilePicture")
}

class SettingsViewController: BaseYibbyViewController, UITextFieldDelegate, ValidationDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var emailAddress: YibbyTextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var profileImageViewOutlet: SwiftyAvatar!
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
    
    @IBOutlet weak var errorLabelOutlet: UILabel!
    
    
    var addWorkLocation: YBLocation?
    var addHomeLocation: YBLocation?

    var addHomeSelected: Bool?
    var addWorkSelected: Bool?
    
    var emailEditInProgress = false
    
    let imagePickerController = ImagePickerController()

    let validator = Validator()

    // MARK: - Actions
    
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
            
            self.validator.validate(self)
            
        } else {
            
            emailEditBtnOutlet.setFAIcon(icon: .FACheckCircle, forState: .normal)
            emailEditBtnOutlet.setTitleColor(UIColor.appDarkGreen1(), for: .normal)
            emailEditBtnOutlet.layer.borderWidth = 0.0
            
            emailAddress.isUserInteractionEnabled = true
            emailAddress.becomeFirstResponder()
            emailAddress.layer.borderWidth = 1.0
            emailAddress.layer.cornerRadius = 7.0
            emailAddress.layer.borderColor = UIColor.appDarkGreen1().cgColor
            
            emailEditInProgress = true
        }
    }
    

    // MARK: - Setup Functions
    
    func setupValidator() {
        validator.styleTransformers(success:{ (validationRule) -> Void in
            
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.appDarkGreen1().cgColor
            }
        }, error:{ (validationError) -> Void in
            
            //            validationError.errorLabel?.isHidden = false
            //            validationError.errorLabel?.text = validationError.errorMessage
            //
            //            if let textField = validationError.field as? UITextField {
            //                textField.setBottomBorder(UIColor.red)
            //            }
        })
        
        validator.registerField(self.emailAddress,
                                errorLabel: errorLabelOutlet,
                                rules: [RequiredRule(message: "Email Address is required"), EmailRule()])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupDelegates()
        setupImagePicker()
        setupValidator()
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
        
        VW2.isHidden = true
        
        VW.layer.borderColor = UIColor.appDarkGreen1().cgColor
        VW1.layer.borderColor = UIColor.appDarkGreen1().cgColor
        VW2.layer.borderColor = UIColor.appDarkGreen1().cgColor

        firstNameLbl.layer.borderColor = UIColor.appDarkGreen1().cgColor
        lastNameLbl.layer.borderColor = UIColor.appDarkGreen1().cgColor
        
        emailEditBtnOutlet.layer.borderColor = UIColor.appDarkGreen1().cgColor
        emailEditBtnOutlet.layer.borderWidth = 1.0
        emailEditBtnOutlet.layer.cornerRadius = 7.0
        
        profileImageViewOutlet.borderColor = UIColor.appDarkGreen1()
        
        addHomePlusButtonOutlet.setTitleColor(UIColor.appDarkGreen1(), for: .normal)
        addWorkPlusButtonOutlet.setTitleColor(UIColor.appDarkGreen1(), for: .normal)
        
        emailAddress.removeFormatting()
        
        if let profile = YBClient.sharedInstance().profile {
            self.applyProfileModel(profile)
            setProfilePicture()
        }
    }
    
    // MARK: - ValidationDelegate Methods
    
    func validationSuccessful() {
        
        emailEditBtnOutlet.setFAIcon(icon: .FAWrench, forState: .normal)
        emailEditBtnOutlet.setTitleColor(UIColor.black, for: .normal)
        emailEditBtnOutlet.layer.borderWidth = 1.0
        
        emailAddress.isUserInteractionEnabled = false
        emailAddress.resignFirstResponder()
        emailAddress.removeFormatting()
        
        if (emailAddress.text?.isEqual(YBClient.sharedInstance().profile?.email))! {
            
        }
        else {
            updateEmail()
        }
        
        emailEditInProgress = false
    }
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        
        let (_, validationError) = errors[0]

        emailAddress.layer.borderColor = UIColor.red.cgColor
        validationError.errorLabel?.isHidden = false
        validationError.errorLabel?.text = validationError.errorMessage
    }
    
    // MARK: - Helpers
    
    func setProfilePicture() {
        
        profileImageViewOutlet.setImageForName(string: YBClient.sharedInstance().profile!.name!,
                                               backgroundColor: UIColor.appDarkGreen1(),
                                               circular: true,
                                               textAttributes: nil)
        
        if let profilePic = YBClient.sharedInstance().profile?.profilePicture {
            if (profilePic != "") {
                if let imageUrl  = BAAFile.getCompleteURL(withToken: profilePic) {
                
                    profileImageViewOutlet.pin_setImage(from: imageUrl)
                }
            }
        }
    }

    @available(*, deprecated)
    func getProfile() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.getProfile(BAASBOX_RIDER_STRING, completion:{(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            DDLogVerbose("getProfile data: \(String(describing: success))")
            
            if let success = success {
                let profileModel = Mapper<YBProfile>().map(JSONObject: success)
                
                if let profile = profileModel {
                    self.applyProfileModel(profile)
                }
                else {
                    AlertUtil.displayAlertOnVC(self, title: "Error in Fetching User Profile", message: error?.localizedDescription ?? "")
                    DDLogVerbose("getProfile failed1: \(String(describing: success))")
                }
                
            } else {
                // TODO: Show the alert with error
                AlertUtil.displayAlertOnVC(self, title: "Error in Fetching User Profile", message: error?.localizedDescription ?? "")
                DDLogVerbose("getProfile failed2: \(String(describing: error))")
            }
        })
    }
    
    func updateEmail() {
        
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
            ActivityIndicatorUtil.enableActivityIndicator(self.view)
            let client: BAAClient = BAAClient.shared()
            
            let dictionary: [String: String] = ["email": emailAddress.text!]
            
            client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
                if let success = success {
                    let profileModel = Mapper<YBProfile>().map(JSONObject: success)
                    
                    if let profile = profileModel {
                        self.applyProfileModel(profile)
                        ToastUtil.displayToastOnVC(self, title: "Email has been successfully changed", body: "", theme: .success, presentationStyle: .bottom, duration: .seconds(seconds: 5), windowLevel: UIWindowLevelNormal)
                    }
                    else {
                        AlertUtil.displayAlertOnVC(self, title: "Error in Updating User Profile", message: error?.localizedDescription ?? "")
                        DDLogError("Error in updating Profile: \(String(describing: success))")
                    }
                }
                else {
                    DDLogVerbose("updateProfile failed: \(String(describing: error))")
                    errorBlock(success, error)
                }
                
                ActivityIndicatorUtil.disableActivityIndicator(self.view)
            })
        })
    }

    func applyProfileModel(_ profile: YBProfile) {
        
        // update the global profile object first
        YBClient.sharedInstance().profile = profile
        
        self.emailAddress.text = profile.email
        self.phoneNo.text = profile.phoneNumber?.toPhoneNumber()
        
        let nameArr = profile.name?.components(separatedBy: " ")
        
        if let myStringArr = nameArr {
            
            let firstName = String(format: " %@ ", myStringArr[0])
            self.firstNameLbl.text = firstName.uppercased()
            
            let lastName = myStringArr.count > 1 ? String(format: " %@  ", myStringArr[1]) : nil
            self.lastNameLbl.text = lastName?.uppercased()
            
            if (self.lastNameLbl.text == nil || self.lastNameLbl.text == "") {
                self.lastNameLbl.isHidden = true
                self.lastNameLbl.isEnabled = false
            }
        }
        
        if let homeLocName = profile.homeLocation?.name {
            if (homeLocName != "") {
                self.addHomeBtnOutlet.setTitle(homeLocName, for: UIControlState())
            }
        }
        
        if let workLocName = profile.workLocation?.name {
            if (workLocName != "") {
                self.addWorkBtnOutlet.setTitle(workLocName, for: UIControlState())
            }
        }
        
        setProfilePicture()
    }

    func addHomeDetails (_ location: YBLocation) {
        
        self.addHomeLocation = location
        
        addHomeBtnOutlet.setTitle(location.name!, for: UIControlState())
        
        if location.name!.isEqual(YBClient.sharedInstance().profile?.homeLocation?.name) {
            
        }
        else {
            WebInterface.makeWebRequestAndHandleError(
                self,
                webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                    
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.shared()
                    
                let dict = ["latitude":location.latitude!, "longitude":location.longitude!, "name":location.name!] as [String : Any]
                let dictionary = ["homeLocation": dict]
                
                client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
                    if let success = success {
                        let profileModel = Mapper<YBProfile>().map(JSONObject: success)
                        
                        if let profile = profileModel {
                            self.applyProfileModel(profile)
                        }
                        else {
                            AlertUtil.displayAlertOnVC(self, title: "Error in Updating Home", message: error?.localizedDescription ?? "")
                            DDLogError("Error in updating home: \(String(describing: success))")
                        }
                    }
                    else {
                        DDLogVerbose("addHomeDetails failed: \(String(describing: error))")
                        errorBlock(success, error)
                    }
                    
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                })
            })
        }
    }
    
    func addWorkDetails (_ location: YBLocation) {
        addWorkBtnOutlet.setTitle(location.name!, for: UIControlState())
        
        if location.name!.isEqual(YBClient.sharedInstance().profile?.workLocation?.name) {
            
        }
        else {
            WebInterface.makeWebRequestAndHandleError(
                self,
                webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                    
                ActivityIndicatorUtil.enableActivityIndicator(self.view)
                
                let client: BAAClient = BAAClient.shared()
                let dict = ["latitude":location.latitude!, "longitude":location.longitude!, "name":location.name!] as [String : Any]
                let dictionary = ["workLocation": dict]
                
                client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in
                    if let success = success {
                        let profileModel = Mapper<YBProfile>().map(JSONObject: success)
                        
                        if let profile = profileModel {
                            self.applyProfileModel(profile)
                        }
                        else {
                            AlertUtil.displayAlertOnVC(self, title: "Error in Updating Work", message: error?.localizedDescription ?? "")
                            DDLogError("Error in updating Work: \(String(describing: success))")
                        }
                    }
                    else {
                        DDLogVerbose("addWorkDetails failed: \(String(describing: error))")
                        errorBlock(success, error)
                    }
                    
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                })
            })
        }
    }
}

extension SettingsViewController: GMSAutocompleteViewControllerDelegate {
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        DDLogVerbose("Place name: \(place.name)")
        DDLogVerbose("Place address: \(String(describing: place.formattedAddress))")
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
                
                let client: BAAClient = BAAClient.shared()
                let dictionary = ["profilePicture": fileId]

                client.updateProfile(BAASBOX_RIDER_STRING, jsonBody: dictionary, completion:{(success, error) -> Void in

                    if let success = success {
                        let profileModel = Mapper<YBProfile>().map(JSONObject: success)
                        
                        if let profile = profileModel {
                            self.applyProfileModel(profile)
                            
                            // update UI here
                            self.profileImageViewOutlet.image = image
                            
                            // post notification to update the profile picture in other view controllers
                            postNotification(ProfileNotifications.profilePictureUpdated, value: "")
                        }
                        else {
                            AlertUtil.displayAlertOnVC(self, title: "Error in updating profile picture", message: error?.localizedDescription ?? "")
                            DDLogError("Error in updating profilepic: \(String(describing: success))")
                        }
                    }
                    else {
                        AlertUtil.displayAlertOnVC(self, title: "Error in updating profile picture", message: error?.localizedDescription ?? "")
                        DDLogVerbose("addHomeDetails failed: \(String(describing: error))")
                    }
                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                })
              },
              failure: { error in
                AlertUtil.displayAlertOnVC(self, title: "Upload failed", message: error.localizedDescription)
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
