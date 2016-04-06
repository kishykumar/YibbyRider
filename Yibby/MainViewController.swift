//
//  ViewController.swift
//  Example
//
//  Created by Kishy Kumar on 1/9/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import MMDrawerController
import TTRangeSlider
import BaasBoxSDK
import BButton

public class MainViewController: UIViewController, UITextFieldDelegate, DestinationDelegate, CLLocationManagerDelegate, TTRangeSliderDelegate {

    // MARK: Properties
    @IBOutlet weak var pickupFieldOutlet: UITextField!
    @IBOutlet weak var dropoffFieldOutlet: UITextField!
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var bidButton: BButton!

    let ACTIVITY_INDICATOR_TAG: Int = 1
    
    var placesClient: GMSPlacesClient?
    let regionRadius: CLLocationDistance = 1000
    var pickupFieldSelected: Bool?
    var dropoffFieldSelected: Bool?
    
    var currentPlaceLatLng: CLLocationCoordinate2D?
    var currentPlaceName: String?
    
    var pickupLatLng: CLLocationCoordinate2D?
    var pickupPlaceName: String?
    var pickupMarker: GMSMarker?
    
    var dropoffLatLng: CLLocationCoordinate2D?
    var dropoffPlaceName: String?
    var dropoffMarker: GMSMarker?
    
    var locationManager:CLLocationManager!
    let GMS_DEFAULT_CAMERA_ZOOM: Float = 14.0
    
    var bidLow: Float?
    var bidHigh: Float?
    
    var responseHasArrived: Bool = false
    
    let NO_DRIVERS_FOUND_ERROR_CODE = 20099
    
    // UI Elements
    let NAV_BAR_COLOR_CODE = 0xc6433b
    
    // MARK: Functions
    @IBAction func leftSlideButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    @IBAction func onBidButtonClick(sender: AnyObject) {
        
        if (pickupLatLng != nil && pickupPlaceName != nil &&
            dropoffLatLng != nil && dropoffPlaceName  != nil &&
            bidLow != nil && bidHigh != nil) {
                
            Util.enableActivityIndicator(self.view, tag: ACTIVITY_INDICATOR_TAG)
                
            let client: BAAClient = BAAClient.sharedClient()
                
            client.createBid(bidHigh, bidLow: bidLow, etaHigh: 0, etaLow: 0, pickupLat: pickupLatLng!.latitude, pickupLong: pickupLatLng!.longitude, pickupLoc: pickupPlaceName, dropoffLat: dropoffLatLng!.latitude, dropoffLong: dropoffLatLng!.longitude, dropoffLoc: dropoffPlaceName, completion: {(success, error) -> Void in

                Util.disableActivityIndicator(self.view, tag: self.ACTIVITY_INDICATOR_TAG)
                if (error == nil) {
                    
                    // check the error codes
                    if let bbCode = success["bb_code"] as? String {
                        if (Int(bbCode) == self.NO_DRIVERS_FOUND_ERROR_CODE) {
                            
                            // TODO: display alert that no drivers are online
                            Util.displayAlert("No drivers online.", message: "")
                        } else {
                            Util.displayAlert("Unexpected error. Please be patient.", message: "")
                        }
                    } else {
                        self.performSegueWithIdentifier("findOffersSegue", sender: nil)
                    }
                }
                else {
                    print("error creating bid \(error)")
                    // check if error is 401 (authentication) and re-authenticate
                }
                self.responseHasArrived = true
            })
        }
    }
    
    public func rangeSlider(sender: TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        if sender == self.rangeSlider {
            self.bidLow = selectedMinimum
            self.bidHigh = selectedMaximum
            NSLog("Standard slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum)
        }
    }
    
    func setupUI () {
//        let imageView = UIImageView();
//        
//        // Set the size of the icon
//        imageView.frame = CGRect(x: 5, y: 0, width: pickupFieldOutlet.frame.height - 1, height: pickupFieldOutlet.frame.height - 1);
//        
//        let image = UIImage(named: "destTextFieldIcon.png");
//        imageView.image = image;
//        pickupFieldOutlet.leftView = imageView;
//        pickupFieldOutlet.leftViewMode = UITextFieldViewMode.Always;
        
        
//        let imageView1 = UIImageView();
//        imageView1.frame = CGRect(x: 5, y: 0, width: dropoffFieldOutlet.frame.height - 1, height: dropoffFieldOutlet.frame.height - 1);
//        
//        let image1 = UIImage(named: "destTextFieldIcon.png");
//        imageView1.image = image1;
//        dropoffFieldOutlet.leftView = imageView1;
//        dropoffFieldOutlet.leftViewMode = UITextFieldViewMode.Always;
        
        // currency range slider
        self.rangeSlider.delegate = self
        let formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        self.rangeSlider.numberFormatterOverride = formatter

        setNavigationBarColor()
        setStatusBarColor()
    }
    
    func setNavigationBarColor () {
        // set nav bar color
        self.navigationController!.navigationBar.barTintColor = UIColor(netHex: NAV_BAR_COLOR_CODE)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.translucent = false
        
        // Set Title Font, Font size, Font color
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]

//
//        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.            whiteColor()]
    }
    
