//
//  RideEndViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/14/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit

class RideEndViewController: BaseYibbyViewController {

    @IBOutlet var carImage: UIImageView!
    @IBOutlet var driverImage: UIImageView!
    @IBOutlet var mapImage: UIImageView!
    
    @IBOutlet var rideDateLbl: UILabel!
    @IBOutlet var carNumberLbl: UILabel!
    @IBOutlet var rideFareBtn: UILabel!
    
    @IBOutlet var finishBtn: UIButton!
    
    @IBOutlet var tipVW: UIView!
    
    
    @IBOutlet var star1Btn: UIButton!
    @IBOutlet var star2Btn: UIButton!
    @IBOutlet var star3Btn: UIButton!
    @IBOutlet var star4Btn: UIButton!
    @IBOutlet var star5Btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        self.customBackButton(y: 20 as AnyObject)
        
        carImage.layer.borderColor = UIColor.borderColor().cgColor
        carImage.layer.borderWidth = 1.0
        carImage.layer.cornerRadius = carImage.frame.size.width/2-4
        
        driverImage.layer.borderColor = UIColor.borderColor().cgColor
        driverImage.layer.borderWidth = 1.0
        driverImage.layer.cornerRadius = 25
        
        mapImage.layer.borderColor = UIColor.borderColor().cgColor
        mapImage.layer.borderWidth = 1.0
        mapImage.layer.cornerRadius = mapImage.frame.size.width/2-4
        
        //finishBtn.layer.borderColor = UIColor.lightGray.cgColor
        //finishBtn.layer.borderWidth = 1.0
        finishBtn.layer.cornerRadius = 7
        
        tipVW.layer.borderColor = UIColor.lightGray.cgColor
        tipVW.layer.borderWidth = 1.0
        tipVW.layer.cornerRadius = 7
    }
    
    
    @IBAction func finishBtnAction(_ sender: Any) {
    }
    
    @IBAction func rateStarDriverBtnAction(_ sender: AnyObject) {
        
        if sender.tag == 0
        {
            star1Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star2Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            star3Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            star4Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            star5Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        else if sender.tag == 1
        {
            star1Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star2Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star3Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            star4Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            star5Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        else if sender.tag == 2
        {
            star1Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star2Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star3Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star4Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            star5Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        else if sender.tag == 3
        {
            star1Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star2Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star3Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star4Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star5Btn.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        else if sender.tag == 4
        {
            star1Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star2Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star3Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star4Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            star5Btn.setTitleColor(UIColor.yellow, for: UIControlState.normal)
        }
    }
    
    
    @IBAction func newPriceInTipBtnAction(_ sender: Any) {
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
