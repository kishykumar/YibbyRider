//
//  TripViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/12/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

class TripViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var tripProgressLabelOutlet: UILabel!
    @IBOutlet weak var etaLabelOutlet: UILabel!
    
    // MARK: Actions
    
    @IBAction func cancelRideAction(sender: AnyObject) {
        
    }
    
    // MARK: Setup functions 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
