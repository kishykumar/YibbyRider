//
//  TripTableVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 25/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import FoldingCell
import BaasBoxSDK
import CocoaLumberjack
import DZNEmptyDataSet


class TripTableVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let kCloseCellHeight: CGFloat = 180
    let kOpenCellHeight: CGFloat = 590
    
    let kRowsCount = 2
    
    var cellHeights = [CGFloat]()
    
   // var tripsArray = [String]()
    
    @IBOutlet var TV: UITableView!
    
    
    var responseDataArray = NSMutableArray()
    
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
    self.customBackButton(y: 0 as AnyObject)
    }
    
    func getTripsService()
    {
        ActivityIndicatorUtil.enableActivityIndicator(self.view)
        
        let client: BAAClient = BAAClient.shared()
        
        client.getRides(BAASBOX_RIDER_STRING, completion: {(success, error) -> Void in
            
            ActivityIndicatorUtil.disableActivityIndicator(self.view)
            
            if let resultArray = success as? Array<Any>
            {
        let tripObjectModel = TripObject()
            self.responseDataArray = tripObjectModel.saveTripDetails(responseArr: resultArray as NSArray)
                
                DDLogVerbose("Trips available \(resultArray)")
                
                
               // self.tripsArray = resultArray as! [String]
                
                self.TV.reloadData()
            }
            else {
                DDLogVerbose("No Trips: \(error)")
                
                }
        })
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseDataArray.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as TripTableCell = cell else {
            return
        }
        
        var tripObjectModel = TripObject()
        tripObjectModel = self.responseDataArray[indexPath.row] as! TripObject
        
        
        print(tripObjectModel.id)
        
        cell.dateAndTimeLbl.text = tripObjectModel.dateTime
        //cell.fareOrRideIssueBtn.setTitle("$\(tripObjectModel.fare)", for: .normal)
        cell.userNameLbl.text = tripObjectModel.driver_firstName
        cell.totalPriceLbl.text = "$\(tripObjectModel.fare)"
        
        cell.dateAndTimeLbl1.text = tripObjectModel.dateTime
        cell.fromPlaceTF.text = tripObjectModel.pickup_name
        cell.toPlaceTF.text = tripObjectModel.drop_name
        cell.ridePriceLbl.text = "$\(tripObjectModel.riderBidPrice)"
        
        cell.cardDetailsBtnOutlet.tag = indexPath.row
        
        
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
        
        
        var tripObjectModel = TripObject()
       tripObjectModel = self.responseDataArray[indexPath.row] as! TripObject
        
        
        print(tripObjectModel.id)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table vie delegate
    
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
        
        var tripObjectModel = TripObject()
        tripObjectModel = self.responseDataArray[sender.tag] as! TripObject
        print(tripObjectModel)
        print(tripObjectModel.vehicle_make)
        
        let loginSubView = self.storyboard!.instantiateViewController(withIdentifier: "CarDetailsChildView") as! CarDetailsChildView
        //loginSubView.selectedIndex = sender.tag
        loginSubView.carModelStr = tripObjectModel.vehicle_make
        loginSubView.carNumberStr = tripObjectModel.vehicle_licensePlate
        
        print(loginSubView.view.frame)        
        
        print(sender.tag)
     
        addChildViewController(loginSubView)
        loginSubView.view.backgroundColor = .clear
        DispatchQueue.main.async {
            self.view.addSubview(loginSubView.view)
            // self.emailTxtFld.isHidden=true
        }
    }
    
    
    // MARK: DZNEmptyDataSet Delegate-Datasource
    
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
}
