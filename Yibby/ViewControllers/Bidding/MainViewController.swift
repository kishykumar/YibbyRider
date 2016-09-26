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
import BaasBoxSDK
import BButton
import CocoaLumberjack
import Braintree

// TODO:
// 1. Create bid state that we save on the app
// 2.
// 3. When bid timer expires on the app, save the state of the bid so that it doesn't conflict with the incoming push message.
// 4. 

public class MainViewController: BaseYibbyViewController,
                                UITextFieldDelegate,
                                DestinationDelegate,
                                CLLocationManagerDelegate {

    // MARK: - Properties
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
    @IBOutlet weak var rangeSliderOutlet: ASValueTrackingSlider!
    @IBOutlet weak var bidButton: YibbyButton1!
    @IBOutlet weak var cardLabelOutlet: UILabel!
    @IBOutlet weak var maxBidLabelOutlet: UILabel!
    @IBOutlet weak var priceSliderViewOutlet: YibbyBorderedUIView!
    @IBOutlet weak var miscPickerViewOutlet: YibbyBorderedUIView!
    @IBOutlet weak var peopleButtonOutlet: JOButtonMenu!
    @IBOutlet weak var peopleLabelOutlet: UILabel!
    @IBOutlet weak var cardHintOutlet: BTUICardHint!
    @IBOutlet weak var centerMarkersViewOutlet: YibbyBorderedUIView!
    
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
    
    var priceSliderViewHidden = false
    var miscPickerViewHidden = false
    
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    var selectedPaymentMethod: STPPaymentMethod?
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    var selectedPaymentMethod: BTPaymentMethodNonce?
    
#endif
    
    var responseHasArrived: Bool = false
    
    let NO_DRIVERS_FOUND_ERROR_CODE = 20099
    
    // MARK: - Actions
    
    @IBAction func leftSlideButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    @IBAction func onPaymentSelectAction(sender: UITapGestureRecognizer) {
        displaySelectCardView()
    }
    
    @IBAction func onDollarImageClickAction(sender: AnyObject) {
        
        if (priceSliderViewHidden) {
            priceSliderViewOutlet.animation = "fadeIn"
            priceSliderViewOutlet.animate()
            priceSliderViewHidden = false
        } else {
            priceSliderViewOutlet.animation = "fadeOut"
            priceSliderViewOutlet.animate()
            priceSliderViewHidden = true
        }
    }
    
    @IBAction func onMiscPickerImageClickAction(sender: AnyObject) {
        
        if (miscPickerViewHidden) {
            miscPickerViewOutlet.animation = "fadeIn"
            miscPickerViewOutlet.animate()
            miscPickerViewHidden = false
        } else {
            miscPickerViewOutlet.animation = "fadeOut"
            miscPickerViewOutlet.animate()
            miscPickerViewHidden = true
        }
    }
    
    @IBAction func onCenterMarkersButtonClick(sender: AnyObject) {
        adjustGMSCameraFocus()
    }
    
    @IBAction func onBidButtonClick(sender: AnyObject) {

        // Make sure user has a payment method selected
        if (self.selectedPaymentMethod == nil) {
            displaySelectCardView()
            return;
        }
        
        bidHigh = self.rangeSliderOutlet.value
        DDLogVerbose("bidHigh value is: \(bidHigh)")
        
        if (pickupLatLng != nil && pickupPlaceName != nil &&
            dropoffLatLng != nil && dropoffPlaceName  != nil &&
            bidLow != nil && bidHigh != nil) {
            
            DDLogVerbose("Made the bid: pickupLatLng: \(pickupLatLng), pickupPlaceName: \(pickupPlaceName), dropoffLatLng: \(dropoffLatLng), dropoffPlaceName: \(dropoffPlaceName),  bidLow: \(bidLow), bidHigh: \(bidHigh)")
            
            WebInterface.makeWebRequestAndHandleError(
                self,
                webRequest: {(errorBlock: (BAAObjectResultBlock)) -> Void in
                
                    ActivityIndicatorUtil.enableActivityIndicator(self.view)
                    
                    let client: BAAClient = BAAClient.sharedClient()
                    
                    client.createBid(self.bidHigh,
                        bidLow: self.bidLow, etaHigh: 0, etaLow: 0, pickupLat: self.pickupLatLng!.latitude,
                        pickupLong: self.pickupLatLng!.longitude, pickupLoc: self.pickupPlaceName,
                        dropoffLat: self.dropoffLatLng!.latitude, dropoffLong: self.dropoffLatLng!.longitude,
                        dropoffLoc: self.dropoffPlaceName, completion: {(success, error) -> Void in
                        
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        if (error == nil) {
                            // check the error codes
                            if let bbCode = success["bb_code"] as? String {
                                if (Int(bbCode) == self.NO_DRIVERS_FOUND_ERROR_CODE) {
                                    
                                    // TODO: display alert that no drivers are online
                                    AlertUtil.displayAlert("No drivers online.", message: "")
                                } else {
                                    AlertUtil.displayAlert("Unexpected error. Please be patient.", message: "")
                                    DDLogVerbose("Unexpected Error: success var: \(success)")
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
    
    // MARK: - Setup
    
    static func initMainViewController(vc: UIViewController, animated anim: Bool) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.sendGCMTokenToServer()

        appDelegate.initializeMainViewController()
        vc.presentViewController(appDelegate.centerContainer!, animated: anim, completion: nil)
    }
    
    func setupDelegates() {
        gmsMapViewOutlet.delegate = self
        peopleButtonOutlet.delegate = self
    }
    
    func setupUI() {
        // bidButton
        bidButton.color = UIColor.appDarkGreen1()
        bidButton.addAwesomeIcon(FAIcon.FAGavel, beforeTitle: true)
        
        // currency range slider
        setupRangeSliderUI()
        
        setupPersonsButtonMenuUI()
        
        setupNavigationBar()
        setStatusBarColor()

        // update card UI
        if let method = self.selectedPaymentMethod {
            updateSelectCardUI(method)
        }
    }
    
    func setupRangeSliderUI() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        let formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        self.rangeSliderOutlet.showPopUpViewAnimated(false)
        
        self.rangeSliderOutlet.maximumValue = 100
        self.rangeSliderOutlet.numberFormatter = formatter
        self.rangeSliderOutlet.setMaxFractionDigitsDisplayed(0)
        
        self.rangeSliderOutlet.font = UIFont.boldSystemFontOfSize(screenSize.size.height * 0.026)
        
        self.rangeSliderOutlet.popUpViewArrowLength = screenSize.size.height * 0.010
        
        self.rangeSliderOutlet.popUpViewAnimatedColors = [UIColor.redColor(),
                                                          UIColor.appDarkGreen1()]
        
        let thumbImage = UIImage(named: "defaultSlider")
        self.rangeSliderOutlet.setThumbImage(thumbImage, forState: UIControlState.Normal)
    }
    
    func setupPersonsButtonMenuUI() {
        
        peopleButtonOutlet.dataset = [
            JOButtonMenuOption(labelText: "1"),
            JOButtonMenuOption(labelText: "2"),
            JOButtonMenuOption(labelText: "3"),
            JOButtonMenuOption(labelText: "4")
        ]
    }
    
    func setupNavigationBar() {
        // set nav bar color
//        self.navigationController?.navigationBar.barTintColor = UIColor.appDarkGreen1()
//        self.navigationController?.navigationBar.tintColor = UIColor.appDarkGreen1()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        
        //MMDrawerBarButtonItem
        
        // RIGHT Bar Button Item
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "FontAwesome", size: 24.0)!,
            NSForegroundColorAttributeName: UIColor.blueColor()],
            forState: .Normal)
        
        self.navigationItem.rightBarButtonItem?.title =
            String.fa_stringForFontAwesomeIcon(FAIcon.FALightbulbO)
        
        self.navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(-5.0, 20.0),
                                                                           forBarMetrics: UIBarMetrics.Default)
        
        // LEFT Bar Button Item
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "FontAwesome", size: 24.0)!,
            NSForegroundColorAttributeName: UIColor.yellowColor()],
            forState: .Normal)
        
        self.navigationItem.leftBarButtonItem?.title =
            String.fa_stringForFontAwesomeIcon(FAIcon.FABars)
        
        self.navigationItem.leftBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(5.0, 20.0),
                                                                          forBarMetrics: UIBarMetrics.Default)
        
        // Set Title Font, Font size, Font color
//        self.navigationController!.navigationBar.titleTextAttributes = [
//            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
//            NSForegroundColorAttributeName : UIColor.whiteColor()
//        ]

//
//        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    func setStatusBarColor () {
        let app: UIApplication = UIApplication.sharedApplication()
        
        let statusBarView: UIView = UIView(frame:
            CGRectMake(0, -app.statusBarFrame.size.height,
                    self.view.bounds.size.width, app.statusBarFrame.size.height))
        
        statusBarView.backgroundColor = UIColor.appDarkGreen1()
        self.navigationController!.navigationBar.addSubview(statusBarView)
        
        // status bar text color
        UIApplication.sharedApplication().statusBarStyle = .LightContent
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
        
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
            
        self.selectedPaymentMethod = self.selectedPaymentMethod ??
                                    StripePaymentService.sharedInstance().defaultPaymentMethod
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE

        self.selectedPaymentMethod = self.selectedPaymentMethod ??
            BraintreePaymentService.sharedInstance().defaultPaymentMethod
    
#endif

    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // init properties *should* be called before any setup function
        initProperties()
        
        setupDelegates()
        setupUI()
        setupMap()
        setupMapClient()
        
        // check for location services
        AlertUtil.displayLocationAlert()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    // MARK: - Helpers
    
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
    
    func choseDestination(location: String) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setPickupDetails (address: String, loc: CLLocationCoordinate2D) {
        
        pickupMarker?.map = nil
        
        self.pickupPlaceName = address
        self.pickupLatLng = loc
        
        let pumarker = GMSMarker(position: loc)
        pumarker.map = gmsMapViewOutlet
        
        pumarker.icon = YibbyMapMarker.annotationImageWithMarker(pumarker,
                                                                 title: address,
                                                                 andPinIcon: UIImage(named: "defaultMarker")!,
                                                                 pickup: true)
        
        pickupMarker = pumarker
        adjustGMSCameraFocus()
    }
    
    func setDropoffDetails (address: String, loc: CLLocationCoordinate2D) {
        
        dropoffMarker?.map = nil
        
        self.dropoffPlaceName = address
        self.dropoffLatLng = loc
        
        let domarker = GMSMarker(position: loc)
        domarker.map = gmsMapViewOutlet
        
        //        domarker.icon = UIImage(named: "Visa")
        domarker.icon = YibbyMapMarker.annotationImageWithMarker(domarker,
                                                                 title: address,
                                                                 andPinIcon: UIImage(named: "defaultMarker")!,
                                                                 pickup: false)
        
        dropoffMarker = domarker
        adjustGMSCameraFocus()
    }
    
    func adjustGMSCameraFocus() {
        
        guard let pickupMarker = pickupMarker else {
            
            if let dropoffMarker = dropoffMarker {
                let update = GMSCameraUpdate.setTarget((dropoffMarker.position),
                                                       zoom: GMS_DEFAULT_CAMERA_ZOOM)
                gmsMapViewOutlet.moveCamera(update)
            }
            return
        }
        
        guard let dropoffMarker = dropoffMarker else {
            
            let update = GMSCameraUpdate.setTarget((pickupMarker.position),
                                                   zoom: GMS_DEFAULT_CAMERA_ZOOM)
            gmsMapViewOutlet.moveCamera(update)
            return
        }
        
        let bounds = GMSCoordinateBounds(coordinate: (pickupMarker.position),
                                         coordinate: (dropoffMarker.position))
        
        let centerMarkersRelativeOrigin: CGPoint =
            (centerMarkersViewOutlet.superview?.convertPoint(centerMarkersViewOutlet.frame.origin,
                toView: gmsMapViewOutlet))!
        
        let insets = UIEdgeInsets(top: self.topLayoutGuide.length + pickupMarker.icon.size.height,
                                  left: (pickupMarker.icon.size.width / 2) + 10.0,
                                  bottom: gmsMapViewOutlet.frame.height - centerMarkersRelativeOrigin.y,
                                  right: (pickupMarker.icon.size.width / 2) + 10.0)
        
        let update = GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: insets)
        gmsMapViewOutlet.moveCamera(update)
    }
    
    func setCurrentLocationDetails (address: String, loc: CLLocationCoordinate2D) {
        self.currentPlaceName = address
        self.currentPlaceLatLng = loc
    }
}

