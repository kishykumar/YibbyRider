//
//  HelpViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

class HelpViewController: BaseYibbyViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    
    @IBOutlet var lastTripTime: UILabel!
    @IBOutlet var lastTripDate: UILabel!
    @IBOutlet var lastTripPrice: UILabel!

    @IBOutlet var appVersionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        
        // Do any additional setup after loading the view.
    }

    @IBAction func rideHistoryBtnAction(sender: AnyObject) {
        let emergencyContactsNVC = self.storyboard?.instantiateViewController(withIdentifier: "RiderHistoryVC") as! RiderHistoryVC
        _ = self.navigationController?.pushViewController(emergencyContactsNVC, animated: true)
    }
    @IBAction func helpCenterBtnAction(sender: AnyObject) {
    }
    @IBAction func legalBtnAction(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
