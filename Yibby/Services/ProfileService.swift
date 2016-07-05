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

public typealias ProfileUploadSuccessCompletion = (url: NSURL) -> Void

public struct ProfileService {
    
    public init(){}

    public func updateUserProfilePicture(image: UIImage, success: ProfileUploadSuccessCompletion, failure: ElloFailureCompletion) {
        updateUserImage(image, success: { (url) in
            TemporaryCache.save(.ProfilePicture, image: image)
            success(url: url)
            }, failure: failure)
    }
    
    private func updateUserImage(image: UIImage, success: ProfileUploadSuccessCompletion, failure: ElloFailureCompletion) {

        if let data = UIImageJPEGRepresentation(image, 0.8) {

            let myLocalFile: BAAFile = BAAFile(data: data)
//            myLocalFile.contentType = "image/png"
            myLocalFile.uploadFileWithPermissions(nil, completion: { (file, error) -> Void in
                if error == nil {
                    DDLogVerbose("File uploaded to Baasbox + \(file) + \(file.fileURL())")
                    success(url: file.fileURL())
                }
                else {
                    DDLogVerbose("error in uploading file \(error)")
                    failure(error: error, statusCode: nil)
                }
            })
        }
    }
}
