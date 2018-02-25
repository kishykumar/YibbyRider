//
//  DriverInfoVC.swift
//  sr
//
//  Created by Rahul Mehndiratta on 10/03/17.
//  Copyright © 2017 Rahul Mehndiratta. All rights reserved.
//

import UIKit
import BaasBoxSDK

class DriverInfoVC: BaseYibbyViewController {

    // MARK: - Properties

    @IBOutlet var driverImage: SwiftyAvatar!
    @IBOutlet var carImage: UIImageView!

    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!

    @IBOutlet weak var driverNameLabel: YibbyPaddingLabel!
    @IBOutlet weak var driverRatingLabel: UILabel!

    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!

    var myDriver: YBDriver! // driver details have to be set
    var myDriverVehicle: YBVehicle! // driver details have to be set
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // Do any additional setup after loading the view.
    }

    private func setupUI() {
        
        setupBackButton()
        
        driverNameLabel.text = myDriver.firstName!
        driverRatingLabel.text = myDriver.rating!

        carNameLabel.text = "\(myDriverVehicle.make!) \(myDriverVehicle.model!)"
        carNumberLabel.text = myDriverVehicle.licensePlate!
        
        VW.layer.borderColor = UIColor.borderColor().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        
        carImage.layer.borderColor = UIColor.borderColor().cgColor
        carImage.layer.borderWidth = 1.0
        carImage.layer.cornerRadius = 45
        
        self.driverImage.setImageForName(string: myDriver.firstName!,
                                         backgroundColor: nil,
                                         circular: true,
                                         textAttributes: nil)
        
        if let profilePictureFileId = myDriver.profilePictureFileId {
            
            if (profilePictureFileId != "") {
                if let newUrl = BAAFile.getCompleteURL(withToken: profilePictureFileId) {
                    self.driverImage.pin_setImage(from: newUrl)
                }
            }
        }
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
