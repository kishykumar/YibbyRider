//
//  FareIssueViewController.swift
//  Yibby
//
//  Created by Prabhdeep Singh on 7/30/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import UIKit

class FareIssueViewController: UIViewController {
    
    @IBOutlet weak var emailYibbyOutlet: YibbyButton1!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        setupBackButton()
        emailYibbyOutlet.buttonCornerRadius = 5.0
        emailYibbyOutlet.color = UIColor.appDarkGreen1()
    }
    
    @IBAction func onClickContactYibbyView(_ sender: UITapGestureRecognizer) {
        let email = "support@yibby.zohodesk.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
