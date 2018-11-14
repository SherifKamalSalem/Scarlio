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
        case kAUDIO: print("Unkown msg type")
        case kPICTURE: print("Unkown msg type")
        case kVIDEO: print("Unkown msg type")
        case kLOCATION: print("Unkown msg type")
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
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: messages[kMESSAGE] as? String)
    }
}