    func setStatusBarColor () {
        let app: UIApplication = UIApplication.sharedApplication()
        
        let statusBarView: UIView = UIView(frame:
            CGRectMake(0, -app.statusBarFrame.size.height,
                    self.view.bounds.size.width, app.statusBarFrame.size.height))
        
        statusBarView.backgroundColor = UIColor.yellowColor()
        self.navigationController!.navigationBar.addSubview(statusBarView)
        
        // status bar text color
//        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    func setupLocationManager () {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        gmsMapViewOutlet.myLocationEnabled = true
        gmsMapViewOutlet.settings.myLocationButton = true
        
        // Very Important: DONT disable consume all gestures, needed for nav drawer with a map
        gmsMapViewOutlet.settings.consumesGesturesInView = true
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let userLocation:CLLocation = locations.first {
            
            // adjust the camera focus
//            gmsMapViewOutlet.camera = GMSCameraPosition(target: userLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
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

                            self.setCurrentLocationDetails(addressString, loc: userLocation.coordinate)
                            self.setPickupDetails(addressString, loc: userLocation.coordinate)
                            
                            print ("Address form location manager came out: \(addressString)")
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
    
    func initProperties() {
        bidLow = 1
        bidHigh = 100
        let lat: CLLocationDegrees = -23.527096772791133
        let long: CLLocationDegrees = -46.48964569157911
        
        let latLng: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
        
        pickupLatLng = latLng
        pickupPlaceName = "pickup"
        dropoffLatLng = latLng
        dropoffPlaceName = "dropoff"
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        setupMap()
        setupMapClient()
        initProperties()
        
        pickupFieldOutlet.delegate = self
        dropoffFieldOutlet.delegate = self
        
        // check for location services
        Util.displayLocationAlert()
    }
    
    override public func viewDidAppear(animated: Bool) {
//        performSegueWithIdentifier("loginSegue", sender: self)
        
//        let loginViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewControllerIdentifier") as? LoginViewController
//        
//        self.navigationController?.pushViewController(loginViewControllerObejct!, animated: true)

    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // The pickup and dropoff textfields should not pop up a keyboapublic rd
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
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
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func choseDestination(location: String) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setPickupDetails (address: String, loc: CLLocationCoordinate2D) {
        
        pickupMarker?.map = nil
        
        self.pickupFieldOutlet.text = address
        self.pickupPlaceName = address
        self.pickupLatLng = loc
        
        let pumarker = GMSMarker(position: loc)
        pumarker.map = gmsMapViewOutlet
        pickupMarker = pumarker
        adjustGMSCameraFocus()
    }

    func setDropoffDetails (address: String, loc: CLLocationCoordinate2D) {

        dropoffMarker?.map = nil
        
        self.dropoffFieldOutlet.text = address
        self.dropoffPlaceName = address
        self.dropoffLatLng = loc
        
        let domarker = GMSMarker(position: loc)
        domarker.map = gmsMapViewOutlet
        dropoffMarker = domarker
        adjustGMSCameraFocus()
    }
    
    func adjustGMSCameraFocus () {
        
        if (pickupMarker == nil) {
            let update = GMSCameraUpdate.setTarget((dropoffMarker?.position)!)
            gmsMapViewOutlet.moveCamera(update)
            return
        }
        
        if (dropoffMarker == nil) {
            let update = GMSCameraUpdate.setTarget((pickupMarker?.position)!, zoom: GMS_DEFAULT_CAMERA_ZOOM)
            gmsMapViewOutlet.moveCamera(update)
            return
        }
        
        let bounds = GMSCoordinateBounds(coordinate: (pickupMarker?.position)!, coordinate: (dropoffMarker?.position)!)
        let insets = UIEdgeInsets(top: 140.0, left: 64.0, bottom: 140.0, right: 64.0)
        let update = GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: insets)
        gmsMapViewOutlet.moveCamera(update)
    }
    
    func setCurrentLocationDetails (address: String, loc: CLLocationCoordinate2D) {
        self.currentPlaceName = address
        self.currentPlaceLatLng = loc
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
    
    // Handle the user's selectiopublic public public n.
    public func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {

        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        if (pickupFieldSelected == true) {
            self.setPickupDetails(place.formattedAddress, loc: place.coordinate)
        } else if (dropoffFieldSelected == true) {
            self.setDropoffDetails(place.formattedAddress, loc: place.coordinate)
        }
        
        cleanup()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        // TODO: handle the error.
        print("Error: ", error.description)
        cleanup()
    }
    
    // User canceled the operatiopublic public n.
    public func wasCancelled(viewController: GMSAutocompleteViewController!) {
        cleanup()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cleanup () {
        pickupFieldSelected = false
        dropoffFieldSelected = false
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}