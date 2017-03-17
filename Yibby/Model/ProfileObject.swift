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
    
    
    func setProfileData(responseDict: NSDictionary){
     
        print(responseDict)
        self.email = responseDict["email"] as! String
        self.name = responseDict["name"] as! String
        self.phoneNo = responseDict["phoneNumber"] as! String  
    }
    
    
    
    
}
