//
//  ConfirmRideViewControllerSpec.swift
//  Yibby
//
//  Created by Kishy Kumar on 10/7/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

@testable
import Yibby
import Quick
import Nimble
import FBSnapshotTestCase

class ConfirmRideViewControllerSpec: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        recordMode = true
    }
    
    func testCellConfiguration() {
        let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
        
        let subject = biddingStoryboard.instantiateViewControllerWithIdentifier("ConfirmRideViewControllerIdentifier") as!
            ConfirmRideViewController
        
        _ = subject.view

//        FBSnapshotVerifyView(subject.view)
    }
}
