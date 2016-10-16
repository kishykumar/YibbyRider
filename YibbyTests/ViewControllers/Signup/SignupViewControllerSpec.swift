//
//  SignupViewControllerSpec.swift
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
import GoogleMaps

class SignupViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("SignupViewController") {
            
            let signupStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.SignUp, bundle: nil)
            var subject = signupStoryboard.instantiateViewControllerWithIdentifier("SignupViewControllerIdentifier") as! SignupViewController
            
            beforeEach {
                // Arrange
                subject = signupStoryboard.instantiateViewControllerWithIdentifier("SignupViewControllerIdentifier") as! SignupViewController
                
                // Act
                _ = subject.view
            }
            
            // Assert
            describe ("Initialization") {
                describe("Storyboard") {
                    
                    it("IBOutlets are  not nil") {
                        expect(subject.nameOutlet).notTo(beNil())
                        expect(subject.emailAddressOutlet).notTo(beNil())
                        expect(subject.phoneNumberOutlet).notTo(beNil())
                        expect(subject.passwordOutlet).notTo(beNil())
                        expect(subject.signupButtonOutlet).notTo(beNil())
                        expect(subject.tandcButtonOutlet).notTo(beNil())
                    }
                    
                    it("IBActions are wired up") {
                        let signupButtonClickActions = subject.signupButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(signupButtonClickActions).to(contain("submitFormButton:"))
                        expect(signupButtonClickActions?.count) == 1
                        
                        let tandcButtonClickActions = subject.tandcButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(tandcButtonClickActions).to(contain("tncButtonAction:"))
                        expect(tandcButtonClickActions?.count) == 1
                    }
                    
                    it("is a BaseYibbyViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyViewController.self))
                    }
                    
                    it("is a SignupViewController") {
                        expect(subject).to(beAKindOf(SignupViewController.self))
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "Launch")
                }
                
                describe("Delegates") {
                    it("are setup") {
                        expect(subject.nameOutlet.delegate as? SignupViewController).to(equal(subject))
                        expect(subject.emailAddressOutlet.delegate as? SignupViewController).to(equal(subject))
                        expect(subject.phoneNumberOutlet.delegate as? SignupViewController).to(equal(subject))
                        expect(subject.passwordOutlet.delegate as? SignupViewController).to(equal(subject))
                    }
                }
            }
            
            // TODO: Delegate tests for SignupPaymentViewControllerDelegate, UITextFieldDelegate
            // TODO: Network call tests for createUser
            // TODO: UI test for Invalid textfield input
            // TODO: UI test for SignupViewController launch
            // TODO: UI Tests for Submit Signup form
            //          - When signup fails
            //          - success
        }
    }
}
