//
//  DriverEnRouteBottomViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 12/15/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import UIKit
import ISHPullUp
import CocoaLumberjack

class DriverEnRouteBottomViewController: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var rootViewOutlet: UIView!
    @IBOutlet weak var topViewOutlet: UIView!
    
    private var firstAppearanceCompleted = false
    weak var pullUpController: ISHPullUpViewController!
    
    private var currentHeight = CGFloat(0)
    
    static let PULLUP_VIEW_PERCENT_OF_SCREEN: CGFloat = 0.45 // 45%
    private var pullupViewTargetHeight: CGFloat!
    
    // MARK: - Actions
    
    private dynamic func handleTapGesture(gesture: UITapGestureRecognizer) {
        pullUpController.toggleState(animated: true)
    }
    
    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topViewOutlet.addGestureRecognizer(tapGesture)
        
        let screenSize: CGRect = UIScreen.main.bounds
        pullupViewTargetHeight = DriverEnRouteBottomViewController.PULLUP_VIEW_PERCENT_OF_SCREEN * screenSize.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true
        pullUpController.setState(.expanded, animated: false)
        currentHeight = pullupViewTargetHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ISHPullUpSizingDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        
        return pullupViewTargetHeight
//        return rootViewOutlet.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        
        return pullupViewTargetHeight/4
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        
        let collapsedHeight = pullupViewTargetHeight/4
//        let rootViewHeight = rootViewOutlet.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        if (height > pullupViewTargetHeight) {
            return height
        }
        
        if (height < currentHeight) {
            currentHeight = collapsedHeight
            return collapsedHeight
        }
        
        if (height > currentHeight) {
            currentHeight = pullupViewTargetHeight
            return pullupViewTargetHeight
        }
        
        // default behaviour...should not reach here.
        return height
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController bottomVC: UIViewController) {
        // we update the scroll view's content inset
        // to properly support scrolling in the intermediate states
        
    }
    
    // MARK: ISHPullUpStateDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
//        topLabel.text = textForState(state);
    }

    @IBAction func driverInfoBtnAction(_ sender: Any) {        
        let DriverInfoNVC = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoVC") as! DriverInfoVC
        _ = self.navigationController?.pushViewController(DriverInfoNVC, animated: true)
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
