//
//  IncomingMessages.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/14/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessages {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    //MARK: Create messages
    func createMessage(messages: NSDictionary, chatRoomId: String) -> JSQMessage? {
        var message: JSQMessage?
        let type = messages[kTYPE] as! String
        switch type {
        case kTEXT:
            message = createTextMessage(messages: messages, chatRoomId: chatRoomId)
        case kAUDIO:
            message = createAudioMessage(messages: messages)
        case kPICTURE:
            message = createPictureMessage(messages: messages)
        case kVIDEO:
            message = createMovieMessage(messages: messages)
        case kLOCATION:
            message = createLocationMessage(messages: messages)
        default:
            print("Unkown msg type")
        }
        
        if message != nil {
            return message
        }
        return nil
    }
    
    //MARK: Create messages types
    func createTextMessage(messages: NSDictionary, chatRoomId: String) -> JSQMessage? {
        let name = messages[kSENDERNAME] as? String
        let userId = messages[kSENDERID] as? String
        
        var date: Date!
        if let createdAt = messages[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdAt as! String)
            }
        } else {
            date = Date()
        }
        
        let text = messages[kMESSAGE] as! String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    //MARK: creating picture msg
    func createPictureMessage(messages: NSDictionary) -> JSQMessage? {
        let name = messages[kSENDERNAME] as? String
        let userId = messages[kSENDERID] as? String
        var date: Date!
        if let createdAt = messages[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdAt as! String)
            }
        } else {
            date = Date()
        }
        //Customize image according to portrait or landscape mode
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = outGoingStatusFor(senderId: userId!)
        
        downloadImage(imageUrl: messages[kPICTURE] as! String) { (image) in
            if image != nil {
                mediaItem?.image = image
                self.collectionView.reloadData()
            }
        }
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    //MARK: create video msg
    func createMovieMessage(messages: NSDictionary) -> JSQMessage? {
        let name = messages[kSENDERNAME] as? String
        let userId = messages[kSENDERID] as? String
        var date: Date!
        if let createdAt = messages[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdAt as! String)
            }
        } else {
            date = Date()
        }
        let videoURL = NSURL(fileURLWithPath: messages[kVIDEO] as! String)
        //Customize image according to portrait or landscape mode
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: outGoingStatusFor(senderId: userId!))
        //call download video func
        downloadVideo(videoUrl: messages[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentDirectory(fileName: fileName))
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            imageFromData(pictureData: (messages[kTHUMBNAIL] as! NSString) as String, withBlock: { (image) in
                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                }
            })
            self.collectionView.reloadData()
        }
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    //MARK: create audio msg
    func createAudioMessage(messages: NSDictionary) -> JSQMessage? {
        let name = messages[kSENDERNAME] as? String
        let userId = messages[kSENDERID] as? String
        var date: Date!
        if let createdAt = messages[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdAt as! String)
            }
        } else {
            date = Date()
        }
        
        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = outGoingStatusFor(senderId: userId!)
        let audioMessage = JSQMessage(senderId: userId!, displayName: name!, media: audioItem)
        //download audio messages
        downloadAudio(audioUrl: messages[kAUDIO] as! String) { (audioFileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentDirectory(fileName: audioFileName!))
            let audioData = try? Data(contentsOf: url as URL)
            audioItem.audioData = audioData
            self.collectionView.reloadData()
        }
        
        return audioMessage
    }
    
    //MARK: Create Location Msg
    func createLocationMessage(messages: NSDictionary) -> JSQMessage? {
        let name = messages[kSENDERNAME] as? String
        let userId = messages[kSENDERID] as? String
        
        var date: Date!
        if let createdAt = messages[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdAt as! String)
            }
        } else {
            date = Date()
        }
        
        let lat = messages[kLATITUDE] as? Double
        let lng = messages[kLONGITUDE] as? Double
        let locMediaItem = JSQLocationMediaItem(location: nil)
        locMediaItem?.appliesMediaViewMaskAsOutgoing = outGoingStatusFor(senderId: userId!)
        let location = CLLocation(latitude: lat!, longitude: lng!)
        locMediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userId!, senderDisplayName: name, date: date, media: locMediaItem)
    }
    
    //MARK: check if incoming or outgoing msg
    func outGoingStatusFor(senderId: String) -> Bool {
        return senderId == FUser.currentId()
    }
}
