//
//  LoginViewControllerSpec.swift
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

class LoginViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("LoginViewController") {
            
            let loginStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Login, bundle: nil)
            var subject = loginStoryboard.instantiateViewControllerWithIdentifier("LoginViewControllerIdentifier") as! LoginViewController
            
            beforeEach {
                // Arrange
                subject = loginStoryboard.instantiateViewControllerWithIdentifier("LoginViewControllerIdentifier") as! LoginViewController
                
                // Act
                _ = subject.view
            }
            
            // Assert
            describe ("Initialization") {
                describe("Storyboard") {
                    
                    it("IBOutlets are  not nil") {
                        expect(subject.emailAddress).notTo(beNil())
                        expect(subject.password).notTo(beNil())
                        expect(subject.loginButtonOutlet).notTo(beNil())
                    }
                    
                    it("IBActions are wired up") {
                        let loginButtonClickActions = subject.loginButtonOutlet.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(loginButtonClickActions).to(contain("loginAction:"))
                        expect(loginButtonClickActions?.count) == 1
                    }
                    
                    it("is a BaseYibbyViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyViewController.self))
                    }
                    
                    it("is a LoginViewController") {
                        expect(subject).to(beAKindOf(LoginViewController.self))
                    }
                }
                
                describe("snapshots") {
                    beforeEach {
                    }
                    validateAllSnapshots(subject, named: "Launch")
                }
                
                describe("Delegates") {
                    it("are setup") {
                        expect(subject.emailAddress.delegate as? LoginViewController).to(equal(subject))
                        expect(subject.password.delegate as? LoginViewController).to(equal(subject))
                    }
                }
            }
            
            describe("KeychainCredentials") {
                
                let username = "memyselfandI"
                let password = "solorideontillIdie"
                
                context("can be set/get") {
                    beforeEach {
                        LoginViewController.setLoginKeyChainKeys(username, password: password)
                    }
                    
                    it("Get keys") {
                        let (myusername, mypassword) = LoginViewController.getLoginKeyChainValues()
                        expect(myusername).to(equal(username))
                        expect(mypassword).to(equal(password))
                    }
                }
                
                context("can be removed") {
                    
                    beforeEach {
                        LoginViewController.removeLoginKeyChainKeys()
                    }
                    
                    it("keys should not exist after removal") {
                        let (myusername, mypassword) = LoginViewController.getLoginKeyChainValues()
                        
                        expect(myusername).to(beNil())
                        expect(mypassword).to(beNil())
                    }
                }
            }
            
            // TODO: Delegate tests for UITextFieldDelegate
            // TODO: Network call tests for loginUser
            // TODO: UI test for Invalid textfield input
            // TODO: UI test for LoginViewController launch
            // TODO: UI Tests for Submit Login form
            //          - When login fails
            //          - success
        }
    }
}
