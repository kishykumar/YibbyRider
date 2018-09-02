//
//  PromotionsViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 4/5/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import CocoaLumberjack
import MessageUI
import SwiftMessages

class PromotionsViewController: BaseYibbyViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var yebbyCodeTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!
    
    @IBOutlet weak var rideOffView: YibbyBorderedUIView!
    @IBOutlet weak var contactYibbyButtonOutlet: UIButton!
    
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    
    @IBOutlet var accessContactsBtn: UIButton!
    
    let EMAIL_BODY:String = "Referrer details: <Your name> <Your phone number> \n - is referring my friend - \n\n Friend details: <Your friend's name> <Your friend's phone number> \n\n Yibby will make $5 payment to you via Venmo once your friend takes a ride with us. \n\n Please provide your venmo id: <Referrer venmo id>"
    
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
        
        accessContactsBtn.layer.borderColor = UIColor.borderColor().cgColor
        accessContactsBtn.layer.borderWidth = 1.0
        accessContactsBtn.layer.cornerRadius = 7
        
        /*let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y:  yebbyCodeTF.frame.height - 1, width: yebbyCodeTF.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        yebbyCodeTF.borderStyle = UITextBorderStyle.none
        yebbyCodeTF.layer.addSublayer(bottomLine)
        
        let bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: 0.0, y:  emailAddressTF.frame.height - 1, width: emailAddressTF.frame.width, height: 1.0)
        
        bottomLine1.backgroundColor = UIColor.lightGray.cgColor
        emailAddressTF.borderStyle = UITextBorderStyle.none
        emailAddressTF.layer.addSublayer(bottomLine1)*/
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func contactYibbyButtonAction(_ sender: UIButton) {
//        let email = "support@yibby.zohodesk.com"
//        if let url = URL(string: "mailto:\(email)") {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        sendEmail()
    }
    
    func sendEmail(){
        if !MFMailComposeViewController.canSendMail(){
            DDLogVerbose("Mail services are not available")
            ToastUtil.displayToastOnVC(self, title: "Mail account not configured", body: "Mail Services are not available. Please configure a mail account to send Referrals", theme: .warning, presentationStyle: .center, duration: .seconds(seconds: 5), windowLevel: UIWindowLevelNormal)
            return
        }
        let composeVc = MFMailComposeViewController()
        composeVc.mailComposeDelegate = self
        composeVc.setToRecipients(["support@yibby.zohodesk.com"])
        composeVc.setSubject("Yibby Referral")
        composeVc.setMessageBody(EMAIL_BODY, isHTML: false)
        self.present(composeVc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //body

    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
