//
//  Camera.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/15/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices


class Camera {
    
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    init(delegate_: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        delegate = delegate_
    }
    
    //MARK: Present Photo Library
    func presentPhotoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            return
        }
        let type = kUTTypeImage as String
        let imageBicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imageBicker.sourceType = .photoLibrary
            if let availableType = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if (availableType as NSArray).contains(type) {
                    imageBicker.mediaTypes = [type]
                    imageBicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imageBicker.sourceType = .savedPhotosAlbum
            if let availableType = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if (availableType as NSArray).contains(type) {
                    imageBicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        imageBicker.allowsEditing = canEdit
        imageBicker.delegate = delegate
        target.present(imageBicker, animated: true, completion: nil)
        return
    }
    
    //MARK: Present Mutly Camera
    func presentMutlyCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        let type1 = kUTTypeImage as String
        let type2 = kUTTypeMovie as String
        
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) {
                    imagePicker.mediaTypes = [type1, type2]
                    imagePicker.sourceType = UIImagePickerController.SourceType.camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Present Photo Camera
    func presentPhotoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        let type1 = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) {
                    imagePicker.mediaTypes = [type1]
                    imagePicker.sourceType = .camera
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Present Video Camera
    func presentVideoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        let type1 = kUTTypeVideo as String
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                if (availableTypes as NSArray).contains(type1) {
                    imagePicker.mediaTypes = [type1]
                    imagePicker.sourceType = .camera
                    imagePicker.videoMaximumDuration = kMAXDURATION
                }
            }
            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Present Video Library
    func presentVideoLibrary(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            return
        }
        let type = kUTTypeMovie as String
        let imageBicker = UIImagePickerController()
        imageBicker.videoMaximumDuration = kMAXDURATION
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imageBicker.sourceType = .photoLibrary
            if let availableType = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if (availableType as NSArray).contains(type) {
                    imageBicker.mediaTypes = [type]
                    imageBicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imageBicker.sourceType = .savedPhotosAlbum
            if let availableType = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if (availableType as NSArray).contains(type) {
                    imageBicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        imageBicker.allowsEditing = canEdit
        imageBicker.delegate = delegate
        target.present(imageBicker, animated: true, completion: nil)
        return
    }
}
