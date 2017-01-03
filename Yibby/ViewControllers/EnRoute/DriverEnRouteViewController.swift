//
//  DriverEnRouteViewController.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/26/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

import UIKit
import BaasBoxSDK
import CocoaLumberjack
import GoogleMaps
import ISHPullUp

class DriverEnRouteViewController: ISHPullUpViewController {

    
    // MARK: - Setup functions
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        let driverEnRouteStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.DriverEnRoute, bundle: nil)
        
        let contentVC = driverEnRouteStoryboard.instantiateViewController(withIdentifier: "DriverEnRouteContentViewControllerIdentifier") as! DriverEnRouteContentViewController
        
        let bottomVC = driverEnRouteStoryboard.instantiateViewController(withIdentifier: "DriverEnRouteBottomViewControllerIdentifier") as! DriverEnRouteBottomViewController
        
        contentViewController = contentVC
        bottomViewController = bottomVC
        dimmingColor = nil
        
        contentVC.pullUpController = self
        bottomVC.pullUpController = self
        
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
        
//        contentDelegate = contentVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -

}
