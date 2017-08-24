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
import GooglePlaces
import ActionSheetPicker_3_0

// TODO:
// 1. Create bid state that we save on the app
// 2.
// 3. When bid timer expires on the app, save the state of the bid so that it doesn't conflict with the incoming push message.
// 4. 

class MainViewController: BaseYibbyViewController,
                                UITextFieldDelegate,
                                DestinationDelegate,
                                CLLocationManagerDelegate,
                                SelectPaymentViewControllerDelegate,
                                GMSAutocompleteViewControllerDelegate,
                                GMSMapViewDelegate,
                                JOButtonMenuDelegate {

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
    @IBOutlet weak var miscHintViewOutlet: UIView!
    @IBOutlet weak var dollarHintViewOutlet: UIView!
    
    
    var placesClient: GMSPlacesClient?
    let regionRadius: CLLocationDistance = 1000
    var pickupFieldSelected: Bool?
    var dropoffFieldSelected: Bool?
    
    var curLocation: YBLocation?
    
    var pickupLocation: YBLocation?
    var pickupMarker: GMSMarker?
    
    var dropoffLocation: YBLocation?
    var dropoffMarker: GMSMarker?
    
    var locationManager:CLLocationManager!
    let GMS_DEFAULT_CAMERA_ZOOM: Float = 14.0
    
    var bidHigh: Float?
    var numPeople: Int?
    
    var priceSliderViewHidden = false
    var miscPickerViewHidden = false
    
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    var selectedPaymentMethod: STPPaymentMethod?
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
    //var selectedPaymentMethod: BTPaymentMethodNonce?
    var selectedPaymentMethod: YBPaymentMethod?
    
#endif
    
    @IBAction func onDrawerSlideButtonClick(_ sender: UITapGestureRecognizer) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToMainViewController(_ segue:UIStoryboardSegue) {
        AlertUtil.displayAlert("Thanks for taking a ride with Yibby!", message: "Please come back.")
    }
    
    @IBAction func leftSlideButtonTapped(_ sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    @IBAction func onPaymentSelectAction(_ sender: UITapGestureRecognizer) {
        displaySelectCardView()
    }
    
    @IBAction func onDollarImageClickAction(_ sender: AnyObject) {
        
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
    
    @IBAction func onMiscPickerImageClickAction(_ sender: AnyObject) {
        
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
    
    @IBAction func onCenterMarkersButtonClick(_ sender: AnyObject) {
        adjustGMSCameraFocus()
    }
    
    @IBAction func onBidButtonClick(_ sender: AnyObject) {

        // TODO: REMOVE
//        let driverEnRouteStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.DriverEnRoute, bundle: nil)
//        
//        let derVC = driverEnRouteStoryboard.instantiateViewController(withIdentifier: "DriverEnRouteViewControllerIdentifier") as! DriverEnRouteViewController
//        self.navigationController?.pushViewController(derVC, animated: true)
//        return;
        ///////////////////////////        ///////////////////////////
        
        // Make sure user has a payment method selected
        if (self.selectedPaymentMethod == nil) {
            displaySelectCardView()
            return;
        }
        
        bidHigh = self.rangeSliderOutlet.value
        
        if (pickupLocation != nil &&
            dropoffLocation != nil && bidHigh != nil) {
            
            DDLogVerbose("Made the bid: pickupLoc: \(pickupLocation), dropoffLoc: \(dropoffLocation), bidHigh: \(bidHigh)")
            
            let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
            
            let confirmRideViewController = biddingStoryboard.instantiateViewController(withIdentifier: "ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
            
            // Initialize the view controller state 
            confirmRideViewController.bidHigh = self.bidHigh!
            confirmRideViewController.pickupLocation = self.pickupLocation!
            confirmRideViewController.dropoffLocation = self.dropoffLocation!
            confirmRideViewController.currentPaymentMethod = self.selectedPaymentMethod!
            confirmRideViewController.numPeople = self.numPeople!
            
            self.navigationController?.pushViewController(confirmRideViewController, animated: true)
        }
    }
    
    // MARK: - Setup
    
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
//        setStatusBarColor()
        setupMenuButton()

        // update card UI
        if let method = self.selectedPaymentMethod {
            updateSelectCardUI(paymentMethod: method)
        }
        
        // default number of people
        self.peopleLabelOutlet.text = "1"
        self.numPeople = 1
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    open override func updateViewConstraints() {
        super.updateViewConstraints()
        
    }
    
    func setupRangeSliderUI() {
        let screenSize: CGRect = UIScreen.main.bounds

        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        
        self.rangeSliderOutlet.showPopUpView(animated: false)
        
        self.rangeSliderOutlet.maximumValue = 100
        self.rangeSliderOutlet.numberFormatter = formatter
        self.rangeSliderOutlet.setMaxFractionDigitsDisplayed(0)
        
        self.rangeSliderOutlet.font = UIFont.boldSystemFont(ofSize: screenSize.size.height * 0.026)
        
        self.rangeSliderOutlet.popUpViewArrowLength = screenSize.size.height * 0.010
        
        self.rangeSliderOutlet.popUpViewAnimatedColors = [UIColor.red,
                                                          UIColor.appDarkGreen1()]
        
        let thumbImage = UIImage(named: "defaultSlider")
        self.rangeSliderOutlet.setThumbImage(thumbImage, for: UIControlState())
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
//        let app: UIApplication = UIApplication.shared

//        let image : UIImage? = UIImage.init(named: "menu_icon_green")!.withRenderingMode(.alwaysOriginal)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
//        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(app.statusBarFrame.size.height-4, -8, -(app.statusBarFrame.size.height-4), 8)
        
//        self.navigationController?.isNavigationBarHidden = true

        // set nav bar color
//        self.navigationController?.navigationBar.barTintColor = UIColor.appDarkGreen1()
//        self.navigationController?.navigationBar.tintColor = UIColor.appDarkGreen1()

        // Make nav bar transparent
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()

//        if let navigationController = self.navigationController {
        
            // RIGHT Bar Button Item
//            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
//                NSFontAttributeName: UIFont(name: "FontAwesome", size: 24.0)!,
//                NSForegroundColorAttributeName: UIColor.blue],
//                for: UIControlState())
//            
//            self.navigationItem.rightBarButtonItem?.title =
//                String.fa_string(forFontAwesomeIcon: FAIcon.FALightbulbO)
//            
//            self.navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(-5.0, 20.0),
//                                                                               for: UIBarMetrics.default)
//            
            // LEFT Bar Button Item
//            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
//                NSFontAttributeName: UIFont(name: "FontAwesome", size: 24.0)!,
//                NSForegroundColorAttributeName: UIColor.yellow],
//                for: UIControlState())
//            
//            self.navigationItem.leftBarButtonItem?.title =
//                String.fa_string(forFontAwesomeIcon: FAIcon.FABars)
//            
//            self.navigationItem.leftBarButtonItem?.setTitlePositionAdjustment(UIOffsetMake(5.0, 20.0),
//                                                                              for: UIBarMetrics.default)
        
        // Set Title Font, Font size, Font color
//        self.navigationController?.navigationBar.titleTextAttributes = [
//            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
//            NSForegroundColorAttributeName : UIColor.whiteColor()
//        ]

//
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
//        }
    }
    
    func setupMap () {
        gmsMapViewOutlet.isMyLocationEnabled = true
        
        // Very Important: DONT disable consume all gestures because it's needed for nav drawer with a map
        gmsMapViewOutlet.settings.consumesGesturesInView = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let curLocation = LocationService.sharedInstance().provideCurrentLocation() {
                DispatchQueue.main.async {
                    self.updateCurrentLocation(curLocation)
                }
            }
        }
    }

    func setupMapClient () {
        placesClient = GMSPlacesClient()
    }
    
    func initProperties() {
        bidHigh = 100
        
        self.setPickupDetails(YBLocation(lat: 37.531631, long: -122.263606, name: "420 Oracle Pkwy, Redwood City, CA 94065"))
        self.setDropoffDetails(YBLocation(lat: 37.787884, long: -122.407536, name: "Union Square, San Francisco"))
        
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
            
        self.selectedPaymentMethod = self.selectedPaymentMethod ??
                                    StripePaymentService.sharedInstance().defaultPaymentMethod
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE

        self.selectedPaymentMethod = YBClient.sharedInstance().defaultPaymentMethod
    
#endif

    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // init properties *should* be called before any setup function
        initProperties()
        
        setupDelegates()
        setupUI()
        setupMap()
        setupMapClient()
                
        // check for location services
//        AlertUtil.displayLocationAlert()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        // Moved the rounding circle code here because the circling wasn't happening correctly.
        // Please refer here for why this solution has been picked:
        // http://stackoverflow.com/questions/29685055/ios-frame-size-width-2-doesnt-produce-a-circle-on-every-device
        miscHintViewOutlet.setRoundedWithWhiteBorder()
        dollarHintViewOutlet.setRoundedWithWhiteBorder()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustGMSCameraFocus()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func getCurrentPlace(sender: UIButton) {
        
        placesClient?.currentPlace(callback: {
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
          //  self.nameLabel.text = "No current place"
            //self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
            }
        } as! GMSPlaceLikelihoodListCallback)
    }
    
    
    // MARK: - Helpers
    
    func updateCurrentLocation (_ userLocation: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) -> Void in
            
            if (error != nil) {
                DDLogWarn("Error is: \(String(describing: error))")
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
                        
                        let loc = YBLocation(coordinate: userLocation.coordinate, name: addressString)
                        
                        self.setCurrentLocationDetails(loc)
                        self.setPickupDetails(loc)
                        
                        DDLogVerbose("Address from location manager came out: \(addressString)")
                    }
                }
            }
        })
    }
    
    func choseDestination(_ location: String) {
        dismiss(animated: true, completion: nil)
    }
    
    func setCurrentLocationDetails (_ location: YBLocation) {
        self.curLocation = location
    }
    
    func setPickupDetails (_ location: YBLocation) {
        
        pickupMarker?.map = nil
        
        self.pickupLocation = location
        
        let pumarker = GMSMarker(position: location.coordinate())
        pumarker.map = gmsMapViewOutlet
        
        pumarker.icon = YibbyMapMarker.annotationImageWithMarker(pumarker,
                                                                 title: location.name!,
                                                                 type: .pickup)
        
        pickupMarker = pumarker
        adjustGMSCameraFocus()
    }
    
    func setDropoffDetails (_ location: YBLocation) {
        
        dropoffMarker?.map = nil
        
        self.dropoffLocation = location
        
        let domarker = GMSMarker(position: location.coordinate())
        domarker.map = gmsMapViewOutlet
        
        //        domarker.icon = UIImage(named: "Visa")
        domarker.icon = YibbyMapMarker.annotationImageWithMarker(domarker,
                                                                 title: location.name!,
                                                                 type: .dropoff)
        
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
            (centerMarkersViewOutlet.superview?.convert(centerMarkersViewOutlet.frame.origin,
                to: gmsMapViewOutlet))!
        
        let insets = UIEdgeInsets(top: self.topLayoutGuide.length + (pickupMarker.icon?.size.height)!,
                                  left: ((pickupMarker.icon?.size.width)! / 2) + 10.0,
                                  bottom: gmsMapViewOutlet.frame.height - centerMarkersRelativeOrigin.y,
                                  right: ((pickupMarker.icon?.size.width)! / 2) + 10.0)
        
        let update = GMSCameraUpdate.fit(bounds, with: insets)
        gmsMapViewOutlet.moveCamera(update)
    }

    // MARK: - SelectPaymentViewControllerDelegate
    
    func selectPaymentViewControllerDidCancel(_ selectPaymentViewController: PaymentsViewController) {
//        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    #if YIBBY_USE_STRIPE_PAYMENT_SERVICE
    
    func selectPaymentViewController(selectPaymentViewController: PaymentViewController,
                                    didSelectPaymentMethod method: STPPaymentMethod,
                                    controllerType: PaymentViewControllerType) {
        
        if (controllerType == PaymentViewControllerType.PickForRide) {
        
            // modify the selected payment method
            self.selectedPaymentMethod = method
            
            // remove the view controller
            self.navigationController?.popViewControllerAnimated(true)
    
            // update the card UI
            updateSelectCardUI(method)
        }
    }
    
    #elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE
    
//    func selectPaymentViewController(selectPaymentViewController: PaymentsViewController,
//                                     didSelectPaymentMethod method: BTPaymentMethodNonce,
//                                                            controllerType: PaymentsViewControllerType) {
//        
//        if (controllerType == PaymentsViewControllerType.pickForRide) {
//            
//            // modify the selected payment method
//            //self.selectedPaymentMethod = method
//            
//            // remove the view controller
//            self.navigationController?.popViewController(animated: true)
//            
//            // update the card UI
//           // updateSelectCardUI(paymentMethod: method)
//        }
//    }
    
    func selectPaymentViewController(selectPaymentViewController: PaymentsViewController,
                                     didSelectPaymentMethod method: YBPaymentMethod) {
        
//        if (controllerType == PaymentsViewControllerType.pickForRide) {
        
            // modify the selected payment method
            self.selectedPaymentMethod = method
            
            // remove the view controller
            self.navigationController?.popViewController(animated: true)
            
            // update the card UI
            updateSelectCardUI(paymentMethod: method)
//        }
    }
    #endif
    
    func displaySelectCardView () {
        
        // Display the select card view
        let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
        
        let selectPaymentViewController = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentsViewControllerIdentifier") as! PaymentsViewController
        
        selectPaymentViewController.controllerType = PaymentsViewControllerType.pickForRide
        selectPaymentViewController.delegate = self
        
        selectPaymentViewController.selectedPaymentMethod = self.selectedPaymentMethod
        
//        self.navigationController?.presentViewController(selectPaymentViewController, animated: true, completion: nil)
        self.navigationController?.pushViewController(selectPaymentViewController, animated: true)        
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
    
    func updateSelectCardUI (paymentMethod: YBPaymentMethod) {
        
        
        let paymentMethodType: BTUIPaymentOptionType =
            BraintreeCardUtil.paymentMethodTypeFromBrand(paymentMethod.type)
        self.cardHintOutlet.setCardType(paymentMethodType, animated: false)
        self.cardLabelOutlet.text = paymentMethod.last4
        
        //        self.cardLabelOutlet.font = UIFont(name: "FontAwesome", size: 17)
        //        self.cardLabelOutlet.text = String(format: "%C", 0xf042)
    }
    
    #endif

    // MARK: - GMSAutocompleteViewControllerDelegate
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        DDLogVerbose("Place name: \(place.name)")
        DDLogVerbose("Place address: \(String(describing: place.formattedAddress))")
        DDLogVerbose("Place attributions: (place.attributions)")
        
        let loc = YBLocation(coordinate: place.coordinate, name: place.formattedAddress!)

        if (pickupFieldSelected == true) {
            self.setPickupDetails(loc)
        } else if (dropoffFieldSelected == true) {
            self.setDropoffDetails(loc)
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
        pickupFieldSelected = false
        dropoffFieldSelected = false
    }

    // MARK: - GMSMapViewDelegate
    
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if (marker == pickupMarker) {
            pickupFieldSelected = true
        }
        else if (marker == dropoffMarker) {
            dropoffFieldSelected = true
        }
        
        // This view controller lets a user pick address
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
        
        // default marker action is false, but we don't want that.
        return true
    }

    // MARK: - JOButtonMenuDelegate
    
    public func selectedOption(_ sender: JOButtonMenu, index: Int) {
        peopleLabelOutlet.text = peopleButtonOutlet.dataset[index].labelText
        self.numPeople = Int(peopleLabelOutlet.text!)
    }
    
    public func canceledAction(_ sender: JOButtonMenu) {
        print("User cancelled selection")
    }
}
