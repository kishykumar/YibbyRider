//
//  LeftNavDrawerViewControllerSpec.swift
//  Yibby
//
//  Created by Kishy Kumar on 10/7/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

@testable
import Yibby
import Quick
import Nimble
import Nimble_Snapshots
import CocoaLumberjack

class LeftNavDrawerViewControllerSpec: QuickSpec {
    override func spec() {
        
        beforeSuite {
            
        }
        
        afterSuite {
            
        }
        
        describe("LeftNavDrawerViewController") {
            
            let drawerStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Drawer, bundle: nil)
            var subject = drawerStoryboard.instantiateViewControllerWithIdentifier("LeftNavDrawerViewControllerIdentifier") as! LeftNavDrawerViewController
            
            beforeEach {
                // Arrange
                subject = drawerStoryboard.instantiateViewControllerWithIdentifier("LeftNavDrawerViewControllerIdentifier") as! LeftNavDrawerViewController
                
                // Act
                _ = subject.view
            }
            
            // Assert
            describe ("Initialization") {
                
                describe("Storyboard") {
                    
                    it("IBOutlets are  not nil") {
                        expect(subject.tableView).notTo(beNil())
                        expect(subject.profilePictureOutlet).notTo(beNil())
                        expect(subject.userRealNameLabelOutlet).notTo(beNil())
                        expect(subject.aboutButtonOutlet).notTo(beNil())
                        expect(subject.signOutButtonOutlet).notTo(beNil())
                    }
                    
                    it("IBActions are wired up") {
                        let aboutClickActions = subject.aboutButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(aboutClickActions).to(contain("onAboutButtonClick:"))
                        expect(aboutClickActions?.count) == 1
                        
                        let signoutClickActions = subject.signOutButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(signoutClickActions).to(contain("onSignOutButtonClick:"))
                        expect(signoutClickActions?.count) == 1
                    }
                    
                    it("is a BaseYibbyViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyViewController.self))
                    }
                    
                    it("is a LeftNavDrawerViewController") {
                        expect(subject).to(beAKindOf(LeftNavDrawerViewController.self))
                    }
                    
                    it("should have correct number of rows") {
                        expect(subject.tableView(subject.tableView, numberOfRowsInSection: 0)) == subject.menuItems.count
                    }
                }
                
                describe("Delegates") {
                    it("are setup") {
                        
                    }
                }
            }
            
            describe("snapshots") {
                beforeEach {
                }
                validateAllSnapshots(subject, named: "Launch")
            }
            
            // TODO: Network call tests for onBidButtonClick
            
            // TODO: UI test for Pickup, dropoff markers set
            
            // TODO: UI test for onCenterMarkersButtonClick
            
            // TODO: UI test for LeftNavDrawerViewController launch
            
            // TODO: Network failures simulate and click all buttons - bid, side button, etc
        }
    }
}
