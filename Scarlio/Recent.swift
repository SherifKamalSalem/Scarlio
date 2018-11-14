//
//  Recent.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/13/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation

func startPrivateChat(firstUser: FUser, secondUser: FUser) -> String {
    let firstUserId = firstUser.objectId
    let secondUserId = secondUser.objectId
    
    var chatRoomId = ""
    let value = firstUserId.compare(secondUserId).rawValue
    if value < 0 {
        chatRoomId = firstUserId + secondUserId
    } else {
        chatRoomId = secondUserId + firstUserId
    }
    let members = [firstUserId, secondUserId]
    
    createRecent(forMembers: members, chatRoomId: chatRoomId, withUser: "", ofType: kPRIVATE, forUsers: [firstUser, secondUser], avatarOfGroup: nil)
    
    return chatRoomId
}

func createRecent(forMembers members: [String], chatRoomId: String, withUser userName: String, ofType type: String, forUsers users: [FUser]?, avatarOfGroup: String?) {
    
    var tempMembers = members
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if let currentUserId = currentRecent[kUSERID] {
                    if tempMembers.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.index(of: currentUserId as! String)!)
                    }
                }
            }
        }
        
        for userId in tempMembers {
            createRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, withUser: userName, ofType: type, forUsers: users, avatarOfGroup: avatarOfGroup)
        }
    }
}

func createRecentItem(userId: String, chatRoomId: String, members: [String], withUser userName: String, ofType type: String, forUsers users: [FUser]?, avatarOfGroup: String?) {
    
    let localRef = reference(.Recent).document()
    let recentId = localRef.documentID
    let date = dateFormatter().string(from: Date())
    var recent : [String : Any]!
    var recentChatUser: FUser?
    
    
    if type == kPRIVATE {
        if users != nil && users!.count > 0 {
            if userId == FUser.currentId() {
                recentChatUser = users?.last
            } else {
                recentChatUser = users?.first
            }
        }
        recent = [kRECENTID : recentId,
                  kUSERID : userId,
                  kCHATROOMID : chatRoomId,
                  kMEMBERS : members,
                  kMEMBERSTOPUSH : members,
                  kWITHUSERFULLNAME : recentChatUser?.fullname,
                  kWITHUSERUSERID : recentChatUser?.objectId,
                  kLASTMESSAGE : "",
                  kCOUNTER : 0,
                  kDATE : date,
                  kTYPE : type,
                  kAVATAR : recentChatUser?.avatar] as [String : Any]
    } else {
        if avatarOfGroup != nil {
            recent = [kRECENTID : recentId,
                      kUSERID : userId,
                      kCHATROOMID : chatRoomId,
                      kMEMBERS : members,
                      kMEMBERSTOPUSH : members,
                      kWITHUSERFULLNAME : recentChatUser!.fullname,
                      kLASTMESSAGE : "",
                      kCOUNTER : 0,
                      kDATE : date,
                      kTYPE : type,
                      kAVATAR : avatarOfGroup!] as [String : Any]
        }
    }
    
    //MARK: save recent chat
    localRef.setData(recent)
}

//MARK: restart chat
func restartChat(recent: NSDictionary) {
    if recent[kTYPE] as! String == kPRIVATE {
        createRecent(forMembers: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUser: (FUser.currentUser()?.firstname)!, ofType: kPRIVATE, forUsers: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    if recent[kTYPE] as! String == kGROUP {
        createRecent(forMembers: recent[kMEMBERS] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUser: recent[kWITHUSERFULLNAME] as! String, ofType: kGROUP, forUsers: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
    
}


//MARK: Delete recent chat
func deleteRecentChat(recentChats: NSDictionary) {
    if let recentId = recentChats[kRECENTID] {
        reference(.Recent).document(recentId as! String).delete()
    }
}
