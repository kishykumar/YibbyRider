//
//  AddAddPaymentViewControllerSpec.swift
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

class AddPaymentViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("AddPaymentViewController") {
            
            let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
            var subject = paymentStoryboard.instantiateViewControllerWithIdentifier("AddPaymentViewControllerIdentifier") as! AddPaymentViewController
            
            beforeEach {
                // Arrange
                subject = paymentStoryboard.instantiateViewControllerWithIdentifier("AddPaymentViewControllerIdentifier") as! AddPaymentViewController
                
                // Act
                _ = subject.view
            }
            
            // Assert
            describe ("Initialization") {
                describe("Storyboard") {
                    
                    it("IBOutlets are  not nil") {
                        expect(subject.cardFieldsViewOutlet).notTo(beNil())
                        expect(subject.deleteCardButtonOutlet).notTo(beNil())
                        expect(subject.saveCardButtonOutlet).notTo(beNil())
                        expect(subject.cancelButtonOutlet).notTo(beNil())
                        expect(subject.scanCardButtonOutlet).notTo(beNil())
                    }
                    
                    it("IBActions are wired up") {
                        let deleteButtonClickActions = subject.deleteCardButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(deleteButtonClickActions).to(contain("deleteCardAction:"))
                        expect(deleteButtonClickActions?.count) == 1
                        
                        let scanCardButtonClickActions = subject.scanCardButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(scanCardButtonClickActions).to(contain("scanCardAction:"))
                        expect(scanCardButtonClickActions?.count) == 1
                        
//                        TODO: Wire up the navbar tab item actions
                    }
                    
                    it("is a BaseYibbyViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyViewController.self))
                    }
                    
                    it("is a AddPaymentViewController") {
                        expect(subject).to(beAKindOf(AddPaymentViewController.self))
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "Launch")
                }
                
                describe("Delegates") {
                    //                    it("are setup") {
                    //                        expect(subject.emailAddress.delegate as? AddPaymentViewController).to(equal(subject))
                    //                        expect(subject.password.delegate as? AddPaymentViewController).to(equal(subject))
                    //                    }
                }
            }
            
            //            describe("KeychainCredentials") {
            //
            //                let username = "memyselfandI"
            //                let password = "solorideontillIdie"
            //
            //                context("can be set/get") {
            //                    beforeEach {
            //                        AddPaymentViewController.setLoginKeyChainKeys(username, password: password)
            //                    }
            //
            //                    it("Get keys") {
            //                        let (myusername, mypassword) = AddPaymentViewController.getLoginKeyChainValues()
            //                        expect(myusername).to(equal(username))
            //                        expect(mypassword).to(equal(password))
            //                    }
            //                }
            //
            //                context("can be removed") {
            //
            //                    beforeEach {
            //                        AddPaymentViewController.removeLoginKeyChainKeys()
            //                    }
            //
            //                    it("keys should not exist after removal") {
            //                        let (myusername, mypassword) = AddPaymentViewController.getLoginKeyChainValues()
            //
            //                        expect(myusername).to(beNil())
            //                        expect(mypassword).to(beNil())
            //                    }
            //                }
            //            }
            
            // TODO: This whole file needs to be tested as a TableViewDelegate, SelectAddPaymentViewControllerDelegate
            // TODO: Network call tests for saveCardAction
            // TODO: UI test for Invalid textfield input
            // TODO: UI test for AddPaymentViewController launch
            // TODO: UI Tests for Submit Login form
            //          - When login fails
            //          - success
        }
    }
}
