//
//  RideDetailViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/17/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

// TODO: Remove 'import BaasBoxSDK' and BAAFile references

import UIKit
import BaasBoxSDK

class RideDetailViewController: BaseYibbyViewController {

    // MARK: - Properties
    var ride: BAAFile!             // we need a strong reference as the ride should not be nil
    
    // MARK: - Setup functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // Do any additional setup after loading the view.
        
    }

    private func setupUI() {
        self.customBackButton(y: 20 as AnyObject)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchRideFromServer() {
        
    }
    
    // MARK: - Helper functions

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
