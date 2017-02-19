//
//  ProfileService.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/3/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

import SwiftyJSON
import BaasBoxSDK
import CocoaLumberjack

public typealias ProfileUploadSuccessCompletion = (_ url: URL) -> Void

public struct ProfileService {
    
    public init(){}

    public func updateUserProfilePicture(_ image: UIImage, success: @escaping ProfileUploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        updateUserImage(image, success: { (url) in
            TemporaryCache.save(.profilePicture, image: image)
            success(url)
            }, failure: failure)
    }
    
    fileprivate func updateUserImage(_ image: UIImage, success: @escaping ProfileUploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {

        if let data = UIImageJPEGRepresentation(image, 0.8) {

            let myLocalFile: BAAFile = BAAFile(data: data)
//            myLocalFile.contentType = "image/png"
            myLocalFile.uploadFile(withPermissions: nil, completion: { (file, error) -> Void in
                if error == nil {
                    DDLogVerbose("File uploaded to Baasbox + \(file) + \((file as! BAAFile).fileURL())")
                    success((file as! BAAFile).fileURL())
                }
                else {
                    DDLogVerbose("error in uploading file \(error)")
                    failure(error as! NSError, nil)
                }
            })
        }
    }
}
