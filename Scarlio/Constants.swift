//
//  Constants.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/7/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


public var recentBadgeHandler: ListenerRegistration?
let userDefaults = UserDefaults.standard

//NOTIFICATION
public let USER_DID_LOGIN_NOTIFICATION = "userDidLoginNotification"
public let APP_STARTED_NOTIFICATION = "appStartedNotification"

//MARK: IDS and Keys
public let kFILE_REFERENCE = "gs://scarlio-962f0.appspot.com"
public let kONESIGNALAPPID = ""
public let kSINCHKEY = ""
public let kSINCHSECRET = ""
public let kAPPURL = ""

//MARK: Firebase Headers
public let kUSER_PATH = "User"
public let kTYPING_PATH = "Typing"
public let kRECENT_PATH = "Recent"
public let kMESSAGE_PATH = "Message"
public let kGROUP_PATH = "Group"
public let kCALL_PATH = "Call"

//MARK: FUser
public let kOBJECTID = "objectId"
public let kCREATEDAT = "createdId"
public let kUPDATEDAT = "updatedAt"
public let kEMAIL = "email"
public let kPHONE = "phone"
public let kCOUNTRYCODE = "countryCode"
public let kFACEBOOK = "facebook"
public let kLOGINMETHOD = "loginMethod"
public let kPUSHID = "pushId"
public let kFIRSTNAME = "firstname"
public let kLASTNAME = "lastname"
public let kFULLNAME = "fullname"
public let kAVATAR = "avatar"
public let kCURRENTUSER = "currentUser"
public let kISONLINE = "isOnline"
public let kVERIFICATIONCODE = "firebase_verification"
public let kCITY = "city"
public let kCOUNTRY = "country"
public let kBLOCKEDUSERID = "blockedUserId"

//MARK: Image & Audio
public let kBACKGROUNDIMAGE = "backgroundImage"
public let kSHOWAVATAR = "showAvatar"
public let kPASSWORDPROTECT = "passwordProtect"
public let kFIRSTRUN = "firstRun"
public let kNUMBEROFMESSAGES = 10
public let kMAXDURATION = 120.0
public let kAUDIOMAXDURATION = 120.0
public let kSUCCESS = 2

//MARK: Recent
public let kCHATROOMID = "chatRoomId"
public let kUSERID = "userId"
public let kDATE = "date"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kMESSAGE = "message"
public let kMEMBERSTOPUSH = "membersToPush"
public let kDESCRIPTION = "description"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"
public let kISDELETED = "isDeleted"

//MARK: Contacts
public let kCONTACT = "contact"
public let kCONTACTID = "contactId"

//MARK: Message types
public let kPICTURE = "picture"
public let kTEXT = "text"
public let kAUDIO = "audio"
public let kVIDEO = "video"
public let kLOCATION = "location"

//MARK: Message status
public let kDELIVERED = "delivered"
public let kREAD = "read"
public let kREADDATE = "readDate"
public let kDELETED = "deleted"

//MARK: Push
public let kDEVICEID = "deviceId"

//MARK: Call
public let kISINCOMING = "isIncoming"
public let kCALLERID = "callerId"
public let kCALLERFULLNAME = "callerFullName"
public let kCALLERSTATUS = "callStatus"
public let kWITHUSERFULLNAME = "withUserFullName"
public let kCALLERAVATAR  = "callerAvatar"
public let kWITHUSERAVATAR = "withUserAvatar"
