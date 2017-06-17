//
//  DriverInfoVC.swift
//  sr
//
//  Created by Rahul Mehndiratta on 10/03/17.
//  Copyright © 2017 Rahul Mehndiratta. All rights reserved.
//

import UIKit

class DriverInfoVC: UIViewController {

    @IBOutlet var driverImage: UIImageView!
    @IBOutlet var carImage: UIImageView!

    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    
    @IBOutlet var driverNameBtn: UIButton!
    @IBOutlet var driverRatingBtn: UIButton!
    @IBOutlet var carNameBtn: UIButton!
    @IBOutlet var carNumberBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // Do any additional setup after loading the view.
    }

    private func setupUI() {
        
        setupBackButton()
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        
        driverImage.layer.borderColor = UIColor.borderColor().cgColor
        driverImage.layer.borderWidth = 1.0
        driverImage.layer.cornerRadius = 25
        carImage.layer.borderColor = UIColor.borderColor().cgColor
        carImage.layer.borderWidth = 1.0
        carImage.layer.cornerRadius = 45
        
        driverNameBtn.layer.borderColor = UIColor.borderColor().cgColor
        driverNameBtn.layer.borderWidth = 1.0
        driverNameBtn.layer.cornerRadius = 7
        carNameBtn.layer.borderColor = UIColor.borderColor().cgColor
        carNameBtn.layer.borderWidth = 1.0
        carNameBtn.layer.cornerRadius = 7
        carNumberBtn.layer.borderColor = UIColor.borderColor().cgColor
        carNumberBtn.layer.borderWidth = 1.0
        carNumberBtn.layer.cornerRadius = 7
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
