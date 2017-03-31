//
//  ProfileObject.swift
//  Yibby
//
//  Created by Rubi Kumari on 18/03/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class ProfileObject {
    
    var email = ""
    var name = ""
    var phoneNo = ""
    var addHomePlaceName = "Add Home"
    var addWorkPlaceName = "Add Work"
    
    func setProfileData(responseDict: NSDictionary){
        
        print(responseDict)
        
        if responseDict["email"] as? String != nil {
        self.email = responseDict["email"] as! String
        }
        
        if responseDict["name"] as? String != nil {
        self.name = responseDict["name"] as! String
        }
        
        if responseDict["phoneNumber"] as? String != nil {
        self.phoneNo = responseDict["phoneNumber"] as! String
        }
        
        if responseDict["homeLocation"] as? NSDictionary != nil {
            let homeLocationDict = responseDict["homeLocation"] as! NSDictionary
            
            if homeLocationDict.count > 0 {
                if homeLocationDict["name"] as? String != nil {
                    
                    self.addHomePlaceName = homeLocationDict["name"] as! String
                }
            }}
        
        if responseDict["workLocation"] as? NSDictionary != nil {
            let workLocationDict = responseDict["workLocation"] as! NSDictionary
            
            if workLocationDict.count > 0 {
                if workLocationDict["name"] as? String != nil {
                    
                    self.addWorkPlaceName = workLocationDict["name"] as! String
                }
            }}
    }
}
