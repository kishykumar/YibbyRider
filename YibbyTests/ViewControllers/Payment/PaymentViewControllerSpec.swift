//
//  PaymentViewControllerSpec.swift
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
import Braintree

class PaymentViewControllerSpec: QuickSpec {
    override func spec() {
        
        let oldDefaultPaymentMethod = BraintreePaymentService.sharedInstance().defaultPaymentMethod
        
        beforeSuite {
            
        }
        
        afterSuite {
            
        }
        
        describe("PaymentViewController") {
            
            context("ListPayment") {
            
                let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
                var subject = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
                subject.controllerType = .ListPayment
                
                beforeEach {
                    // Arrange
                    subject = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
                    subject.controllerType = .ListPayment
                    
                    // Act
                    _ = subject.view
                }
                
                // Assert
                describe ("Initialization") {
                    describe("Storyboard") {
                        
                        it("IBOutlets are  not nil") {
                            
                        }
                        
                        it("IBActions are wired up") {
    //                        let saveButtonClickActions = subject.saveButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
    //                        expect(saveButtonClickActions).to(contain("saveButtonAction:"))
    //                        expect(saveButtonClickActions?.count) == 1
    //                        
    //                        let cancelButtonClickActions = subject.cancelButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
    //                        expect(cancelButtonClickActions).to(contain("cancelButtonAction:"))
    //                        expect(cancelButtonClickActions?.count) == 1
                        }
                        
                        it("is a BaseYibbyTableViewController") {
                            expect(subject).to(beAKindOf(BaseYibbyTableViewController.self))
                        }
                        
                        it("is a PaymentViewController") {
                            expect(subject).to(beAKindOf(PaymentViewController.self))
                        }
                        
                        it("should have correct number of sections") {
                            expect(subject.numberOfSectionsInTableView(subject.tableView)) == 3
                        }
                        
                        it("should have correct number of rows in cardListSection section") {
                            expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.cardListSection)) == BraintreePaymentService.sharedInstance().paymentMethods.count
                        }
                        
                        it("should have correct number of rows in addPaymentSection section") {
                            expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.addPaymentSection)) == 1
                        }
                        
                        it("should have 0 rows in defaultPaymentSection section when no default payment") {
                            BraintreePaymentService.sharedInstance().defaultPaymentMethod = nil
                            expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.defaultPaymentSection)) == 0
                            
