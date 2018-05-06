//
//  MainViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 1/9/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import GoogleMaps
import MMDrawerController
import BButton
import CocoaLumberjack
import Braintree
import GooglePlaces
import ActionSheetPicker_3_0
import BaasBoxSDK
import ObjectMapper

// TODO:
// 1. Don't let user bid for 5 mins
// 2.
// 3.
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
    
    var selectedPaymentMethod: YBPaymentMethod?
    
#endif
    
    fileprivate var offerRejectedObserver: NotificationObserver? // for offer reject
    fileprivate var rideObserver: NotificationObserver? // for driver en route message
    
    // MARK: - Actions
    
    @IBAction func unwindToMainViewController(_ segue:UIStoryboardSegue) {
        
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
    
    @IBAction func onBidButtonClick(_ sender: AnyObject) {

        // Make sure user has a payment method selected
        if (self.selectedPaymentMethod == nil) {
            displaySelectCardView()
            return;
        }
        
        let bidHighInt = Int(self.rangeSliderOutlet.value)
        bidHigh = Float(bidHighInt)
        
        if (pickupLocation != nil &&
            dropoffLocation != nil && bidHigh != nil) {
            
            DDLogVerbose("Going to bid: pickupLoc: \(String(describing: pickupLocation)), dropoffLoc: \(String(describing: dropoffLocation)), bidHigh: \(String(describing: bidHigh))")
            
            let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
            let confirmRideViewController = biddingStoryboard.instantiateViewController(withIdentifier: "ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
            
            // Initialize the view controller state 
            confirmRideViewController.bidHigh = self.bidHigh!
            confirmRideViewController.pickupLocation = self.pickupLocation!
            confirmRideViewController.dropoffLocation = self.dropoffLocation!
            confirmRideViewController.currentPaymentMethod = self.selectedPaymentMethod!
            confirmRideViewController.numPeople = self.numPeople!
            
            // if an alert was already displayed, dismiss it
            if let presentedVC = self.presentedViewController {
                if (presentedVC.isMember(of: UIAlertController.self)) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
            
            let navController = UINavigationController(rootViewController: confirmRideViewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
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
        
        self.setPickupDetails(YBLocation(lat: 37.422094, long: -122.084068, name: "Googleplex, Amphitheatre Parkway, Mountain View, CA"))
        self.setDropoffDetails(YBLocation(lat: 37.430033, long: -122.173335, name: "Stanford Computer Science Department"))
                
#if YIBBY_USE_STRIPE_PAYMENT_SERVICE
            
        self.selectedPaymentMethod = self.selectedPaymentMethod ??
                                    StripePaymentService.sharedInstance().defaultPaymentMethod
    
#elseif YIBBY_USE_BRAINTREE_PAYMENT_SERVICE

        self.selectedPaymentMethod = YBClient.sharedInstance().defaultPaymentMethod
    
#endif

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        DDLogVerbose("Fired init")
        setupNotificationObservers()
    }
    
    deinit {
        DDLogVerbose("Fired deinit")
        removeNotificationObservers()
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
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustGMSCameraFocus()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications
    
    fileprivate func removeNotificationObservers() {
        
        offerRejectedObserver?.removeObserver()
        rideObserver?.removeObserver()
    }
    
    fileprivate func setupNotificationObservers() {
        
        offerRejectedObserver = NotificationObserver(notification: BidNotifications.noOffers) { [unowned self] bid in
            
            YBClient.sharedInstance().status = .looking

            // Clear the locally persisted bid
            YBClient.sharedInstance().bid = nil
            AlertUtil.displayAlertOnVC(self, title: "No offers from drivers.",
                                   message: "Your bid was not accepted by any driver",
                                   completionBlock: {() -> Void in
                                    self.dismiss(animated: true, completion: nil)
            })
        }
        
        rideObserver = NotificationObserver(notification: RideNotifications.driverEnRoute) { [unowned self] ride in
            
            YBClient.sharedInstance().status = .driverEnRoute

            // Successful ride, save it. We only update the ride object during driver_en_route, and not during driverArrived/rideStart/End
            YBClient.sharedInstance().ride = ride
            
            // dismiss the currently presented offerViewController
            self.dismiss(animated: true, completion: nil)

            let rideStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Ride, bundle: nil)
            let rideViewController = rideStoryboard.instantiateViewController(withIdentifier: "RideViewControllerIdentifier") as! RideViewController
            rideViewController.controllerState = .driverEnRoute
            self.navigationController?.pushViewController(rideViewController, animated: true)
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func getNearestDriverEta(loc: YBLocation) {
   
        let client: BAAClient = BAAClient.shared()
        client.getNearestDriverEta(["latitude": loc.latitude!, "longitude": loc.longitude!],
            completion: {(success, error) -> Void in
                
                if (error == nil && success != nil) {
                    
                    let loadedEtas = Mapper<DriverEta>().mapArray(JSONObject: success)
                    if let loadedEtas = loadedEtas {
                        
                        var lowestEta: Int = Int.max // seconds
                        for item in loadedEtas {
                            if let eta = item.eta {
                                if (eta < lowestEta) {
                                    lowestEta = eta
                                }
                            }
                        }
                        
                        DDLogVerbose("KKDBG_getNearestDriverEta \(lowestEta)")
                    }
                } else {
                    DDLogVerbose("Error in getNearestDriverEta \(error)")
                }
        })
    }
    
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
    
    internal func choseDestination(_ location: String) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setCurrentLocationDetails (_ location: YBLocation) {
        self.curLocation = location
    }
    
    fileprivate func drawMarker(_ location: YBLocation, isPickup: Bool) -> GMSMarker {
        
        let marker = GMSMarker(position: location.coordinate())
        marker.map = gmsMapViewOutlet
        marker.icon = YibbyMapMarker.annotationImageWithMarker(marker,
                                                               title: location.name!,
                                                               type: isPickup ? .pickup : .dropoff)
        return marker
    }
    
    fileprivate func setPickupDetails (_ location: YBLocation) {
        
        self.pickupLocation = location
        
        // 1. clear the map
        gmsMapViewOutlet.clear()
        
        // 2. draw the route
        if let dropoffLoc = self.dropoffLocation {
            DirectionsService.shared.drawRoute(mapView: gmsMapViewOutlet,
                                               loc1: location.coordinate(),
                                               loc2: dropoffLoc.coordinate())
        }
        
        // 3. Draw pickup and dropoff markers
        pickupMarker = drawMarker(location, isPickup: true)
        
        if let dropoffLoc = self.dropoffLocation {
            dropoffMarker = drawMarker(dropoffLoc, isPickup: false)
        }
        
        adjustGMSCameraFocus()
        
        // get the driver's ETA for this pickup location
        getNearestDriverEta(loc: location)
    }
    
    fileprivate func setDropoffDetails (_ location: YBLocation) {
        
        self.dropoffLocation = location
        
        // 1. clear the map
        gmsMapViewOutlet.clear()
        
        // 2. draw the route
        if let pickupLoc = self.pickupLocation {
            DirectionsService.shared.drawRoute(mapView: gmsMapViewOutlet,
                                               loc1: pickupLoc.coordinate(),
                                               loc2: location.coordinate())
        }
        
        // 3. Draw pickup and dropoff markers
        dropoffMarker = drawMarker(location, isPickup: false)
        
        if let pickupLoc = self.pickupLocation {
            pickupMarker = drawMarker(pickupLoc, isPickup: true)
        }
        
        adjustGMSCameraFocus()
    }
    
    fileprivate func adjustGMSCameraFocus() {
        
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
        
        let insets = UIEdgeInsets(top: self.topLayoutGuide.length + (pickupMarker.icon?.size.height)! + 10.0,
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
