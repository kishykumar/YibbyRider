//
//  LeftNavDrawerViewController.swift
//  Example
//
//  Created by Kishy Kumar on 2/18/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import MMDrawerController

class LeftNavDrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    var menuItems: [String] = ["Payment", "History", "Settings", "Promotions", "Help", "About"]
    
    enum TableIndex: Int {
        case Payment = 0
        case History
        case Settings
        case Promotions
        case Help
        case About
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mycell = tableView.dequeueReusableCellWithIdentifier("LeftNavDrawerCellIdentifier", forIndexPath: indexPath) as! LeftNavDrawerTableViewCell
        mycell.menuItemLabel.text = menuItems[indexPath.row]
        return mycell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var selectedViewController: UIViewController = UIViewController()
        
        switch (indexPath.row) {
        case TableIndex.Payment.rawValue:
            
            selectedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
            
            break
        case TableIndex.History.rawValue:
            
            selectedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HistoryViewControllerIdentifier") as! HistoryViewController

            break
        case TableIndex.Settings.rawValue:
            
            selectedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewControllerIdentifier") as! SettingsViewController
            
            break
        case TableIndex.Promotions.rawValue:
            
            selectedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PromotionsViewControllerIdentifier") as! PromotionsViewController
            
            break
        case TableIndex.Help.rawValue:
            
            selectedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HelpViewControllerIdentifier") as! HelpViewController
            
            break
        case TableIndex.About.rawValue:
            
            selectedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AboutViewControllerIdentifier") as! AboutViewController
            
            break
        default: break
        }

        // Push the selected view controller to the main navigation controller
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if let mmnvc = appDelegate.centerContainer!.centerViewController as? UINavigationController {
            
            mmnvc.pushViewController(selectedViewController, animated: true)
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
        } else {
            assert(false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
