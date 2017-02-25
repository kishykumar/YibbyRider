//
//  LostOrStolenItemVC.swift
//  Yibby
//
//  Created by Rubi Kumari on 25/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class LostOrStolenItemVC: UIViewController {

    
    @IBOutlet var VW: UIView!
    @IBOutlet var VW1: UIView!
    
    @IBOutlet weak var contactDriverBtnOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        VW.layer.borderColor = UIColor.grey5().cgColor
        VW.layer.borderWidth = 1.0
        VW.layer.cornerRadius = 7
        
        VW1.layer.borderColor = UIColor.borderColor().cgColor
        VW1.layer.borderWidth = 1.0
        VW1.layer.cornerRadius = 7
        
        contactDriverBtnOutlet.layer.borderColor = UIColor.borderColor().cgColor
        contactDriverBtnOutlet.layer.borderWidth = 1.0
        contactDriverBtnOutlet.layer.cornerRadius = 7
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
