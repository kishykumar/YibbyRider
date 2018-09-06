//
//  TripTableVC.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 25/02/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import UIKit
import FoldingCell
import BaasBoxSDK
import CocoaLumberjack
import DZNEmptyDataSet
import ObjectMapper
import GoogleMaps
import Braintree
import Presentr

class TripTableVC: BaseYibbyTableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    // MARK: - Properties 
    
    let kCloseCellHeight: CGFloat = 195 // Any size about the constraint size (165) is spacing between cells :)
    let kOpenCellHeight: CGFloat = 580 // Any size about the constraint size (550) is spacing between cells
    
    var kRowsCount = 0
    var cellHeights = [CGFloat]()
    
    @IBOutlet var TV: UITableView!
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = TransitionType.coverHorizontalFromRight
        presenter.dismissOnSwipe = true
        return presenter
    }()
    
    var ridesList = [Ride]()

    var shownRides: Int = 0
    var totalRides: Int = 0
    var nextPageToLoad: Int = 0
    var totalPages: Int = 0
    var isLoading: Bool = false
    
    let NUM_FETCH_RIDE_ENTRIES: Int = 5

    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        // Setup Delegate and data source for DZNEmptyDataSet
        TV.emptyDataSetSource = self;
        TV.emptyDataSetDelegate = self;
        
        // A little trick for removing the cell separators
        TV.tableFooterView = UIView()
        
        createCellHeightsArray()
        
        // This block runs when the table view scrolled to the bottom
        weak var weakSelf = self
        
        // Don't forget to make weak pointer to self
        self.tableScrolledDownBlock = { () -> Void in
            
            // data loading logic
            if let strongSelf = weakSelf {
                if !strongSelf.isLoading {
                    strongSelf.loadNextPage()
                }
            }
        }
        
        self.shownRides = 0
        self.totalRides = 0
        self.nextPageToLoad = 0
        self.totalPages = 0
        
//        ActivityIndicatorUtil.enableBlurActivityIndicator(view, title: InterfaceString.ActivityIndicator.Loading)
//        self.perform(#selector(TripTableVC.loadNextPage), with:nil, afterDelay:0.0)
    }
    
    deinit {
        TV.emptyDataSetSource = nil
        TV.emptyDataSetDelegate = nil
    }
    
    func setupUI () {
        
        // add spacing on top of tableview
//        let topInset: CGFloat = 60
//        TV.contentInset =  UIEdgeInsetsMake(topInset, 0, 0, 0);

        setupBackButton()
        // setupNavigationBar()
    }

    func setupNavigationBar() {
        
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        
        cellHeights.removeAll()
        kRowsCount = self.ridesList.count
        
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    func reinit() {
        
        if (self.shownRides != 0) {
            let topInset: CGFloat = 80
            TV.contentInset =  UIEdgeInsetsMake(topInset, 0, 0, 0);
        }
        
        createCellHeightsArray()
        self.TV.reloadData()
    }
    
    // MARK: - UITableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shownRides
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as TripTableCell = cell else {
            return
        }
        
        let ride = self.ridesList[indexPath.row]

        cell.myViewController = self
        cell.myTrip = ride
        
        cell.configure(ride)
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
        cell.number = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripTableCellIdentifier", for: indexPath)
        
        if let tripCell = cell as? TripTableCell {
            tripCell.resetAllContent()
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }

    // MARK: - UITableView Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if (self.shownRides == 0) {
            return 0;
        }
        
        // Return the number of sections.
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        
    }
    
    // MARK: - DZNEmptyDataSet Delegate-Datasource
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        if (self.isLoading) {
            return nil;
        }
        
        let attrs = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22.0), NSAttributedStringKey.foregroundColor: UIColor.appDarkGreen1()]
        return NSAttributedString(string: InterfaceString.EmptyDataMsg.NotRiddenYetTitle, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        if (self.isLoading) {
            return nil;
        }
        
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0), NSAttributedStringKey.foregroundColor: UIColor.black]
        return NSAttributedString(string: InterfaceString.EmptyDataMsg.NotRiddenYetDescription, attributes: attrs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let defaultColor: UIColor = self.view.tintColor
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0), NSAttributedStringKey.foregroundColor: defaultColor]
        return NSAttributedString(string: "Learn More", attributes: attrs)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 20.0
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        if (self.isLoading) {
            return nil;
        }
        
        return UIImage(named: "car_gear")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        // TODO:
        let url = URL(string: "http://yibbyapp.com")!
        UIApplication.shared.openURL(url)
    }
    
    /*@IBAction func backBtnAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }*/
    
    // MARK: - Helpers
    
