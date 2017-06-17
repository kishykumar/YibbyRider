//
//  RiderHistoryVC.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 18/02/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class RiderHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        setupBackButton()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let riderCell = tableView.dequeueReusableCell(withIdentifier: "RiderHistoryTVC", for: indexPath as IndexPath) as UITableViewCell
        
            return riderCell
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
