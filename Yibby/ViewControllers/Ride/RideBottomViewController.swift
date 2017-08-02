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
    @IBOutlet weak var innerCircleImageViewOutlet: UIImageView!
    
    private var firstAppearanceCompleted = false
    weak var pullUpController: ISHPullUpViewController!
    
    private var currentHeight = CGFloat(0)
    
    static let PULLUP_VIEW_PERCENT_OF_SCREEN: CGFloat = 0.45 // 45%
    private var pullupViewTargetHeight: CGFloat!
    
    let messageComposer = MessageComposer()
    
    // MARK: - Actions
    
    @IBAction func onCallButtonTap(_ sender: UIButton) {
        
        guard let ride = YBClient.sharedInstance().ride, let myDriver = ride.driver else {
            
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
            
            return;
        }
        
        myDriver.call()
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
    
    private dynamic func handleTapGesture(gesture: UITapGestureRecognizer) {
        pullUpController.toggleState(animated: true)
    }
    
    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topViewOutlet.addGestureRecognizer(tapGesture)
        
        let screenSize: CGRect = UIScreen.main.bounds
        pullupViewTargetHeight = RideBottomViewController.PULLUP_VIEW_PERCENT_OF_SCREEN * screenSize.height
        
        driverStatusLabelOutlet.text = "Driver on the way"
        
        if let ride = YBClient.sharedInstance().ride {
            
            DDLogVerbose("KKDBG ride:")
            dump(ride)
            
            let paymentMethodType: BTUIPaymentOptionType =
                BraintreeCardUtil.paymentMethodTypeFromBrand(ride.paymentMethodBrand)
            cardHintViewOutlet.setCardType(paymentMethodType, animated: false)
            
            cardNumberLabelOutlet.text = ride.paymentMethodLast4
            
            totalFareLabelOutlet.text = "$\(String(describing: ride.fare!))"
            peopleLabelOutlet.text = String(describing: ride.numPeople)
            
            if let myDriver = ride.driver {
                driverStarsLabelOutlet.text = "\(String(describing: myDriver.rating!)) Stars"
                
                if let driverRatingStr = myDriver.rating, let driverRating = Double(driverRatingStr) {
                    switch (driverRating) {
                    case 4.0 :
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_4.0")
                        break
                    case 4.5 :
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_4.5")
                        break
                    case 5.0 :
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_5.0")
                        break
                    default:
                        outerCircleImageViewOutlet.image = UIImage(named: "driver_image_circle_4.5")
                        break
                    }
                }
                
                if let driverProfilePic = myDriver.profilePictureFileId {
                    if (driverProfilePic != "") {
                        if let imageUrl  = BAAFile.getCompleteURL(withToken: driverProfilePic) {
                            innerCircleImageViewOutlet.pin_setImage(from: imageUrl)
                            innerCircleImageViewOutlet.setRoundedWithWhiteBorder()
                        }
                    }
                }
            }
            
            if let driverVehicle = ride.vehicle {
                driverCarMakeLabelOutlet.text = driverVehicle.make
                driverCarModelLabelOutlet.text = driverVehicle.model
                driverCarNumberLabelOutlet.text = driverVehicle.licensePlate
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true
        pullUpController.setState(.expanded, animated: false)
        currentHeight = pullupViewTargetHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    
    func rideStartCallback() {
        driverStatusLabelOutlet.text = "Your Ride has started."
    }
    
    func driverArrivedCallback() {
        driverStatusLabelOutlet.text = "Your Driver has arrived."
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

    @IBAction func driverInfoBtnAction(_ sender: Any) {        
        let DriverInfoNVC = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoVC") as! DriverInfoVC
        _ = self.navigationController?.pushViewController(DriverInfoNVC, animated: true)
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
