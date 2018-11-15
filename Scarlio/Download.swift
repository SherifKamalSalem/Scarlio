//
//  Download.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/15/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation


let storage = Storage.storage()

//MARK: Upload Images
func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping (_ imageLink: String?) -> Void) {
    let progress = MBProgressHUD.showAdded(to: view, animated: true)
    progress.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    let storageRef = storage.reference(forURL: kFILE_REFERENCE).child(photoFileName)
    let imageData = image.jpegData(compressionQuality: 0.7)
    var task: StorageUploadTask!
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progress.hide(animated: true)
        if error != nil {
            print("Error uploading images")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            completion(downloadUrl.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        //make percentage of uploaded files
        progress.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

//MARK: Download Images
func downloadImage(imageUrl: String, completion: @escaping(_ image: UIImage?) -> Void) {
    let imageURL = NSURL(string: imageUrl)
    let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    if fileExistsAtPath(path: imageFileName) {
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)) {
            completion(contentsOfFile)
        } else {
            print("couldn't generate image")
        }
    } else {
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        //Save image to document directory
        downloadQueue.async {
            let data = NSData(contentsOf: imageURL! as URL)
            if data != nil {
                var docURL = getDocumentURL()
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                data?.write(to: docURL, atomically: true)
                let imageToReturn = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    guard let imageToReturn = imageToReturn else { return }
                    completion(imageToReturn)
                }
            } else {
                DispatchQueue.main.async {
                    print("No image in Firebase DB")
                    completion(nil)
                }
            }
        }
    }
}

//MARK: check if the image in file directory
func fileInDocumentDirectory(fileName: String) -> String {
    let fileURL = getDocumentURL().appendingPathComponent(fileName)
    return fileURL.path
}

func getDocumentURL() -> URL {
    let DocURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return DocURL!
}

func fileExistsAtPath(path: String) -> Bool {
    var doesExist = false
    let filePath = fileInDocumentDirectory(fileName: path)
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
}
