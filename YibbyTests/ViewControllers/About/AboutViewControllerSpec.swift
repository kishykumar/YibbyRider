//
//  AboutViewControllerSpec.swift
//  Yibby
//
//  Created by Kishy Kumar on 10/7/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

@testable
import Yibby
import Quick
import Nimble
import Nimble_Snapshots

class AboutViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("AboutViewController") {
            
            let aboutStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.About, bundle: nil)
            var subject = aboutStoryboard.instantiateViewControllerWithIdentifier("AboutViewControllerIdentifier") as! AboutViewController
            
            beforeEach {
                // Arrange
                subject = aboutStoryboard.instantiateViewControllerWithIdentifier("AboutViewControllerIdentifier") as! AboutViewController
                
                // Act
                _ = subject.view
            }
            
            // Assert
            describe ("Initialization") {
                describe("Storyboard") {
                    
                    it("IBOutlets are  not nil") {
//                        expect(subject.gmsMapViewOutlet).notTo(beNil())
                    }
                    
                    it("IBActions are wired up") {
//                        let bidActions = subject.bidButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
//                        expect(bidActions).to(contain("onBidButtonClick:"))
//                        expect(bidActions?.count) == 1
                    }
                    
                    it("is a BaseYibbyViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyViewController.self))
                    }
                    
                    it("is a AboutViewController") {
                        expect(subject).to(beAKindOf(AboutViewController.self))
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "Launch")
                }
                
                describe("Delegates") {
                    it("are setup") {
//                        expect(subject.gmsMapViewOutlet.delegate as? AboutViewController).to(equal(subject))
//                        expect(subject.peopleButtonOutlet.delegate as? AboutViewController).to(equal(subject))
                    }
                }
                
                describe("Map") {
                    it("is setup") {
//                        expect(subject.gmsMapViewOutlet.myLocationEnabled).to(beTrue())
//                        expect(subject.gmsMapViewOutlet.settings.consumesGesturesInView).to(beTrue())
                    }
                }
            }
            
            // TODO: Delegate tests
            
            // TODO: Network call tests for onBidButtonClick
            
            // TODO: UI test for AboutViewController launch
            
            // TODO: Network failures simulate and click all buttons - bid, side button, etc
        }
    }
}
