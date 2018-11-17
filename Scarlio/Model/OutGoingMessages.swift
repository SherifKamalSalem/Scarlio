//
//  OutGoingMessages.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/14/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation


class OutGoingMessages {
    
    let messagesDictionary: NSMutableDictionary
    
    //MARK: Initializer
    //text messages
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messagesDictionary = NSMutableDictionary(
            objects: [message, senderId, senderName, dateFormatter().string(from: date),status, type]
            ,forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: picture Msgs
    init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messagesDictionary = NSMutableDictionary(
            objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date),status, type]
            ,forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: Video msgs
    init(message: String, video: String, thumbnail: NSData, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        let picThumbmail = thumbnail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        messagesDictionary = NSMutableDictionary(
            objects: [message, video, picThumbmail, senderId, senderName, dateFormatter().string(from: date),status, type]
            ,forKeys: [kMESSAGE as NSCopying, kVIDEO as NSCopying, kTHUMBNAIL as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: Audio Msgs
    init(message: String, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messagesDictionary = NSMutableDictionary(
            objects: [message, audio, senderId, senderName, dateFormatter().string(from: date),status, type]
            ,forKeys: [kMESSAGE as NSCopying, kAUDIO as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: Location Msgs
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messagesDictionary = NSMutableDictionary(
            objects: [message, latitude, longitude, senderId, senderName, dateFormatter().string(from: date),status, type]
            ,forKeys: [kMESSAGE as NSCopying, kLATITUDE as NSCopying, kLONGITUDE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: Send Messages to Firestore
    func sendMessage(chatRoomID: String, messages: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        
        let messageId = UUID().uuidString
        messages[kMESSAGEID] = messageId
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messages as! [String : Any])
        }
        updateRecents(chatRoomId: chatRoomID, lastMessage: messages[kMESSAGE] as! String)
    }
    
    //MARK: Delete Message
    class func deleteMessage(withId: String, chatRoomId: String) {
    reference(.Message).document(FUser.currentId()).collection(chatRoomId).document(withId).delete()
    }
    
    //MARK: Update Message
    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        let readDate = dateFormatter().string(from: Date())
        let values = [kSTATUS : kREAD, kREADDATE : readDate]
        for userId in memberIds {
            reference(.Message).document(userId).collection(chatRoomId).document(withId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    reference(.Message).document(userId).collection(chatRoomId).document(withId).updateData(values)
                }
            }
        }
    }
}
