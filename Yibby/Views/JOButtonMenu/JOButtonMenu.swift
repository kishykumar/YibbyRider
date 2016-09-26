//
//  JOButtonMenu.swift
//  JOButtonMenu
//
//  Created by Jorge Raul Ovalle Zuleta on 2/28/16.
//  Copyright © 2016 jorgeovalle. All rights reserved.
//

import UIKit

/**
 *  Control's configuration, details on Github https://github.com/lojals/JOButtonMenu
 */
public struct JOButtonMenuConfig{
    var spacing:CGFloat
    var size:CGFloat
    var minSize:CGFloat
    var maxSize:CGFloat
    var s_options_selector:CGFloat
    
    public init(spacing:CGFloat,size:CGFloat,minSize:CGFloat,maxSize:CGFloat,s_options_selector:CGFloat){
        self.spacing            = spacing
        self.size               = size
        self.minSize            = minSize
        self.maxSize            = maxSize
        self.s_options_selector = s_options_selector
    }
}

/**
 *  TODO: use name value to create Option's labels
 */
public struct JOButtonMenuOption{
    var labelText:String
    
    public init(labelText:String){
        self.labelText = labelText
    }
}

public protocol JOButtonMenuDelegate{
    func selectedOption(sender:JOButtonMenu,index:Int)
    func canceledAction(sender:JOButtonMenu)
}

public class JOButtonMenu: UIButton {
    public var delegate:JOButtonMenuDelegate!
    public var dataset:[JOButtonMenuOption]!
    
    var singleTap:UITapGestureRecognizer!
    var drag:UIPanGestureRecognizer!
    
    var active:Bool!
    var selectedItem:Int!
    var bgClear:SelectorView!
    var options:UIView!
    var origin:CGPoint!
    
    let spacing:CGFloat
    let size:CGFloat
    let minSize:CGFloat
    let maxSize:CGFloat
    let s_options_selector:CGFloat
    
    /**
     Initialization with parameters as default (Facebook reactions iOS App)
     
     - parameter frame: Frame of the button will open the selector
     
     */
    
