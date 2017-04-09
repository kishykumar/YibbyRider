//
//  DriversOffer.swift
//  sr
//
//  Created by Rahul Mehndiratta on 30/03/17.
//  Copyright © 2017 Rahul Mehndiratta. All rights reserved.
//

import UIKit
import TTRangeSlider

open class DriversOffer: BaseYibbyViewController, TTRangeSliderDelegate {
    public func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        
        print(selectedMinimum)
    }

    
    @IBOutlet var requestRideBtn: UIButton!

    @IBOutlet weak var rideDetailsVW: UIView!
    
    @IBOutlet weak var driverBidVW: UIView!
    
    @IBOutlet weak var riderCardNumberBtnOutlet: UIButton!
    
    @IBOutlet weak var numberOfPeopleLbl: UILabel!
    
    @IBOutlet weak var totalFareLbl: UILabel!
    
    @IBOutlet weak var ETATimeLbl: UILabel!
    
    
    @IBOutlet weak var driverBidTF: UITextField!
    
    @IBOutlet weak var ETA1Btn: UIButton!
    
    @IBOutlet weak var ETA5Btn: UIButton!
    
    @IBOutlet weak var ETA10Btn: UIButton!
    
    @IBOutlet weak var bidRangeSliderOutlet: TTRangeSlider!
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // currency range slider
        setupRangeSliderUI()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI()
    {
        requestRideBtn.layer.cornerRadius = 7
        
        rideDetailsVW.layer.borderColor = UIColor.lightGray.cgColor
        rideDetailsVW.layer.borderWidth = 1.0
        rideDetailsVW.layer.cornerRadius = 7
        
        let col2 = UIColor(red: 170/255, green: 61/255, blue: 48/255, alpha: 1)
        
        driverBidVW.layer.borderColor = col2.cgColor
        
        driverBidVW.layer.borderWidth = 10.0
        driverBidVW.layer.cornerRadius = driverBidVW.frame.size.width/2
        //156 55 46
        
        driverBidTF.layer.borderColor = UIColor.clear.cgColor
        driverBidTF.layer.borderWidth = 1.0
        driverBidTF.layer.cornerRadius = 7
        
        ETA1Btn.layer.borderColor = UIColor.borderColor().cgColor
        ETA1Btn.layer.borderWidth = 4.0
        ETA1Btn.layer.cornerRadius = ETA1Btn.frame.size.width/2
        //52 188 153
        
        ETA5Btn.layer.borderColor = UIColor.borderColor().cgColor
        ETA5Btn.layer.borderWidth = 4.0
        ETA5Btn.layer.cornerRadius = ETA5Btn.frame.size.width/2
        
        ETA10Btn.layer.borderColor = UIColor.borderColor().cgColor
        ETA10Btn.layer.borderWidth = 4.0
        ETA10Btn.layer.cornerRadius = ETA10Btn.frame.size.width/2
    }

    func setupRangeSliderUI() {
    //currency range slider
        
        bidRangeSliderOutlet.delegate = self
        bidRangeSliderOutlet.minValue = 29
        bidRangeSliderOutlet.maxValue = 70
        bidRangeSliderOutlet.selectedMaximum = 29
        bidRangeSliderOutlet.selectedMaximum = 44
        
        
//    rangeSliderCurrency.delegate = self;
//    self.rangeSliderCurrency.minValue = 29;
//    self.rangeSliderCurrency.maxValue = 70;
//    self.rangeSliderCurrency.selectedMinimum = 29;
//    self.rangeSliderCurrency.selectedMaximum = 70;
//    self.rangeSliderCurrency.handleColor = UIColor.lightGray;
//    self.rangeSliderCurrency.handleDiameter = 30;
//    self.rangeSliderCurrency.selectedHandleDiameterMultiplier = 1.3;
//    NSNumberFormatter *formatter = NSNumberFormatter new;
//    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
//    self.rangeSliderCurrency.numberFormatterOverride = formatter;
//    self.rangeSliderCurrency.handleImage = [UIImage imageNamed:@"custom-handle"];
    //self.rangeSliderCurrency.lineHeight = 10;
    }
    

    /*-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
    if (sender == self.rangeSlider){
    NSLog(@"Standard slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum);
    }
    else if (sender == self.rangeSliderCurrency) {
    NSLog(@"Currency slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum);
    }
    else if (sender == self.rangeSliderCustom){
    NSLog(@"Custom slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum);
    }
    }*/
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func ETA10BtnAction(_ sender: Any) {
    }
    
    @IBAction func ETA5BtnAction(_ sender: Any) {
    }
    
    @IBAction func ETA1BtnAction(_ sender: Any) {
    }
    
    @IBAction func requestRideBtnAction(_ sender: Any) {
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
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
