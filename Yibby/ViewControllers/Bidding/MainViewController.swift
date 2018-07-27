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
                                GMSAutocompleteViewControllerDelegate,
                                GMSMapViewDelegate {

    // MARK: - Properties
    @IBOutlet weak var gmsMapViewOutlet: GMSMapView!
//    @IBOutlet weak var rangeSliderOutlet: ASValueTrackingSlider!
    @IBOutlet weak var bidButton: UIButton!
    @IBOutlet weak var priceSliderViewOutlet: YibbyBorderedUIView!
    @IBOutlet weak var centerMarkersViewOutlet: YibbyBorderedUIView!
    @IBOutlet weak var bidSliderOutlet: YBSlider!
    @IBOutlet weak var etaStackView: UIStackView!
    @IBOutlet weak var etaLabelStackView: UIStackView!
    @IBOutlet weak var driverETALabelOutlet: UILabel!
    @IBOutlet weak var userBidLabelOutlet: UILabel!
    @IBOutlet weak var suggestedBidLabelOutlet: UILabel!
    
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
    fileprivate var suggestedBid: Int = 0

    var priceSliderViewHidden = false
    var miscPickerViewHidden = false
    
    //15 sec timer
    var timer:Timer?
    var isTimerRunning:Bool = false
    //60 sec timer
    var minTimer:Timer?
    var isMinTimerRunning:Bool = false
    //ETAIndicator
    var driverEtaIndicator:UIActivityIndicatorView?

    
    fileprivate var offerRejectedObserver: NotificationObserver? // for offer reject
    fileprivate var rideObserver: NotificationObserver? // for driver en route message
    
    // MARK: - Actions
    
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
    
    // RideEndViewController uses this to unwind to MainViewController
    @IBAction func unwindToMainViewController(_ segue:UIStoryboardSegue) {
        
        // Always clear the bid when coming back to Main View Controller
        YBClient.sharedInstance().status = .looking
        YBClient.sharedInstance().bid = nil
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
        if (YBClient.sharedInstance().defaultPaymentMethod == nil) {
            AlertUtil.displayAlertOnVC(self, title: "No Default Payment Method", message: "Please add a payment method in the Payment Menu.")
            return;
        }
        
        let bidHighInt = Int(self.bidSliderOutlet.value)
        bidHigh = Float(bidHighInt)
        
        if (pickupLocation != nil &&
            dropoffLocation != nil && bidHigh != nil) {
            
            DDLogVerbose("Going to bid: pickupLoc: \(String(describing: pickupLocation)), dropoffLoc: \(String(describing: dropoffLocation)), bidHigh: \(String(describing: bidHigh))")
            
            let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
            let confirmRideViewController = biddingStoryboard.instantiateViewController(withIdentifier: "ConfirmRideViewControllerIdentifier") as! ConfirmRideViewController
            
            // Initialize the view controller state 
            confirmRideViewController.bidPrice = self.bidHigh!
            confirmRideViewController.pickupLocation = self.pickupLocation!
            confirmRideViewController.dropoffLocation = self.dropoffLocation!
            confirmRideViewController.currentPaymentMethod = YBClient.sharedInstance().defaultPaymentMethod!
            
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
    
    @IBAction func onBidSliderValueChange(_ sender: YBSlider) {
        
        let curUserBid = Int(sender.value)
        userBidLabelOutlet.text = "$\(curUserBid)"
        
        if (self.suggestedBid > curUserBid) {
            self.bidSliderOutlet.minimumTrackTintColor = UIColor.bidSliderRed()
        } else {
            self.bidSliderOutlet.minimumTrackTintColor = UIColor.bidSliderGreen()
        }
    }
    
    // MARK: - Setup
    
    func setupDelegates() {
        gmsMapViewOutlet.delegate = self
    }
    
    func setupUI() {
        // currency range slider
        setupMenuButton()
        let myView = UIView(frame: CGRect(x: 10, y: 0, width: 20, height: 20.5))
        driverEtaIndicator = ActivityIndicatorUtil.myIndicator(myView)
        etaLabelStackView.addArrangedSubview(myView)
        self.bidSliderOutlet.minimumTrackTintColor = UIColor.bidSliderGreen()
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
        self.setPickupDetails(YBLocation(lat: 37.422094, long: -122.084068, name: "Googleplex, Amphitheatre Parkway, Mountain View, CA"))
        self.setDropoffDetails(YBLocation(lat: 37.430033, long: -122.173335, name: "Stanford Computer Science Department"))
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
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        // Moved the rounding circle code here because the circling wasn't happening correctly.
        // Please refer here for why this solution has been picked:
        // http://stackoverflow.com/questions/29685055/ios-frame-size-width-2-doesnt-produce-a-circle-on-every-device
        //miscHintViewOutlet.setRoundedWithWhiteBorder()
        //dollarHintViewOutlet.setRoundedWithWhiteBorder()
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

            // dismiss the currently presented offerViewController
            self.dismiss(animated: true, completion: nil)

            // Clear the locally persisted bid
            YBClient.sharedInstance().bid = nil
            AlertUtil.displayAlertOnVC(self, title: "No offers from drivers.",
                                   message: "Your bid was not accepted by any driver",
                                   completionBlock: {() -> Void in
                                    //self.dismiss(animated: true, completion: nil)
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
                    if var loadedEtas = loadedEtas {
                        
                        loadedEtas.sort {
                            if ($0.eta! < $1.eta!) {
                                return true
                            } else {
                                return false
                            }
                        }
                        
                        // Convert seconds to minutes and round up
                        var minEtaMins = (loadedEtas.first!.eta! + 59) / 60
                        var maxEtaMins = (loadedEtas.last!.eta! + 59) / 60
                        
                        if (minEtaMins == 0) {
                            minEtaMins = 1
                        }
                        
                        if (maxEtaMins == 0) {
                            maxEtaMins = 1
                        }
                        
                        DDLogVerbose("KKDBG_getNearestDriverEta \(minEtaMins) \(maxEtaMins)")
                        
                        if (minEtaMins == maxEtaMins) {
                            self.driverETALabelOutlet.text = "\(minEtaMins) mins"
                        } else {
                            self.driverETALabelOutlet.text = "\(minEtaMins)-\(maxEtaMins) mins"
                        }
                        //invalidate 15 sec timer and fire 60 sec timer
                        if self.isMinTimerRunning==false{
                            self.invalidateTimer()
                            self.minTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
                                self.getNearestDriverEta(loc: loc)
                                self.isMinTimerRunning = true
                                DDLogVerbose("60 sec timer fired")
                            })
                            
                        }
                    } else {
                        self.driverETALabelOutlet.text = "No Drivers"
                        //invalidate 60 sec timer and run 15 sec timer
                        if self.isTimerRunning==false{
                            self.driverEtaIndicator?.startAnimating()
                            self.invalidateTimerOfMinute()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { (_) in
                                self.getNearestDriverEta(loc: loc)
                                self.isTimerRunning = true
                                DDLogVerbose("15 sec timer fired")
                            })
                            
                        }
                    }
                } else {
                    self.invalidateTimer()
                    self.invalidateTimerOfMinute()
                    self.driverETALabelOutlet.text = "No Drivers"
                    DDLogVerbose("Error in getNearestDriverEta \(String(describing: error))")
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
            
            setSuggestedBid(pickupLoc: location, dropoffLoc: dropoffLoc)
        }
        
        // 3. Draw pickup and dropoff markers
        pickupMarker = drawMarker(location, isPickup: true)
        
        if let dropoffLoc = self.dropoffLocation {
            dropoffMarker = drawMarker(dropoffLoc, isPickup: false)
        }
        
        adjustGMSCameraFocus()
        invalidateTimer()
        invalidateTimerOfMinute()
        
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
            
            setSuggestedBid(pickupLoc: pickupLoc, dropoffLoc: location)
        }
        
        // 3. Draw pickup and dropoff markers
        dropoffMarker = drawMarker(location, isPickup: false)
        
        if let pickupLoc = self.pickupLocation {
            pickupMarker = drawMarker(pickupLoc, isPickup: true)
        }
        
        adjustGMSCameraFocus()
    }
    
    fileprivate func setSuggestedBid(pickupLoc: YBLocation, dropoffLoc: YBLocation) {
        
//        Uber and Lyft San Francisco fares:
//        Base Fare: $2.20
//        Per Minute: $0.24
//        Per Mile: $1.33
//        Cancellation Fee: $5
//        Service Fees: $2.20
//        Minimum Fare: $7.20
        
        DirectionsService.shared.getEta(from: pickupLoc.coordinate(), to: dropoffLoc.coordinate(),
            completionBlock: { (etaSeconds, distanceMeters) -> Void in

                // All base calculations in cents, meters, seconds
                let bookingFeesCents: Int = 0
                let serviceFeesCents: Int = 100
                let perMinuteCents: Int = 24
                let perMileCents: Int = 133

                let timeFees = (perMinuteCents * Int(etaSeconds)) / 60
                let distanceFees = Int((Double(perMileCents) * distanceMeters) / 1609.34)

                let maxBidCents: Int = bookingFeesCents + serviceFeesCents + timeFees + distanceFees
                //Suggested Bid is 75% of max dollars
                //low Bid is 50% of max dollars
                let maxBidDollars: Int = maxBidCents / 100
                let suggestedBidDollars: Int = (maxBidDollars * 75)/100
                let lowBidDollars: Int = (maxBidDollars * 5) / 10
                DDLogVerbose("max bid dollars \(maxBidDollars)")
                DDLogVerbose("min bid dollars \(lowBidDollars)")
                DDLogVerbose("suggested bid dollars \(suggestedBidDollars)")

                self.suggestedBidLabelOutlet.text = "$\(suggestedBidDollars)"
                self.suggestedBid = suggestedBidDollars
                self.userBidLabelOutlet.text = "$\(suggestedBidDollars)"

                self.bidSliderOutlet.maximumValue = Float(maxBidDollars)
                self.bidSliderOutlet.minimumValue = Float(lowBidDollars)
                self.bidSliderOutlet.value = Float(suggestedBidDollars)
        })
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
    
    //invalidate timers
    func invalidateTimer(){
        timer?.invalidate()
        isTimerRunning=false
        driverEtaIndicator?.stopAnimating()
        DDLogVerbose("15 sec timer invalidated")
    }
    
    func invalidateTimerOfMinute(){
        minTimer?.invalidate()
        isMinTimerRunning = false
        DDLogVerbose("60 sec timer invalidated")
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
}
