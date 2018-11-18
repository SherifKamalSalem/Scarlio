//
//  Recent.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/13/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation

var groupName: String?

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

/**
 Create recent for every member of group
 including new member that can participat into chat
 */
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
                  kWITHUSERFULLNAME : recentChatUser?.fullname ?? "someone",
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
                      kWITHUSERFULLNAME : groupName,
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
        createRecent(forMembers: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUser: groupName ?? "" , ofType: kGROUP, forUsers: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
}

//MARK: Clear Counter
func updateRecents(chatRoomId: String, lastMessage: String) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
            }
        }
    }
}

//MARK: Update recent chat
func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    let date = dateFormatter().string(from: Date())
    var counter = recent[kCOUNTER] as! Int
    if recent[kUSERID] as? String != FUser.currentId() {
        counter += 1
    }
    let values = [kLASTMESSAGE : lastMessage, kCOUNTER : counter, kDATE : date] as [String : Any]
    reference(.Recent).document(recent[kRECENTID] as! String).updateData(values)
}


//MARK: Delete recent chat
func deleteRecentChat(recentChats: NSDictionary) {
    if let recentId = recentChats[kRECENTID] {
        reference(.Recent).document(recentId as! String).delete()
    }
}

//MARK: Clear Counter
func clearRecentCounter(chatRoomId: String) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if currentRecent[kUSERID] as? String == FUser.currentId() {
                    clearRecentCounterItem(recent: currentRecent)
                }
            }
        }
    }
}


func clearRecentCounterItem(recent: NSDictionary) {
    reference(.Recent).document(recent[kRECENTID] as! String).updateData([kCOUNTER : 0])
}

//MARK: Update mute/unmute status
func updateExistingRecent(withValues values: [String : Any], chatRoomId: String, members: [String]) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let recent = recent.data() as NSDictionary
                update(recentId: recent[kRECENTID] as! String, withValues: values)
            }
        }
    }
}

//MARK: update

func update(recentId recentId: String, withValues values: [String : Any]) {
    reference(.Recent).document(recentId).updateData(values)
}

//MARK: Block User
func block(userToBlock user: FUser) {
    let firstUserId = FUser.currentId()
    let secondUserId = user.objectId
    
    var chatRoomId = ""
    let value = firstUserId.compare(secondUserId).rawValue
    if value < 0 {
        chatRoomId = firstUserId + secondUserId
    } else {
        chatRoomId = secondUserId + firstUserId
    }
    deleteRecentsFor(chatRoomId: chatRoomId)
}

func deleteRecentsFor(chatRoomId: String) {
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let recent = recent.data() as NSDictionary
                deleteRecentChat(recentChats: recent)
            }
        }
    }
}

//MARK: Group Recent Functions

func startGroupChat(group: Group) {
    let chatRoomId = group.groupDictionary[kGROUPID] as! String
    let members = group.groupDictionary[kMEMBERS] as! [String]
    groupName = group.groupDictionary[kNAME] as! String
    createRecent(forMembers: members, chatRoomId: chatRoomId, withUser: group.groupDictionary[kNAME] as! String, ofType: kGROUP, forUsers: nil, avatarOfGroup: group.groupDictionary[kAVATAR] as? String)
}

func createRecent(forNewMembers membersToPush: [String], groupId: String, groupName: String, avatar: String) {
    createRecent(forMembers: membersToPush, chatRoomId: groupId, withUser: groupName, ofType: kGROUP, forUsers: nil, avatarOfGroup: avatar)
}
