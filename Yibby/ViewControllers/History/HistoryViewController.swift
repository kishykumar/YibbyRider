//
//  HistoryViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import BaasBoxSDK
import DZNEmptyDataSet
import SVProgressHUD

class HistoryViewController: BaseYibbyTableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    var rides = [BAAFile]()
    let identifier: String = "historyTableCell"
    
    var shownRides: Int = 0
    var totalRides: Int = 0
    var nextPageToLoad: Int = 0
    var totalPages: Int = 0
    var isLoading: Bool = false
    
    let NUM_FETCH_RIDE_ENTRIES: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        ActivityIndicatorUtil.enableActivityIndicator(view, status: InterfaceString.ActivityIndicator.Loading, mask: SVProgressHUDMaskType.Custom,
                                     maskColor: UIColor.whiteColor(), style: SVProgressHUDStyle.Dark)
        
        //This block runs when the table view scrolled to the bottom
        weak var weakSelf = self

        //Don't forget to make weak pointer to self
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
        
        self.performSelector(#selector(HistoryViewController.loadNextPage),
                             withObject:nil, afterDelay:0.0)
    }
    
    func loadNextPage() {
        self.isLoading = true

        if (self.footerActivityIndicatorView() == nil) {
            self.addFooterActivityIndicatorWithHeight(80.0)
        }

        if nextPageToLoad == 0 {
            
            // make nested webserver calls to get 1. the total number of rides,  and 2. the first page of rides
            WebInterface.makeWebRequestAndHandleError(
                self,
                webRequest: {(errorBlock: (BAAObjectResultBlock)) -> Void in
                    
                    let client: BAAClient = BAAClient.sharedClient()
                    client.fetchCountForFiles( {(success, error) -> Void in
                            
                            if (error == nil) {
                                
                                // parse the result to get the total number of rides
                                DDLogVerbose("Success in fetching ridecount: \(success)")
                                self.totalRides = success
                                
                                // If non-zero total rides then fetch the first batch
                                if self.totalRides == 0 {
                                    
                                    // The DNZ Empty container view will be shown automatically
                                    DDLogVerbose("Removed loadingActivityIndicator1")
                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                    self.removeFooterActivityIndicator()
                                    
                                    self.isLoading = false
                                    self.tableView.reloadData()
                                    return;
                                }
                                
                                // TODO: Remove the delay later
                                self.performSelector(#selector(HistoryViewController.loadNewRides),
                                    withObject:nil, afterDelay:5.0)
                            }
                            else {
                                errorBlock(success, error)
                            }
                    })
            })
            
            return;
        }
        
        // Add ENFooterActivityIndicatorView to tableView's footer
        if shownRides < totalRides {
            self.performSelector(#selector(HistoryViewController.loadNewRides), withObject:nil, afterDelay:5.0)
        }
        else {
            self.removeFooterActivityIndicator()
        }
    }

    func loadNewRides() {
        
        // load the new rides
        WebInterface.makeWebRequestAndHandleError(
            self,
            webRequest: {(errorBlock: (BAAObjectResultBlock)) -> Void in
                
                let client: BAAClient = BAAClient.sharedClient()
                let file: BAAFile = BAAFile()
                client.loadFiles(file, withParams: ["orderBy": "_creation_date%20desc", "recordsPerPage": self.NUM_FETCH_RIDE_ENTRIES,
                    "page": self.nextPageToLoad], completion: {(success, error) -> Void in
                        
                        if (error == nil) {
                            
                            // get success result
                            let loadedRides = success as? [BAAFile]
                            
                            if let loadedRides = loadedRides {
                            
                                let numRidesToShow = loadedRides.count
                                DDLogVerbose("numRidesToShow \(numRidesToShow)")
                                
                                if numRidesToShow != 0 {
                                    // add the new rides to the existing set of rides
                                    for i in 0...(numRidesToShow-1) {
                                        self.rides.append(loadedRides[i])
                                    }
                                    
                                    self.shownRides = (self.shownRides + numRidesToShow)
                                    self.nextPageToLoad = self.nextPageToLoad + 1

                                    self.tableView.reloadData()
                                    ActivityIndicatorUtil.disableActivityIndicator(self.view)
                                }
                            }
                        }
                        else {
                            errorBlock(success, error)
                        }
                        self.removeFooterActivityIndicator()
                        self.isLoading = false
                })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - UITableView DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: HistoryTableCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! HistoryTableCell
//        cell.configure(rides[indexPath.row])
        
        //let myfile: BAAFile = rides[indexPath.row]
        
        // convert myfile to Ride
        let myride:Ride = Ride(id: "", bidHigh: 10, bidLow: 5,
            etaHigh: 5, etaLow: 1, pickupLat: 37.531631,
            pickupLong: -122.263606, pickupLoc: "420 Oracle Pkwy, Redwood City, CA 94065", dropoffLat: 37.348209,
            dropoffLong: -121.993756, dropoffLoc: "3500 Granada Ave, Santa Clara, CA 95051")
        
        cell.configure(myride)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shownRides
    }
    
    //MARK: - UITableView Delegate
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1;
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rideDetail" {
            let indexPath = self.tableView!.indexPathForSelectedRow
            let destinationViewController: RideDetailViewController = segue.destinationViewController as! RideDetailViewController
            
            destinationViewController.ride = rides[indexPath!.row]
        }
    }
    
    // MARK: DZNEmptyDataSet Delegate-Datasource
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        if (self.isLoading) {
            return nil;
        }
        
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: InterfaceString.EmptyDataMsg.NotRiddenYetTitle, attributes: attrs)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        if (self.isLoading) {
            return nil;
        }
        
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
        return NSAttributedString(string: InterfaceString.EmptyDataMsg.NotRiddenYetDescription, attributes: attrs)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        
        if (self.isLoading) {
            return nil;
        }
        
        return UIImage(named: "destTextFieldIcon")
    }

}
