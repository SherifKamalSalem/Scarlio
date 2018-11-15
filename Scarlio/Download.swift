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

//MARK: Upload Video
func uploadVideo(video: NSData, chatRoomId: String, view: UIView, completion: @escaping(_ videoLink: String?) -> Void) {
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let videoFileName = "VideoMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    let storageRef = storage.reference(forURL: kFILE_REFERENCE).child(videoFileName)
    var task: StorageUploadTask!
    task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        if error != nil {
            print("Error couldn't Upload video \(error?.localizedDescription)")
            return
        }
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadURL = url else {
                completion(nil)
                return
            }
            completion(downloadURL.absoluteString)
        })
    })
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

//MARK: Download Video
func downloadVideo(videoUrl: String, completion: @escaping(_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
    let videoURL = NSURL(string: videoUrl)
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    if fileExistsAtPath(path: videoFileName) {
        print("video exist \(videoFileName)")
        completion(true, videoFileName)
    } else {
        let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
        //Save image to document directory
        downloadQueue.async {
            let data = NSData(contentsOf: videoURL! as URL)
            if data != nil {
                var docURL = getDocumentURL()
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                data?.write(to: docURL, atomically: true)
                DispatchQueue.main.async {
                    completion(true, videoFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print("No video in Firebase DB")
                }
            }
        }
    }
}

//MARK: Upload Audio
func uploadAudio(audioPath: String, chatRoomId: String, view: UIView, completion: @escaping(_ audioLink: String?) -> Void) {
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let audioFileName = "AudioMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".m4a"
    let storageRef = storage.reference(forURL: kFILE_REFERENCE).child(audioFileName)
    var task: StorageUploadTask!
    guard let audio = NSData(contentsOfFile: audioPath) else { return }
    task = storageRef.putData(audio as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        if error != nil {
            print("Error couldn't Upload audio \(error?.localizedDescription)")
            return
        }
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadURL = url else {
                completion(nil)
                return
            }
            completion(downloadURL.absoluteString)
        })
    })
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}


//MARK: Video Thumnail
func videoThumbnail(video: NSURL) -> UIImage {
    let asset = AVURLAsset(url: video as URL)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    var image: CGImage?
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    let thumbnail = UIImage(cgImage: image!)
    return thumbnail
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
