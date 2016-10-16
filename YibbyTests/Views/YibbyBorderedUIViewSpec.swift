//
//  YibbyBorderedUIViewSpec.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/29/16.
//  Copyright © 2016 MyComp. All rights reserved.
//

@testable import Yibby
import Quick
import Nimble

class YibbyBorderedUIViewSpec: QuickSpec {
    override func spec() {
        describe("Properties") {
            it("are valid") {
                let borderedView = YibbyBorderedUIView(frame: CGRectZero)
                
                expect(borderedView.layer.cornerRadius) > 0
                expect(borderedView.layer.shadowOpacity) > 0
                expect(borderedView.layer.shadowRadius) > 0
            }
        }
    }
}