//    fileprivate func getTripsService() {
//        ActivityIndicatorUtil.enableActivityIndicator(self.view)
//        
//        let client: BAAClient = BAAClient.shared()
//        
//        client.getRides(BAASBOX_RIDER_STRING, completion: {(success, error) -> Void in
//            
//            ActivityIndicatorUtil.disableActivityIndicator(self.view)
//            
//            if let success = success {
//                let ridesArray = Mapper<Ride>().mapArray(JSONObject: success)! //Swift 3
//                self.ridesList = ridesArray
//                self.reinit()
//            }
//            else {
//                DDLogVerbose("No Trips: \(String(describing: error))")
//            }
//        })
//    }
    
    @objc fileprivate func loadNextPage() {
        self.isLoading = true

        if (self.footerActivityIndicatorView() == nil &&
            nextPageToLoad != 0) {
            self.addFooterActivityIndicator(withHeight: 80.0)
        }
        
        // Make nested webserver calls to get 
        //   1. the total number of rides,  and 
        //   2. the first page of rides
        if nextPageToLoad == 0 {
        
            ActivityIndicatorUtil.enableBlurActivityIndicator(self.view, title: InterfaceString.ActivityIndicator.Loading)
            
            WebInterface.makeWebRequestAndHandleError(
                self,
                webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                    
                let client: BAAClient = BAAClient.shared()
                client.fetchCount(forRides: nil, completion: {(success, error) -> Void in
                    
                    if (error == nil) {
                        
                        // parse the result to get the total number of rides
                        DDLogVerbose("Success in fetching ridecount: \(success)")
                        self.totalRides = success
                        
                        // If zero total rides, then return and remove the activity indicator
                        if self.totalRides == 0 {
                            
                            // The DNZ Empty container view will be shown automatically
                            ActivityIndicatorUtil.disableActivityIndicator(self.view)
                            
                            if (self.footerActivityIndicatorView() != nil) {
                                self.removeFooterActivityIndicator()
                            }
                            
                            self.isLoading = false
                            self.reinit()
                            return;
                        }
                        
                        self.perform(#selector(TripTableVC.loadNewRides), with:nil, afterDelay:1.0)
                    }
                    else {
                        errorBlock(success, error)
                        
                        // The DNZ Empty container view will be shown automatically
                        ActivityIndicatorUtil.disableActivityIndicator(self.view)
                        
                        if (self.footerActivityIndicatorView() != nil) {
                            self.removeFooterActivityIndicator()
                        }
                        
                        self.isLoading = false
                        self.reinit()
                        return;
                    }
                })
            })            
        }
        
        // Get more rides
        if shownRides < totalRides {
            self.perform(#selector(TripTableVC.loadNewRides), with:nil, afterDelay:5.0)
        }
        else {
            // remove ENFooterActivityIndicatorView to tableView's footer
            if (self.footerActivityIndicatorView() != nil) {
                self.removeFooterActivityIndicator()
            }
        }
    }
    
    @objc fileprivate func loadNewRides() {
        
        // load the new rides
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: @escaping (BAAObjectResultBlock)) -> Void in
                
                let client: BAAClient = BAAClient.shared()
                
                client.getRides(BAASBOX_RIDER_STRING,
                                 withParams: ["orderBy": "_creation_date desc", "recordsPerPage": self.NUM_FETCH_RIDE_ENTRIES,
                                              "page": self.nextPageToLoad],
                                 completion: {(success, error) -> Void in
                                                        
                                    if (error == nil && success != nil) {
                                        
                                        let loadedRides = Mapper<Ride>().mapArray(JSONObject: success)

                                        if let loadedRides = loadedRides {
                                            
                                            let numRidesToShow = loadedRides.count
                                            
                                            if numRidesToShow != 0 {
                                                // add the new rides to the existing set of rides
                                                for i in 0...(numRidesToShow-1) {
                                                    self.ridesList.append(loadedRides[i])
                                                }
                                                
                                                self.shownRides = (self.shownRides + numRidesToShow)
                                                self.nextPageToLoad = self.nextPageToLoad + 1
                                                
                                                self.reinit()
                                            }
                                        }
                                    }
                                    else {
                                        errorBlock(success, error)
                                    }
                                    
                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                    
                                    if (self.footerActivityIndicatorView() != nil) {
                                        self.removeFooterActivityIndicator()
                                    }
                                    
                                    self.isLoading = false
                })
        })
    }
}
