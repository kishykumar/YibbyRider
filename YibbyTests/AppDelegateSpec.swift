//
//  AppDelegateSpec.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/28/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

@testable import Yibby
import Quick
import Nimble
import IQKeyboardManagerSwift
import GoogleMaps

class AppDelegateSpec: QuickSpec {
    override func spec() {
        describe("AppDelegate") {
            let subject = UIApplication.sharedApplication().delegate as? AppDelegate
            subject?.setupKeyboardManager()
            
            describe("KeyBoardManager") {
                
                it("is enabled") {
                    expect(IQKeyboardManager.sharedManager().enable).to(beTrue())
                }
                
                it("has autotoolbar enabled") {
                    expect(IQKeyboardManager.sharedManager().enableAutoToolbar).to(beFalse())
                }
                
                it("should resign on touch") {
                    expect(IQKeyboardManager.sharedManager().shouldResignOnTouchOutside).to(beTrue())
                }
            }
            
            subject?.setupLocationService()
            describe("LocationService") {
                it("has BEST location accuracy") {
                    expect(LocationService.sharedInstance().locationManager.desiredAccuracy).to(equal(kCLLocationAccuracyBest))
                }
            }
        }
    }
}
