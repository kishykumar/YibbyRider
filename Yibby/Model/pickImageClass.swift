//
//  pickImageClass.swift
//  Yibby
//
//  Created by Rahul Mehndiratta on 18/03/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit

class PickImageClass: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    
    typealias typeCompletionHandler = (UIImage) -> Void
    var completion : typeCompletionHandler?
    
    
    func showImagePickerActionSheet(viewController : UIViewController, btn : UIButton ) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose Image", message: "", preferredStyle: .actionSheet)
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { action -> Void in
            //Do some other stuff
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            viewController.present(picker, animated: true, completion: nil)
            
        })
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
            //Do some other stuff
            picker.allowsEditing = true
            picker.sourceType = .camera
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            viewController.present(picker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
            
        })
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancelAction)
        
        
        if let presenter = actionSheet.popoverPresentationController {
            presenter.sourceView = btn
            presenter.sourceRect = btn.bounds
        }
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imageSelected : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        print(imageSelected)
        
        picker.dismiss(animated: true, completion: {
            self.completion?(imageSelected)
        })
    }
    
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageSelected : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        print(imageSelected)
        
        picker.dismiss(animated: true, completion: {
            self.completion?(imageSelected)
        })
    }
    */
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: {
            self.completion?(#imageLiteral(resourceName: "Visa"))
        })
        
    }
    
    
    func dismissVCCompletion(viewController : UIViewController, btn : UIButton,completionHandler: @escaping typeCompletionHandler) {
        
        self.showImagePickerActionSheet(viewController: viewController, btn: btn)
        
        self.completion = completionHandler
    }
    
    
}