                            // cleanup any state that was set
                            BraintreePaymentService.sharedInstance().defaultPaymentMethod = oldDefaultPaymentMethod
                        }
                        
                        it("should have 1 row in defaultPaymentSection section when we have default payment") {
                            BraintreePaymentService.sharedInstance().defaultPaymentMethod = BTPaymentMethodNonce()
                            expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.defaultPaymentSection)) == 1
                            
                            // cleanup any state that was set
                            BraintreePaymentService.sharedInstance().defaultPaymentMethod = oldDefaultPaymentMethod
                        }
                    }
                    
                    describe("Delegates") {
    //                    it("are setup") {
    //                        expect(subject.emailAddress.delegate as? PaymentViewController).to(equal(subject))
    //                        expect(subject.password.delegate as? PaymentViewController).to(equal(subject))
    //                    }
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "PaymentViewControllerListPaymentAtLaunch")
                }
                
    //            describe("KeychainCredentials") {
    //                
    //                let username = "memyselfandI"
    //                let password = "solorideontillIdie"
    //                
    //                context("can be set/get") {
    //                    beforeEach {
    //                        PaymentViewController.setLoginKeyChainKeys(username, password: password)
    //                    }
    //                    
    //                    it("Get keys") {
    //                        let (myusername, mypassword) = PaymentViewController.getLoginKeyChainValues()
    //                        expect(myusername).to(equal(username))
    //                        expect(mypassword).to(equal(password))
    //                    }
    //                }
    //                
    //                context("can be removed") {
    //                    
    //                    beforeEach {
    //                        PaymentViewController.removeLoginKeyChainKeys()
    //                    }
    //                    
    //                    it("keys should not exist after removal") {
    //                        let (myusername, mypassword) = PaymentViewController.getLoginKeyChainValues()
    //                        
    //                        expect(myusername).to(beNil())
    //                        expect(mypassword).to(beNil())
    //                    }
    //                }
    //            }
                
                // TODO: This whole file needs to be tested as a TableViewDelegate, SelectPaymentViewControllerDelegate
                // TODO: Network call tests for saveCardAction
                // TODO: UI test for Invalid textfield input
                // TODO: UI test for PaymentViewController launch
                // TODO: UI Tests for Submit Login form
                //          - When login fails
                //          - success
            }
            
            context("PickForRide") {
                
                let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
                var subject = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
                subject.controllerType = .PickForRide
                
                beforeEach {
                    // Arrange
                    
                    subject = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
                    subject.controllerType = .PickForRide
                    
                    // Act
                    _ = subject.view
                }
                
                // Assert
                describe ("Initialization") {
                    describe("Storyboard") {
                        
                        it("IBOutlets are  not nil") {
                            expect(subject.cancelButtonOutlet).notTo(beNil())
                        }
                        
                        it("IBActions are wired up") {
                            //                        let saveButtonClickActions = subject.saveButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                            //                        expect(saveButtonClickActions).to(contain("saveButtonAction:"))
                            //                        expect(saveButtonClickActions?.count) == 1
                            //
                            //                        let cancelButtonClickActions = subject.cancelButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                            //                        expect(cancelButtonClickActions).to(contain("cancelButtonAction:"))
                            //                        expect(cancelButtonClickActions?.count) == 1
                        }
                        
                        it("is a BaseYibbyTableViewController") {
                            expect(subject).to(beAKindOf(BaseYibbyTableViewController.self))
                        }
                        
                        it("is a PaymentViewController") {
                            expect(subject).to(beAKindOf(PaymentViewController.self))
                        }
                        
                        it("should have correct number of sections") {
                            expect(subject.numberOfSectionsInTableView(subject.tableView)) == 2
                        }
                        
                        it("should have correct number of rows in cardListSection section") {
                            expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.cardListSection)) == BraintreePaymentService.sharedInstance().paymentMethods.count
                        }
                        
                        it("should have correct number of rows in addPaymentSection section") {
                            expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.addPaymentSection)) == 1
                        }
                    }
                    
                    describe("Delegates") {
                        //                    it("are setup") {
                        //                        expect(subject.emailAddress.delegate as? PaymentViewController).to(equal(subject))
                        //                        expect(subject.password.delegate as? PaymentViewController).to(equal(subject))
                        //                    }
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "PaymentViewControllerPickForRideAtLaunch")
                }
            }
            
            context("PickDefault") {
                
                let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
                var subject = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
                subject.controllerType = .PickDefault
                
                beforeEach {
                    // Arrange
                    
                    subject = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier") as! PaymentViewController
                    subject.controllerType = .PickDefault
                    
                    // Act
                    _ = subject.view
                }
                
                // Assert
                describe ("Initialization") {
                    describe("Storyboard") {
                        
                        it("IBOutlets are  not nil") {
                            expect(subject.saveButtonOutlet).notTo(beNil())
                            expect(subject.cancelButtonOutlet).notTo(beNil())
                        }
                    }
                    
                    it("IBActions are wired up") {
                        //                        let saveButtonClickActions = subject.saveButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        //                        expect(saveButtonClickActions).to(contain("saveButtonAction:"))
                        //                        expect(saveButtonClickActions?.count) == 1
                        //
                        //                        let cancelButtonClickActions = subject.cancelButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        //                        expect(cancelButtonClickActions).to(contain("cancelButtonAction:"))
                        //                        expect(cancelButtonClickActions?.count) == 1
                    }
                    
                    it("is a BaseYibbyTableViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyTableViewController.self))
                    }
                    
                    it("is a PaymentViewController") {
                        expect(subject).to(beAKindOf(PaymentViewController.self))
                    }
                    
                    it("should have correct number of sections") {
                        expect(subject.numberOfSectionsInTableView(subject.tableView)) == 1
                    }
                    
                    it("should have correct number of rows in cardListSection section") {
                        expect(subject.tableView(subject.tableView, numberOfRowsInSection: subject.cardListSection)) == BraintreePaymentService.sharedInstance().paymentMethods.count
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "PaymentViewControllerPickDefaultAtLaunch")
                }
                
                describe("Delegates") {
                    //                    it("are setup") {
                    //                        expect(subject.emailAddress.delegate as? PaymentViewController).to(equal(subject))
                    //                        expect(subject.password.delegate as? PaymentViewController).to(equal(subject))
                    //                    }
                }
            }
        }
    }
}
