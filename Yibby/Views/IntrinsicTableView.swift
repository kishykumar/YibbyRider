//
//  IntrinsicTableView.swift
//  Yibby
//
//  Created by Kishy Kumar on 6/20/17.
//  Copyright © 2017 Yibby. All rights reserved.
//

import Foundation

public class IntrinsicTableView: UITableView {
    
    override public var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
}
