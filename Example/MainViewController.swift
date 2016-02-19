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
import MMDrawerController

class MainViewController: UIViewController, UITextFieldDelegate, DestinationDelegate, CLLocationManagerDelegate {

    // MARK: Properties
    @IBOutlet weak var pickupFieldOutlet: UITextField!
    @IBOutlet weak var dropoffFieldOutlet: UITextField!
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    

    var placesClient: GMSPlacesClient?
    let regionRadius: CLLocationDistance = 1000
    var pickupFieldSelected: Bool?
    var dropoffFieldSelected: Bool?
    
    var currentPlaceLatLng: CLLocation?
    var currentPlaceName: String?
    
    var pickupLatLng: CLLocation?
    var pickupPlaceName: String?

    var dropoffLatLng: CLLocation?
    var dropoffPlaceName: String?
    
    var locationManager:CLLocationManager!

    // MARK: Functions
    @IBAction func leftSlideButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
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
    
    func setupLocationManager () {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        gmsMapViewOutlet.myLocationEnabled = true
        gmsMapViewOutlet.settings.myLocationButton = true
        
        // Very Important: disable consume all gestures, needed for nav drawer
        gmsMapViewOutlet.settings.consumesGesturesInView = false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let userLocation:CLLocation = locations.first {
            
            gmsMapViewOutlet.camera = GMSCameraPosition(target: userLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            
            CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
                
                if (error != nil) {
                    print(error)
                } else {
                    if let validPlacemark = placemarks?[0] {
                        if let placemark = validPlacemark as? CLPlacemark {
                            var addressString : String = ""

                            if placemark.subThoroughfare != nil {
                                addressString = placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                addressString = addressString + placemark.thoroughfare! + ", "
                            }
                            if placemark.locality != nil {
                                addressString = addressString + placemark.locality! + ", "
                            }
                            if placemark.administrativeArea != nil {
                                addressString = addressString + placemark.administrativeArea! + " "
                            }
                            if placemark.postalCode != nil {
                                addressString = addressString + placemark.postalCode! + ", "
                            }
                            if placemark.country != nil {
                                addressString = addressString + placemark.country!
                            }

                            self.setCurrentLocationDetails(addressString, lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
                            self.setPickupDetails(addressString, lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
                            
                            print (addressString)
                        }
                    }
                }
            })
            
            // we just need the user's location one time
            locationManager.stopUpdatingLocation()
        }
    }
    
    func setupMap () {
        setupLocationManager()
    }

    func setupMapClient () {
        placesClient = GMSPlacesClient()
    }
    
    // BaasBox create user
//    func createUser() {
//        let client: BAAClient = BAAClient.sharedClient()
//        client.createUserWithUsername("cesare", password: "password", completion: {(success, error) -> Void in
//            if (success) {
//                NSLog("created user %@", client)
//            }
//            else {
//                NSLog("error creating user %@", error)
//            }
//        })
//    }
  
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setPickupDetails (address: String, lat: CLLocationDegrees, lng: CLLocationDegrees) {
        self.pickupFieldOutlet.text = address
        self.pickupPlaceName = address
        self.pickupLatLng = CLLocation(latitude: lat, longitude: lng)
    }

    func setDropoffDetails (address: String, lat: CLLocationDegrees, lng: CLLocationDegrees) {
        self.dropoffFieldOutlet.text = address
        self.dropoffPlaceName = address
        self.dropoffLatLng = CLLocation(latitude: lat, longitude: lng)
    }
    
    func setCurrentLocationDetails (address: String, lat: CLLocationDegrees, lng: CLLocationDegrees) {
        self.currentPlaceName = address
        self.currentPlaceLatLng = CLLocation(latitude: lat, longitude: lng)
    }
    
    // MARK: Actions
    /*
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
    */
}

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {

        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        if (pickupFieldSelected == true) {
            self.setPickupDetails(place.formattedAddress, lat: place.coordinate.latitude, lng: place.coordinate.longitude)
        } else if (dropoffFieldSelected == true) {
            self.setDropoffDetails(place.formattedAddress, lat: place.coordinate.latitude, lng: place.coordinate.longitude)
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
        cleanup()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cleanup () {
        pickupFieldSelected = false
        dropoffFieldSelected = false
    }
}
