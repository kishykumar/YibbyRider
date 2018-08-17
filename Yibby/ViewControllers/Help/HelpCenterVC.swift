//
//  HelpCenterVC.swift
//  sr
//
//  Created by Rahul Mehndiratta on 10/03/17.
//  Copyright © 2017 Rahul Mehndiratta. All rights reserved.
//

import UIKit

class HelpCenterVC: BaseYibbyViewController {

    @IBOutlet var lostStolenItemBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        // Do any additional setup after loading the view.
    }

    private func setupUI() {
        setupBackButton()

        lostStolenItemBtn.layer.borderColor = UIColor.borderColor().cgColor
        lostStolenItemBtn.layer.borderWidth = 1.0
        lostStolenItemBtn.layer.cornerRadius = 7

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func lostStolenItemBtnAction(_ sender: Any) {
        let historyStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.History, bundle: nil)
        let fareIssueViewController = historyStoryboard.instantiateViewController(withIdentifier: "FareIssueViewController") as! FareIssueViewController
        self.navigationController?.pushViewController(fareIssueViewController, animated: true)
        
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
