//
//  SelectorView.swift
//  JOEmojiableBtn
//
//  Created by Jorge Raul Ovalle Zuleta on 2/28/16.
//  Copyright © 2016 jorgeovalle. All rights reserved.
//

import UIKit

public protocol SelectorViewDelegate{
//    func movedTo(point:CGPoint)
    func endTouch(point:CGPoint)
}

public class SelectorView: UIView {
    var delegate:SelectorViewDelegate?
//    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        delegate?.movedTo((touches.first?.locationInView(self))!)
//    }
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.endTouch((touches.first?.locationInView(self))!)
    }
}
