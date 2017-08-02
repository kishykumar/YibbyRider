//
//  TripTableVC.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 25/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import FoldingCell
import BaasBoxSDK
import CocoaLumberjack
import DZNEmptyDataSet
import ObjectMapper
import GoogleMaps
import Braintree

class TripTableVC: BaseYibbyTableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

//    let kCloseCellHeight: CGFloat = 172
//    let kOpenCellHeight: CGFloat = 563
    
    let kCloseCellHeight: CGFloat = 195 // Any size about the constraint size (165) is spacing between cells :)
    let kOpenCellHeight: CGFloat = 580 // Any size about the constraint size (550) is spacing between cells
    
    var kRowsCount = 0
    var cellHeights = [CGFloat]()
    @IBOutlet var TV: UITableView!
    
//    var responseDataArray = NSMutableArray()
    var responseDataArray = [Ride]()
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        TV.emptyDataSetSource = self;
        TV.emptyDataSetDelegate = self;
        
        // A little trick for removing the cell separators
        TV.tableFooterView = UIView()
        
        setupUI()

        getTripsService()
        
        createCellHeightsArray()
        //self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
        
    deinit {
        TV.emptyDataSetSource = nil
        TV.emptyDataSetDelegate = nil
    }
    
    func setupUI () {
        
        // add spacing on top of tableview
        let topInset: CGFloat = 60
        TV.contentInset =  UIEdgeInsetsMake(topInset, 0, 0, 0);

        setupBackButton()
//        setupNavigationBar()
    }

    func setupNavigationBar() {
        
        // Make Navbar invisible
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()

        
//        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        negativeSpacer.width = -25
        
//        let backBtn = UIBarButtonItem()
//        let image: UIImage = UIImage(named: "back_button_green")!
//        backBtn.image = image
        //set other properties for your button
        //set traget and action
//        self.navigationItem.leftBarButtonItem = backBtn
//        self.navigationItem.leftBarButtonItems = [negativeSpacer, backBtn]
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        
        cellHeights.removeAll()
        kRowsCount = self.responseDataArray.count
        
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    func reinit() {
        createCellHeightsArray()
        self.TV.reloadData()
    }
    
    // MARK: - Table view data source
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return self.responseDataArray.count
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30.0
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor.clear
//        return view
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseDataArray.count
//        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as TripTableCell = cell else {
            return
        }
        
        let ride = self.responseDataArray[indexPath.row]

        DDLogVerbose("Yibby.Ride at row=\(indexPath.row): \(ride as Any)")
        dump(ride)
        
        //cell.fareOrRideIssueBtn.setTitle("$\(tripObjectModel.fare)", for: .normal)
        cell.userNameLbl.text = ride.driver?.firstName
        cell.totalPriceLbl.text = "$\(ride.fare!)"
        
        if let rideISODateTime = ride.datetime, let rideDate = TimeUtil.getDateFromISOTime(rideISODateTime) {
            let prettyDate = TimeUtil.prettyPrintDate1(rideDate)
            cell.dateAndTimeLbl1.text = prettyDate
            cell.dateAndTimeLbl.text = prettyDate
        }
        
        cell.fromPlaceTF.text = ride.pickupLocation?.name
        cell.toPlaceTF.text = ride.dropoffLocation?.name
        
        if let riderBidPrice = ride.riderBidPrice {
            cell.ridePriceLbl.text = "$\(riderBidPrice)"
        }
        
        if let tip = ride.tip {
            cell.tipPriceLbl.text = "$\(tip)"
        }
        
        if let totalFare = ride.fare {
            cell.totalFareLabelOutlet.text = "$\(totalFare)"
        }
        
        cell.cardDetailsBtnOutlet.tag = indexPath.row
        cell.gmsMapViewOutlet.clear()
        cell.gmsMapViewOpenOutlet.clear()
        
        if let dropoffCoordinate = ride.dropoffLocation?.coordinate(),
            let pickupCoordinate = ride.pickupLocation?.coordinate() {
            
            // Markers for gmsMapViewOutlet
            
            let domarker = GMSMarker(position: dropoffCoordinate)
            domarker.map = cell.gmsMapViewOutlet
            
            let pumarker = GMSMarker(position: pickupCoordinate)
            pumarker.map = cell.gmsMapViewOutlet
            
            adjustGMSCameraFocus(mapView: cell.gmsMapViewOutlet, pickupMarker: pumarker, dropoffMarker: domarker)
            
            // Markers for gmsMapViewOpenOutlet
            
            let domarkerOpen = GMSMarker(position: dropoffCoordinate)
            domarkerOpen.map = cell.gmsMapViewOpenOutlet
            
            let pumarkerOpen = GMSMarker(position: pickupCoordinate)
            pumarkerOpen.map = cell.gmsMapViewOpenOutlet
            
            adjustGMSCameraFocus(mapView: cell.gmsMapViewOpenOutlet, pickupMarker: pumarkerOpen, dropoffMarker: domarkerOpen)
        }

        if let profilePictureFileId = ride.driver?.profilePictureFileId {
            setPicture(imageView: cell.userIV, ride: ride, fileId: profilePictureFileId)
            setPicture(imageView: cell.userIV1, ride: ride, fileId: profilePictureFileId)
        }
        
        if let vehiclePictureFileId = ride.vehicle?.vehiclePictureFileId {
            setPicture(imageView: cell.carIV, ride: ride, fileId: vehiclePictureFileId)
        }
        
        if let milesTravelled = ride.miles {
            cell.distanceInMilesLbl.text = "\(String(describing: milesTravelled)) miles"
        }
        
        if let rideTime = ride.rideTime {
            cell.timeLbl.text = "\(String(describing: rideTime)) mins"
        }
        
        if let paymentMethodBrand = ride.paymentMethodBrand, let paymentMethodLast4 = ride.paymentMethodLast4 {
            cell.cardNumberLbl.text = "*\(paymentMethodLast4)"
            
            let paymentMethodType: BTUIPaymentOptionType =
                BraintreeCardUtil.paymentMethodTypeFromBrand(paymentMethodBrand)
            cell.cardHintOutlet.setCardType(paymentMethodType, animated: false)
        } else {
            let paymentMethodType: BTUIPaymentOptionType =
                BraintreeCardUtil.paymentMethodTypeFromBrand("Visa")
            cell.cardHintOutlet.setCardType(paymentMethodType, animated: false)
            cell.cardNumberLbl.text = "*9999"
        }
        
        /*cell.closeNumberLabel.text = "sankar"
         
         if indexPath.row == 1
         {
         cell.closeNumberLabel.text = "vellampalli"
         }*/
        
        //        cell.lostOrStolenItemBtn.tag = indexPath.row
        //        cell.fareOrRideIssueBtn.tag = indexPath.row
        //        cell.otherIssueBtn.tag = indexPath.row
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
        cell.number = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) 
        let ride = self.responseDataArray[indexPath.row] 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        
    }
    
    @IBAction func lostOrStolenItemBtnAction(_ sender: AnyObject) {
        print("lostOrStolenItemBtn tap")
        
        let emergencyContactsNVC = self.storyboard?.instantiateViewController(withIdentifier: "LostOrStolenItemVC") as! LostOrStolenItemVC
        _ = self.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
    }
    
    @IBAction func fareOrRideIssueBtnAction(_ sender: AnyObject) {
        print("fareOrRideIssueBtn tap")
    }
    
    @IBAction func otherIssueBtnAction(_ sender: AnyObject) {
        print("otherIssueBtn tap")
    }

    @IBAction func carDetailsBtnAction(_ sender: UIButton) {
        print("carDetailsBtnAction tap")
        
        let ride = self.responseDataArray[sender.tag] as! Ride
        let loginSubView = self.storyboard!.instantiateViewController(withIdentifier: "CarDetailsChildView") as! CarDetailsChildView
        //loginSubView.selectedIndex = sender.tag
        loginSubView.carModelStr = ride.vehicle?.make
        loginSubView.carNumberStr = ride.vehicle?.licensePlate
     
        addChildViewController(loginSubView)
        loginSubView.view.backgroundColor = .clear
        DispatchQueue.main.async {
            self.view.addSubview(loginSubView.view)
            // self.emailTxtFld.isHidden=true
        }
    }
    
    
    // MARK: - DZNEmptyDataSet Delegate-Datasource
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        /*if (self.isLoading) {
         return nil;
         }*/
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: InterfaceString.EmptyDataMsg.NotRiddenYetTitle, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        /*if (self.isLoading) {
         return nil;
         }*/
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: InterfaceString.EmptyDataMsg.NotRiddenYetDescription, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        /*if (self.isLoading) {
         return nil;
         }*/
        
        return UIImage(named: "destTextFieldIcon")
    }
    
    /*@IBAction func backBtnAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }*/
    
    // MARK: - Helpers
    
    fileprivate func getTripsService() {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.getRides(BAASBOX_RIDER_STRING, completion: {(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if let success = success {
                let ridesArray = Mapper<Ride>().mapArray(JSONObject: success)! //Swift 3
                self.responseDataArray = ridesArray
                self.reinit()
            }
            else {
                DDLogVerbose("No Trips: \(error)")
            }
        })
    }
    
    fileprivate func adjustGMSCameraFocus(mapView: GMSMapView, pickupMarker: GMSMarker, dropoffMarker: GMSMarker) {
        
        let bounds = GMSCoordinateBounds(coordinate: (pickupMarker.position),
                                         coordinate: (dropoffMarker.position))
        
//        if let markerHeight = pickupMarker.icon?.size.height, let markerWidth = pickupMarker.icon?.size.width {
            let insets = UIEdgeInsets(top: 50.0,
                                  left: 10.0,
                                  bottom: 20.0,
                                  right: 10.0)
            
            let update = GMSCameraUpdate.fit(bounds, with: insets)
            mapView.moveCamera(update)
//        }
    }
    
    func setPicture(imageView: UIImageView, ride: Ride, fileId: String) {
        
        if (fileId == "") {
            return;
        }
        
        if let newUrl = BAAFile.getCompleteURL(withToken: fileId) {
            imageView.pin_setImage(from: newUrl)
        }
    }
}
