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
            object: [message, senderId, senderName, dateFormatter().string(from: date),status, type]
            ,forKey: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying] as NSCopying)
    }
    
    //MARK: Send Messages to Firestore
    func sendMessage(chatRoomID: String, messages: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        
        let messageId = UUID().uuidString
        messages[kMESSAGEID] = messageId
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messages as! [String : Any])
        }
    }
}
