//
//  PromotionsViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack

class PromotionsViewController: BaseYibbyViewController {

    @IBOutlet weak var yebbyCodeTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!

    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    
    @IBOutlet var accessContactsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        VW.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        VW1.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        
        accessContactsBtn.layer.borderColor = UIColor(netHex: 0x31A343).CGColor
        accessContactsBtn.layer.borderWidth = 1.0
        accessContactsBtn.layer.cornerRadius = 7
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, yebbyCodeTF.frame.height - 1, yebbyCodeTF.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.lightGrayColor().CGColor
        yebbyCodeTF.borderStyle = UITextBorderStyle.None
        yebbyCodeTF.layer.addSublayer(bottomLine)
        
        let bottomLine1 = CALayer()
        bottomLine1.frame = CGRectMake(0.0, emailAddressTF.frame.height - 1, emailAddressTF.frame.width, 1.0)
        bottomLine1.backgroundColor = UIColor.lightGrayColor().CGColor
        emailAddressTF.borderStyle = UITextBorderStyle.None
        emailAddressTF.layer.addSublayer(bottomLine1)
        
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
