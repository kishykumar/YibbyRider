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
import CocoaLumberjack

// TODO:
// 1. Create bid state that we save on the app
// 2.
// 3. When bid timer expires on the app, save the state of the bid so that it doesn't conflict with the incoming push message. 
// 4. 

public class MainViewController: UIViewController, UITextFieldDelegate, DestinationDelegate, CLLocationManagerDelegate, TTRangeSliderDelegate {

    // MARK: Properties
    @IBOutlet weak var pickupFieldOutlet: UITextField!
    @IBOutlet weak var dropoffFieldOutlet: UITextField!
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var bidButton: BButton!
    
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
            
            DDLogVerbose("Made the bid: pickupLatLng: \(pickupLatLng), pickupPlaceName: \(pickupPlaceName), dropoffLatLng: \(dropoffLatLng), dropoffPlaceName: \(dropoffPlaceName),  bidLow: \(bidLow), bidHigh: \(bidHigh)")
            
            WebInterface.makeWebRequestAndHandleError(
                self,
                webRequest: {(errorBlock: (BAAObjectResultBlock)) -> Void in
                
                    ActivityIndicatorUtil.enableActivityIndicator(self.view)
                    
                    let client: BAAClient = BAAClient.sharedClient()
                    
                    client.createBid(self.bidHigh, bidLow: self.bidLow, etaHigh: 0, etaLow: 0, pickupLat: self.pickupLatLng!.latitude, pickupLong: self.pickupLatLng!.longitude, pickupLoc: self.pickupPlaceName, dropoffLat: self.dropoffLatLng!.latitude, dropoffLong: self.dropoffLatLng!.longitude, dropoffLoc: self.dropoffPlaceName, completion: {(success, error) -> Void in
                        
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if (error == nil) {
                            // check the error codes
                            if let bbCode = success["bb_code"] as? String {
                                if (Int(bbCode) == self.NO_DRIVERS_FOUND_ERROR_CODE) {
                                    
                                    // TODO: display alert that no drivers are online
                                    AlertUtil.displayAlert("No drivers online.", message: "")
                                } else {
                                    AlertUtil.displayAlert("Unexpected error. Please be patient.", message: "")
                                }
                            } else {
                                
                                if let successData = success["data"] as? [String: NSObject] {
                                    
                                    // set the bid state
                                    
                                    let userBid: Bid = Bid(id: successData["id"] as! String,
                                        bidHigh: successData["bidHigh"] as! Int,
                                        bidLow: successData["bidLow"] as! Int,
                                        etaHigh: successData["etaHigh"] as! Int,
                                        etaLow: successData["etaLow"] as! Int,
                                        pickupLat: successData["pickupLat"] as! Double,
                                        pickupLong: successData["pickupLong"] as! Double,
                                        pickupLoc: successData["pickupLoc"] as! String,
                                        dropoffLat: successData["dropoffLat"] as! Double,
                                        dropoffLong: successData["dropoffLong"] as! Double,
                                        dropoffLoc: successData["dropoffLoc"] as! String)!
                                    
                                    BidState.sharedInstance().setOngoingBid(userBid)
                                    
                                    self.performSegueWithIdentifier("findOffersSegue", sender: nil)
                                } else {
                                    AlertUtil.displayAlert("Unexpected error. Please be patient.", message: "")
                                }
                            }
                        }
                        else {
                            errorBlock(success, error)
                        }
                        self.responseHasArrived = true
                    })
            })
        }
    }
    
    public func rangeSlider(sender: TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        if sender == self.rangeSlider {
            self.bidLow = selectedMinimum
            self.bidHigh = selectedMaximum
            DDLogVerbose("Standard slider updated. Min Value: %.0f Max Value: %.0f \(selectedMinimum), \(selectedMaximum)")
        }
    }
    
    func setupUI () {

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

    func updateCurrentLocation (userLocation: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
            
            if (error != nil) {
                DDLogWarn("Error is: \(error)")
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
                        
                        DDLogVerbose("Address from location manager came out: \(addressString)")
                    }
                }
            }
        })
    }
    
    func setupMap () {
        gmsMapViewOutlet.myLocationEnabled = true
        
        // Very Important: DONT disable consume all gestures, needed for nav drawer with a map
        gmsMapViewOutlet.settings.consumesGesturesInView = true
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)) {
            
            if let curLocation = LocationService.sharedInstance().provideCurrentLocation() {
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateCurrentLocation(curLocation)
                }
            }
        }
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
        let lat: CLLocationDegrees = 37.531631
        let long: CLLocationDegrees = -122.263606
        
        let latLng: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
        
        self.setPickupDetails("420 Oracle Pkwy, Redwood City, CA 94065", loc: latLng)
        
        let dlat: CLLocationDegrees = 37.348209
        let dlong: CLLocationDegrees = -121.993756
        
        let dlatLng: CLLocationCoordinate2D = CLLocationCoordinate2DMake(dlat,dlong)
        self.setDropoffDetails("3500 Granada Ave, Santa Clara, CA 95051", loc: dlatLng)
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
        AlertUtil.displayLocationAlert()
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

        DDLogVerbose("Place name: \(place.name)")
        DDLogVerbose("Place address: \(place.formattedAddress)")
        DDLogVerbose("Place attributions: (place.attributions)")
        
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
        DDLogWarn("Error: \(error.description)")
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