
//
//  NotificationsVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var TV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func changeBtnAction(sender: AnyObject) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 //sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAtindexPath: IndexPath) -> CGFloat {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0 {
            return 90
        }
        else if indexPath.section == 1 {
            return 175
        }
        else if indexPath.section == 2 {
            return 175
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            
            let notificationCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC", for: indexPath as IndexPath) as UITableViewCell

            return notificationCell
        }
        else if indexPath.section == 1 {
            
            let notificationCell1 = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC1", for: indexPath as IndexPath) as UITableViewCell
            
            return notificationCell1
        }
        else
        {
            let notificationCell2 = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC2", for: indexPath as IndexPath) as UITableViewCell
            
            return notificationCell2
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