    required public init?(coder aDecoder: NSCoder) {
        self.spacing            = 6
        self.size               = 40
        self.minSize            = 34
        self.maxSize            = 80
        self.s_options_selector = 30
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    public override init(frame: CGRect) {
        self.spacing            = 6
        self.size               = 40
        self.minSize            = 34
        self.maxSize            = 80
        self.s_options_selector = 30
        super.init(frame: frame)
        self.initialize()
    }
    
    /**
     Initialization with Custom sizes check Documentation Github project
     
     - parameter frame: Frame of the button will open the selector
     - parameter config: JOButtonMenuConfig value with custom sizes
     */
    
    public init(frame: CGRect, config:JOButtonMenuConfig){
        self.spacing            = config.spacing
        self.size               = config.size
        self.minSize            = config.minSize
        self.maxSize            = config.maxSize
        self.s_options_selector = config.s_options_selector
        super.init(frame: frame)
        self.initialize()
    }
    
    private func initialize(){
        singleTap = UITapGestureRecognizer(target: self, action: #selector(JOButtonMenu.singleTapEvent))
        self.addGestureRecognizer(singleTap)
        self.layer.masksToBounds = false
        active = false
    }
    
    func singleTapEvent(){
        if !active {
            activate()
        } else {
            self.deActivate(-1)
        }
    }
    
    func buttonTapEvent(sender: UITapGestureRecognizer) {
        let selectedView = sender.view
        selectIndex(selectedView!.tag)
        self.deActivate(selectedItem)
    }
    
    /**
     Function that open the Options Selector
     */
    private func activate() {
        if !active {
            if dataset != nil {
                let frameSV = UIScreen.mainScreen().bounds
                selectedItem = -1
                active = true
                bgClear = SelectorView(frame: frameSV)
                bgClear.delegate = self
                bgClear.backgroundColor = UIColor.clearColor()

                origin = self.superview?.convertPoint(self.frame.origin, toView: nil)
                
                let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let vvc = appDelegate.window!.visibleViewController {
                    vvc.view?.addSubview(bgClear)
                } else {
                    return
                }

                let sizeBtn:CGSize = CGSize(width: ((CGFloat(dataset.count+1)*spacing)+(size*CGFloat(dataset.count))), height: size+(2*spacing))
                
                options = UIView(frame: CGRectMake(frameSV.size.width/2 - sizeBtn.width/2,
                                                    origin.y - (sizeBtn.height),
                                                    sizeBtn.width,
                                                    sizeBtn.height))
                
                options.layer.cornerRadius  = options.frame.height/2
                options.backgroundColor     = UIColor.whiteColor()
                options.layer.shadowColor   = UIColor.lightGrayColor().CGColor
                options.layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
                options.layer.shadowOpacity = 0.5
                options.alpha               = 0.3
                bgClear.addSubview(options)
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.options.frame.origin.y = self.origin.y - (self.s_options_selector + sizeBtn.height)
                    self.options.alpha          = 1
                })
                
                if dataset.count <= 0 {
                    return
                }
                
                for i in 0...dataset.count-1 {
                    
                    // Create a circle view
                    let option = UIView(frame: CGRectMake((CGFloat(i+1) * spacing) + (size * CGFloat(i)),
                                                            self.spacing,
                                                            self.size,
                                                            self.size))
                    
                    option.layer.cornerRadius = self.size/2
                    option.layer.borderWidth = 1.0
                    option.layer.borderColor = UIColor.redColor().CGColor
                    
                    option.tag = i
                    
                    let myTap = UITapGestureRecognizer(target: self, action: #selector(JOButtonMenu.buttonTapEvent(_:)))
                    option.addGestureRecognizer(myTap)
                    
                    options.addSubview(option)
                    
                    // Add the label to the circle view
                    let countLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 15))
                    
                    countLabel.text = dataset[i].labelText
                    countLabel.font = UIFont.boldSystemFontOfSize(15.0)
                    countLabel.textColor = UIColor.darkGrayColor()
                    countLabel.textAlignment = NSTextAlignment.Center

                    option.addSubview(countLabel)
                    
                    option.center = CGPoint(x: (CGFloat(i+1)*self.spacing)+(self.size*CGFloat(i))+self.size/2, y: self.spacing+self.size/2)
                
                    countLabel.center = CGPointMake(option.bounds.size.width  / 2,
                                                    option.bounds.size.height / 2);
                    
                }
            }
            else{
                print("Please, initialize the dataset.")
            }
        }
    }
    
    /**
     Function that close the Options Selector
     */
    private func deActivate(optionIdx:Int){
        
        // If invalid index, then remove the popup view
        if (optionIdx < 0) {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                self.options.alpha          = 0
                self.options.frame.origin.y = self.origin.y - (self.size+(2*self.spacing))
                
                },completion:  { (finished) -> Void in
                    
                    self.active = false
                    self.bgClear.removeFromSuperview()
                    
                    self.delegate.canceledAction(self)
            })
            
            return
        }
        
        // Valid index: animate
        for (i,option) in self.options.subviews.enumerate(){

            if (optionIdx == i) {

                UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in

                    option.center = CGPoint(x: (CGFloat(i+1) * self.spacing) + (self.size * CGFloat(i)) + (self.size / 2),
                                            y: -self.options.frame.height + (self.size / 2))
                    
                    }, completion:  { (finished) -> Void in
                        if finished {
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                
                                self.options.alpha          = 0
                                self.options.frame.origin.y = self.origin.y - (self.size+(2*self.spacing))
                                
                                }, completion:  { (finished) -> Void in
                                    
                                    self.active = false
                                    self.bgClear.removeFromSuperview()
                                    
                                    self.delegate.selectedOption(self, index: self.selectedItem)
                            })
                        }
                })
                break
            }
        }
    }
    
//    private func loseFocus(){
//        selectedItem = -1
//        
//        let frameSV = UIScreen.mainScreen().bounds
//
//        UIView.animateWithDuration(0.3) { () -> Void in
//            
//            let sizeBtn:CGSize = CGSize(width: ((CGFloat(self.dataset.count+1)*self.spacing)+(self.size*CGFloat(self.dataset.count))), height: self.size+(2*self.spacing))
//            
//            self.options.frame = CGRectMake(frameSV.size.width/2 - sizeBtn.width/2,
//                                            self.origin.y - (self.s_options_selector+sizeBtn.height),
//                                            sizeBtn.width,
//                                            sizeBtn.height)
//            
//            self.options.layer.cornerRadius = sizeBtn.height/2
//            
//            for (idx,view) in self.options.subviews.enumerate(){
//                view.frame = CGRectMake((CGFloat(idx+1)*self.spacing)+(self.size*CGFloat(idx)),self.spacing,self.size,self.size)
//            }
//        }
//    }
    
    func selectIndex(index:Int){
        if index >= 0 && index < dataset.count {
            selectedItem = index
        }
    }
}

extension JOButtonMenu:SelectorViewDelegate {
    /**
     Function that track the user's touch, and help to find the selection user want to do.
     
     - parameter point: user's touch point
     */
//    public func movedTo(point:CGPoint){
//        let t = options.frame.width/CGFloat(dataset.count)
//        
//        if (point.y < (options.frame.minY - 50)/* || point.y > (information.frame.maxY + 30)*/){
//            loseFocus()
//        }else{
//            if (point.x-origin.x > 0 && point.x < options.frame.maxX){
//                selectIndex(Int(round((point.x-origin.x)/t)))
//            }else{
//                loseFocus()
//            }
//        }
//    }
    
    public func endTouch(point:CGPoint){

        // If the touch falls in the options frame
        if (point.x > 0 && point.x < options.frame.maxX){
            self.deActivate(selectedItem)
        } else {
            // Touch not in options frame
            self.deActivate(-1)
        }
    }
}
