//
//  ViewController.swift
//  Example
//
//  Created by Kishy Kumar on 1/9/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class MainViewController: UIViewController, UITextFieldDelegate, DestinationDelegate {

    // MARK: Properties
    @IBOutlet weak var pickupFieldOutlet: UITextField!
    @IBOutlet weak var dropoffFieldOutlet: UITextField!
    @IBOutlet weak var mapViewOutlet: MKMapView!

    // Instantiate a pair of UILabels in Interface Builder
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var placesClient: GMSPlacesClient?
    let regionRadius: CLLocationDistance = 1000
    var pickupFieldSelected: Bool?
    var dropoffFieldSelected: Bool?
    
    // MARK: Functions
    func setupUI () {
        let imageView = UIImageView();
        
        // Set the size of the icon
        imageView.frame = CGRect(x: 5, y: 0, width: pickupFieldOutlet.frame.height - 1, height: pickupFieldOutlet.frame.height - 1);
        
        let image = UIImage(named: "destTextFieldIcon.png");
        imageView.image = image;
        pickupFieldOutlet.leftView = imageView;
        pickupFieldOutlet.leftViewMode = UITextFieldViewMode.Always;
        
        
        let imageView1 = UIImageView();
        imageView1.frame = CGRect(x: 5, y: 0, width: dropoffFieldOutlet.frame.height - 1, height: dropoffFieldOutlet.frame.height - 1);
        
        let image1 = UIImage(named: "destTextFieldIcon.png");
        imageView1.image = image1;
        dropoffFieldOutlet.leftView = imageView1;
        dropoffFieldOutlet.leftViewMode = UITextFieldViewMode.Always;
    }
    
    
    func setupMap () {
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(initialLocation)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapViewOutlet.setRegion(coordinateRegion, animated: true)
    }
    
    func setupMapClient () {
        placesClient = GMSPlacesClient()
    }
    
    // BaasBox create user
    func createUser() {
        let client: BAAClient = BAAClient.sharedClient()
        client.createUserWithUsername("cesare", password: "password", completion: {(success, error) -> Void in
            if (success) {
                NSLog("created user %@", client)
            }
            else {
                NSLog("error creating user %@", error)
            }
        })
    }
    
    func retrieveUserCredentials() {
//        let retrievedLoginToken:String = KeychainWrapper.stringForKey(LoginViewController.LOGIN_TOKEN_KEY_NAME)!
    }
    
//    func uploadFile() {
//        var imgPath: NSURL = NSBundle.mainBundle()(URLForResource: "baasbox", withExtension: "png")
//        var stringPath: String = imgPath.absoluteString()
//        var data: NSData = NSData.dataWithContentsOfURL(NSURL(string: stringPath)!)
//        var myLocalFile: BAAFile = BAAFile(data: data)
//        myLocalFile.contentType = "image/png"
//        myLocalFile.uploadFileWithPermissions(nil, completion: {(file: BAAFile, error: NSError) -> Void in
//            if error == nil {
//                NSLog("file uploaded %@", file)
//            }
//            else {
//                NSLog("error in uploading file %@", error)
//            }
//        })
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        setupMap()
        setupMapClient()
        
        retrieveUserCredentials()
        
        // Baasbox related initialization
//        createUser()

        pickupFieldOutlet.delegate = self
        dropoffFieldOutlet.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
//        performSegueWithIdentifier("loginSegue", sender: self)
        
//        let loginViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewControllerIdentifier") as? LoginViewController
//        
//        self.navigationController?.pushViewController(loginViewControllerObejct!, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // check login
        
        let client: BAAClient = BAAClient.sharedClient()
        if client.isAuthenticated() {
            print("User already logged in")
        } else {
            print("User NOT logged in. Going to login now.")
            client.authenticateUser("cesare", password: "password", completion: {( success, error) -> Void in
                
                if (success) {
                    print("Success logging in.")
                } else {
                    print("Error logging in - \(error)")
                }
            })
        }
        
    }
    
    // The pickup and dropoff textfields should not pop up a keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField == pickupFieldOutlet) {
            pickupFieldSelected = true
        }
        else {
            dropoffFieldSelected = true
        }
        
        // This view controller lets a user pick address
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
        
        
//        let destinationPickerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("destinationPickerViewControllerId") as! DestinationPickerViewController
//        destinationPickerViewController.delegate = self
//        presentViewController(destinationPickerViewController, animated: true, completion: nil)
        
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func choseDestination(location: String) {
        self.nameLabel.text = "Where Ya At"
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func getCurrentPlace(sender: UIButton) {
        
        placesClient?.currentPlaceWithCallback({
        (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress.componentsSeparatedByString(", ")
                        .joinWithSeparator("\n")
                }
            }
        })
    }
}

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {

        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        if (pickupFieldSelected == true) {
            self.pickupFieldOutlet.text = place.formattedAddress
        } else if (dropoffFieldSelected == true) {
            self.dropoffFieldOutlet.text = place.formattedAddress
        }
        
        cleanup()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        // TODO: handle the error.
        print("Error: ", error.description)
        cleanup()
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController!) {
        print("KISHYKUM_DBG_cancelled")
        cleanup()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cleanup () {
        pickupFieldSelected = false
        dropoffFieldSelected = false
    }
}
