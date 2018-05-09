//
//  DriverEnRouteBottomViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 12/15/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import ISHPullUp
import CocoaLumberjack
import Braintree
import BaasBoxSDK
import Spring

class RideBottomViewController: BaseYibbyViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var rootViewOutlet: UIView!
    @IBOutlet weak var topViewOutlet: UIView!
    @IBOutlet weak var driverStatusLabelOutlet: SpringLabel!

    @IBOutlet weak var cardHintViewOutlet: BTUICardHint!
    @IBOutlet weak var cardNumberLabelOutlet: UILabel!
    @IBOutlet weak var totalFareLabelOutlet: UILabel!
    
    @IBOutlet weak var peopleLabelOutlet: UILabel!
    @IBOutlet weak var driverStarsLabelOutlet: UILabel!
    @IBOutlet weak var driverCarMakeLabelOutlet: UILabel!
    @IBOutlet weak var driverCarModelLabelOutlet: UILabel!
    @IBOutlet weak var driverCarNumberLabelOutlet: YibbyPaddingLabel!
    @IBOutlet weak var outerCircleImageViewOutlet: UIImageView!
    @IBOutlet weak var innerCircleImageViewOutlet: SwiftyAvatar!
    
    private var firstAppearanceCompleted = false
    weak var pullUpController: RideViewController? // weak reference to not create a strong reference cycle
    
    private var currentHeight = CGFloat(0)
    
    static let PULLUP_VIEW_PERCENT_OF_SCREEN: CGFloat = 0.45 // 45%
    private var pullupViewTargetHeight: CGFloat!
    
    let messageComposer = MessageComposer()
    
    // MARK: - Actions
    
    @IBAction func driverInfoBtnAction(_ sender: Any) {
        
        guard let ride = YBClient.sharedInstance().ride,
            let myDriver = ride.driver,
            let myDriverVehicle = ride.vehicle else {
                
                DDLogError("Ride details not present. Dump state: ")
                dump(YBClient.sharedInstance())
                return;
        }
        
        let driverInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoVC") as! DriverInfoVC
        
        driverInfoViewController.myDriver = myDriver
        driverInfoViewController.myDriverVehicle = myDriverVehicle
        
        _ = self.navigationController?.pushViewController(driverInfoViewController, animated: true)
    }
    
    @IBAction func onCallButtonTap(_ sender: UIButton) {
        
        guard let ride = YBClient.sharedInstance().ride, let myDriver = ride.driver else {
            
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
            
            return;
        }
        
        myDriver.call()
    }

    @IBAction func onCenterMarkersButtonTap(_ sender: UIButton) {
        if let puVC = pullUpController {
            puVC.centerMarkers()
        }
    }
    
    @IBAction func sendTextMessageButtonTapped(_ sender: UIButton) {

        guard let ride = YBClient.sharedInstance().ride, let myDriver = ride.driver, let phoneNumber = myDriver.phoneNumber else {
            
            let errorAlert = UIAlertView(title: "Unexpected Error.", message: "We are working on resolving this error for you. Sincere apology for the inconvenience.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
            
            return;
        }
        
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController(phoneNumber: phoneNumber)
            
            // Present the configured MFMessageComposeViewController instance
            self.present(messageComposeVC, animated: true, completion: nil)
            
        } else {
            let errorAlert = UIAlertView(title: "Unexpected Error.", message: "We are working on resolving this error for you. Sincere apology for the inconvenience.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    @objc private dynamic func handleTapGesture(gesture: UITapGestureRecognizer) {
        if let puVC = pullUpController {
            puVC.toggleState(animated: true)
        }
    }
    
    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        rideSetup()
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
    
    fileprivate func rideSetup() {
        
        if let puVC = pullUpController {

            let state: RideViewControllerState = puVC.controllerState
            
            switch (state) {
            case .driverEnRoute:
                
                driverStatusLabelOutlet.text = DriverStateDescription.driverEnRoute.rawValue
                
                break
                
            case .driverArrived:
                driverStatusLabelOutlet.text = DriverStateDescription.driverArrived.rawValue

                break
                
            case .rideStart:
                driverStatusLabelOutlet.text = DriverStateDescription.rideStarted.rawValue

                break
            }
            
            startDriverStatusAnimation()
        }
    }
    
    @objc fileprivate func appBecameActive() {
        startDriverStatusAnimation()
    }
    
    fileprivate func setupUI() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topViewOutlet.addGestureRecognizer(tapGesture)
        
        let screenSize: CGRect = UIScreen.main.bounds
        pullupViewTargetHeight = RideBottomViewController.PULLUP_VIEW_PERCENT_OF_SCREEN * screenSize.height
        
        if let ride = YBClient.sharedInstance().ride {
            
            let paymentMethodType: BTUIPaymentOptionType =
                BraintreeCardUtil.paymentMethodTypeFromBrand(ride.paymentMethodBrand)
            cardHintViewOutlet.setCardType(paymentMethodType, animated: false)
            
            if let last4 = ride.paymentMethodLast4 {
                cardNumberLabelOutlet.text = "*\(last4)"
            }
            
            if let fare = ride.fare {
                let fareInt = Int(fare)
                totalFareLabelOutlet.text = "$\(String(describing: fareInt))"
            }
            
            if let people = ride.numPeople {
                
                if people == 1 {
                    peopleLabelOutlet.text = "\(String(describing: people)) person"
                } else {
                    peopleLabelOutlet.text = "\(String(describing: people)) persons"
                }
            }
            
            if let myDriver = ride.driver {
                driverStarsLabelOutlet.text = "\(String(describing: myDriver.rating!))"
                
                 if let driverRatingStr = myDriver.rating, let driverRating = Double(driverRatingStr) {
                    switch (driverRating) {
                    case 4.0 :
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_4_0")
                        break
                    case 4.5 :
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_4_5")
                        break
                    case 5.0 :
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_5_0")
                        break
                    default:
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_4_5")
                        break
                    }
                }
                
                innerCircleImageViewOutlet.setImageForName(string: myDriver.firstName!,
                                                           backgroundColor: nil,
                                                           circular: true,
                                                           textAttributes: nil)
            
                if let driverProfilePic = myDriver.profilePictureFileId {
                    if (driverProfilePic != "") {
                        if let imageUrl  = BAAFile.getCompleteURL(withToken: driverProfilePic) {
                            innerCircleImageViewOutlet.pin_setImage(from: imageUrl)
                        }
                    }
                }
            }
            
            if let driverVehicle = ride.vehicle {
                driverCarMakeLabelOutlet.text = driverVehicle.make
                driverCarModelLabelOutlet.text = driverVehicle.model
                driverCarNumberLabelOutlet.text = driverVehicle.licensePlate?.uppercased()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true
        
        // Set the current state of the pullUp view
        if let puVC = pullUpController {
            puVC.setState(.collapsed, animated: false)
        }
        
        currentHeight = pullupViewTargetHeight/4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Notifications
    
    fileprivate func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func setupNotificationObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RideBottomViewController.appBecameActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    // MARK: - Helpers
    
    fileprivate func startDriverStatusAnimation() {
        driverStatusLabelOutlet.animation = "flash"
        driverStatusLabelOutlet.duration = 1.5
        driverStatusLabelOutlet.repeatCount = .infinity
        driverStatusLabelOutlet.animate()
    }
    
    fileprivate func stopDriverStatusAnimation() {
        driverStatusLabelOutlet.layer.removeAllAnimations()
    }
    
    func rideStartCallback() {
        driverStatusLabelOutlet.text = DriverStateDescription.rideStarted.rawValue
    }
    
    func driverArrivedCallback() {
        driverStatusLabelOutlet.text = DriverStateDescription.driverArrived.rawValue
    }
    
    // MARK: - ISHPullUpSizingDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        
        return pullupViewTargetHeight
//        return rootViewOutlet.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        
        return pullupViewTargetHeight/4
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        
        let collapsedHeight = pullupViewTargetHeight/4
//        let rootViewHeight = rootViewOutlet.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        if (height > pullupViewTargetHeight) {
            return height
        }
        
        if (height < currentHeight) {
            currentHeight = collapsedHeight
            return collapsedHeight
        }
        
        if (height > currentHeight) {
            currentHeight = pullupViewTargetHeight
            return pullupViewTargetHeight
        }
        
        // default behaviour...should not reach here.
        return height
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController bottomVC: UIViewController) {
        // we update the scroll view's content inset
        // to properly support scrolling in the intermediate states
        
    }
    
    // MARK: ISHPullUpStateDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
//        topLabel.text = textForState(state);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