extension MainViewController: SelectPaymentViewControllerDelegate {
    // MARK: - SelectPaymentViewControllerDelegate
    
    func selectPaymentViewControllerDidCancel(selectPaymentViewController: PaymentViewController) {
//        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                    didSelectPaymentMethod method: STPPaymentMethod,
                                    controllerType: PaymentViewControllerType) {
        
        if (controllerType == PaymentViewControllerType.PickForRide) {
        
            // modify the selected payment method
            self.selectedPaymentMethod = method
            
            // remove the view controller
            self.navigationController!.popViewControllerAnimated(true)
    
            // update the card UI
            updateSelectCardUI(method)
        }
    }
    
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                     didSelectPaymentMethod method: BTPaymentMethodNonce,
                                                            controllerType: PaymentViewControllerType) {
        
        if (controllerType == PaymentViewControllerType.PickForRide) {
            
            // modify the selected payment method
            self.selectedPaymentMethod = method
            
            // remove the view controller
            self.navigationController!.popViewControllerAnimated(true)
            
            // update the card UI
            updateSelectCardUI(method)
        }
    }
    
    #endif
    
    func displaySelectCardView () {
        
        // Display the select card view
        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
        
        let selectPaymentViewController = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
        
        selectPaymentViewController.controllerType = PaymentViewControllerType.PickForRide
        selectPaymentViewController.delegate = self
        
        selectPaymentViewController.selectedPaymentMethod = self.selectedPaymentMethod
        
//        self.navigationController!.presentViewController(selectPaymentViewController, animated: true, completion: nil)
        self.navigationController!.pushViewController(selectPaymentViewController, animated: true)
    }
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    func updateSelectCardUI (paymentMethod: STPPaymentMethod) {
    
        if let card = paymentMethod as? STPCard {
            self.cardLabelOutlet.text = card.last4()
        } else {
            self.cardLabelOutlet.text = paymentMethod.label
        }
    }
    
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    func updateSelectCardUI (paymentMethod: BTPaymentMethodNonce) {
        
        
        let paymentMethodType: BTUIPaymentOptionType =
            BraintreeCardUtil.paymentMethodTypeFromBrand(paymentMethod.type)
        self.cardHintOutlet.setCardType(paymentMethodType, animated: false)
        self.cardLabelOutlet.text = paymentMethod.localizedDescription
        
        //        self.cardLabelOutlet.font = UIFont(name: "FontAwesome", size: 17)
        //        self.cardLabelOutlet.text = String(format: "%C", 0xf042)
    }
    
    #endif
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
    
    // User canceled the operation.
    public func wasCancelled(viewController: GMSAutocompleteViewController!) {
        cleanup()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cleanup () {
        pickupFieldSelected = false
        dropoffFieldSelected = false
    }
}

extension MainViewController: GMSMapViewDelegate {
    
    // MARK: - GMSMapViewDelegate
    public func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        if (marker == pickupMarker) {
            pickupFieldSelected = true
        }
        else if (marker == dropoffMarker) {
            dropoffFieldSelected = true
        }
        
        // This view controller lets a user pick address
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
        
        // default marker action is false, but we don't want that.
        return true
    }
}

extension MainViewController: JOButtonMenuDelegate {
    
    // MARK: - JOButtonMenuDelegate
    
    public func selectedOption(sender: JOButtonMenu, index: Int) {
        peopleLabelOutlet.text = peopleButtonOutlet.dataset[index].labelText
    }
    
    public func canceledAction(sender: JOButtonMenu) {
        print("User cancelled selection")
    }
}