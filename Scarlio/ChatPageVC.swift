//
//  ChatPageVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/13/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatPageVC: JSQMessagesViewController {

    //MARK: Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    var initialLoadComplete: Bool = false
    //number of loaded msgs
    var maxMessagesNumber = 0
    var minMessagesNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var typingCounter = 0
    //listener for new messages, notify user for read msg status and typing
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    var newChatListener: ListenerRegistration?
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    //Custom headers
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    
    let avatarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    
    let subtitleLabel: UILabel = {
        let subtitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subtitle.textAlignment = .left
        subtitle.font = UIFont(name: subtitle.font.fontName, size: 10)
        return subtitle
    }()
    
    //Fix UI issue for iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //notify the other user if current is typing
        createTypingObserver()
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        setCustomTitle()
        
        loadMessages()
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()?.firstname
        //Fix UI issue for iphone x
        let constaint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constaint.priority = UILayoutPriority(rawValue: 1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        //Customize send button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    //MARK: JSQMessages data source functions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
        //set text color
        if cell.textView != nil {
            if data.senderId == FUser.currentId() {
                cell.textView.textColor = .white
            } else {
                cell.textView.textColor = .black
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessages[indexPath.row]
        let status: NSAttributedString!
        let attrStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attrStringColor)
        default:
            status = NSAttributedString(string: "✔︎")
        }
        if indexPath.row == (messages.count - 1) {
            return status
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    //MARK: JSQMessages delegate functions
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let camera = Camera(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.presentMutlyCamera(target: self, canEdit: false)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.presentPhotoLibrary(target: self, canEdit: false)
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            camera.presentVideoLibrary(target: self, canEdit: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            if self.haveAccessToUserLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        //for iPad not to crash
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverpresentController = optionMenu.popoverPresentationController {
                currentPopoverpresentController.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentController.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverpresentController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            present(optionMenu, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        } else {
            let audioVC = AudioMessage(delegate_: self)
            audioVC.presentAudioRecorder(target: self)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        //load more old messages
        self.loadMoreMessages(maxNumber: maxMessagesNumber, minNumber: minMessagesNumber)
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let messageDiectionary = objectMessages[indexPath.row]
        let messageType = messageDiectionary[kTYPE] as! String
        switch messageType {
        case kPICTURE:
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            let prowser = IDMPhotoBrowser(photos: photos)
            self.present(prowser!, animated: true, completion: nil)
        case kVIDEO:
            let message = messages[indexPath.row]
            let mediaItem = message.media as! VideoMessage
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            moviePlayer.player = player
            self.present(moviePlayer, animated: true) {
                moviePlayer.player?.play()
            }
        case kLOCATION:
            let message = messages[indexPath.row]
            let locMediaItem = message.media as! JSQLocationMediaItem
            let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapVC") as! MapVC
            mapView.location = locMediaItem.location
            self.navigationController?.pushViewController(mapView, animated: true)
        default:
            print("")
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
    }
    
    //MARK: Send Message
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        var outgoingMessage: OutGoingMessages?
        let currentUser = FUser.currentUser()
        //text msgs
        if let text = text {
            outgoingMessage = OutGoingMessages(message: text, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        //Picture msgs
        if let pic = picture {
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in
                if imageLink != nil {
                    let text = "[\(kPICTURE)]"
                    outgoingMessage = OutGoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messages: outgoingMessage!.messagesDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            }
            return
        }
        //send video
        if let video = video {
            let videoData = NSData(contentsOfFile: video.path!)
            let thumbnailData = videoThumbnail(video: video).jpegData(compressionQuality: 0.3)
            uploadVideo(video: videoData!, chatRoomId: chatRoomId, view: self.navigationController!.view) { (videoLink) in
                if videoLink != nil {
                    let text = "[\(kVIDEO)]"
                    outgoingMessage = OutGoingMessages(message: text, video: videoLink!, thumbnail: thumbnailData! as NSData, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: Date(), status: kDELIVERED, type: kVIDEO)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messages: outgoingMessage!.messagesDictionary, memberIds: self.memberIds, membersToPush: self.membersToPush)
                    
                }
            }
            return
        }
        //Send Audio
        if let audioPath = audio {
            uploadAudio(audioPath: audioPath, chatRoomId: chatRoomId, view: (self.navigationController?.view)!) { (audioLink) in
                if audioLink != nil {
                    let text = "[\(kAUDIO)]"
                    outgoingMessage = OutGoingMessages(message: text, audio: audioLink!, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: date, status: kDELIVERED, type: kAUDIO)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, messages: (outgoingMessage!.messagesDictionary), memberIds: self.memberIds, membersToPush: self.membersToPush)
                }
            }
            return
        }
        //MARK: Send location msg
        if location != nil {
            let lat : NSNumber = NSNumber(value: appDelegate.coordinates?.latitude ?? 0.0)
            let lng : NSNumber = NSNumber(value: appDelegate.coordinates?.longitude ?? 0.0)
            
            let text = "[\(kLOCATION)]"
            outgoingMessage = OutGoingMessages(message: text, latitude: lat, longitude: lng, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: date, status: kDELIVERED, type: kLOCATION)
        }
        
        //make a sound 🗣🖕💨 to notify user of new coming msgs
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, messages: outgoingMessage!.messagesDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    //MARK: load all messages
    func loadMessages() {
        //to update message status
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                
                snapshot.documentChanges.forEach({(diff) in
                    if diff.type == .modified {
                        //update message with new status
                        self.updateMessage(messageDictionary: diff.document.data() as NSDictionary)
                    }
                })
            }
        })
        //get last 11 msgs
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                //initial loading is done successfully
                self.initialLoadComplete = true
                //listen for new chats
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
            self.getOldMessagesInBackground()
            self.listenForNewChats()
            print("we have \(self.messages.count) messages loaded")
        }
    }
    
    //MARK: update message
    func updateMessage(messageDictionary: NSDictionary) {
        for index in 0 ..< objectMessages.count {
            let temp = objectMessages[index]
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                objectMessages[index] = messageDictionary
                self.collectionView!.reloadData()
            }
        }
    }
    
    //MARK: load more old messages
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        if loadOld {
            maxMessagesNumber = minNumber - 1
            minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        }
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        for num in (minMessagesNumber ... maxMessagesNumber).reversed() {
            let messageDictionary = loadedMessages[num]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    //MARK: inserting old loaded messages that requested after loading the first 11 msgs
    func insertNewMessage(messageDictionary: NSDictionary) {
        let incomingMessage = IncomingMessages(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(messages: messageDictionary, chatRoomId: chatRoomId)
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    //MARK: Insert messages
    func insertMessages() {
        maxMessagesNumber = loadedMessages.count - loadedMessagesCount
        minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        for num in minMessagesNumber ..< maxMessagesNumber {
            let messages = loadedMessages[num]
            insertInitialLoadMessages(messageDictionary: messages)
            loadedMessagesCount += 1
        }
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    //MARK: check if the message is on the right side or in the left side
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
        let incomingMessage = IncomingMessages(collectionView_: self.collectionView!)
        //incoming msgs
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            OutGoingMessages.updateMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberIds)
        }
        
        let message = incomingMessage.createMessage(messages: messageDictionary, chatRoomId: chatRoomId)
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    //MARK: Update UI and Custom top header
    func setCustomTitle() {
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        let infoBtn = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoBtnPressed))
        self.navigationItem.rightBarButtonItem = infoBtn
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        } else {
            avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: memberIds) { (withUsers) in
            self.withUsers = withUsers
            if !self.isGroup! {
                self.setUIForSingleChat()
            }
        }
    }
    //MARK: set UI for single chat
    func setUIForSingleChat() {
        let withUser = withUsers.first!
        imageFromData(pictureData: withUser.avatar) { (image) in
            if image != nil {
                self.avatarButton.setImage(image?.circleMasked, for: .normal)
            }
        }
        titleLabel.text = withUser.fullname
        if withUser.isOnline {
            subtitleLabel.text = "Online"
        } else {
            subtitleLabel.text = "Offline"
        }
        avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
    }
    
    //MARK: check if incoming or outgoing
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    //MARK: listen for more than 11 chat msgs
    func listenForNewChats() {
        var lastMessageDate = "0"
        if loadedMessages.count > 0 {
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE] {
                            if self.legitTypes.contains(type as! String) {
                                if type as! String == kPICTURE {
                                    
                                }
                                if self.insertInitialLoadMessages(messageDictionary: item) {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    //MARK: loading old msgs in background
    func getOldMessagesInBackground() {
        if loadedMessages.count > 10 {
            let firstMessageDate = loadedMessages.last![kDATE] as! String
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                self.maxMessagesNumber = self.loadedMessages.count - (self.loadedMessagesCount - 1)
                self.minMessagesNumber = self.maxMessagesNumber - kNUMBEROFMESSAGES
            }
        }
    }
    //MARK: Location Access
    func haveAccessToUserLocation() -> Bool {
        if appDelegate.locationManager != nil {
            return true
        } else {
            ProgressHUD.showError("Please give access to location in Settings")
            return false
        }
    }
    
    //Customize the date format for read status
    func readTimeFrom(dateString: String) -> String {
        let date = dateFormatter().date(from: dateString)
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        return currentDateFormat.string(from: date!)
    }
    
    //MARK: remove bad messages
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        var tempMsgs = allMessages
        for message in tempMsgs {
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    //remove the message
                    tempMsgs.remove(at: tempMsgs.index(of: message)!)
                }
            } else {
                tempMsgs.remove(at: tempMsgs.index(of: message)!)
            }
        }
        return tempMsgs
    }
    
    //MARK: Remove Listeners
    func removeListeners() {
        if typingListener != nil {
            typingListener?.remove()
        }
        if newChatListener != nil {
            newChatListener?.remove()
        }
        if updatedChatListener != nil {
            updatedChatListener?.remove()
        }
    }
    
    //MARK: custom send button
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    //MARK: IBActions navigation back from chat page VC
    @objc func backAction() {
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func infoBtnPressed() {
        
    }
    
    @objc func showGroup() {
        
    }
    
    @objc func showUserProfile() {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileTableVC") as! ProfileTableVC
        profileVC.user = withUsers.first
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK: Typing Observer
    func createTypingObserver() {
        //notify the other user if current is typing
        typingListener = reference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != FUser.currentId() {
                        let isTyping = data.value as! Bool
                        self.showTypingIndicator = isTyping
                        if isTyping {
                            self.scrollToBottom(animated: true)
                        }
                    }
                }
            } else {
                reference(.Typing).document(self.chatRoomId).setData([FUser.currentId() : false])
            }
        })
    }
    
    func typingCounterStart() {
        typingCounter += 1
        typingCounterSave(isTyping: true)
        self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
    }
    
    @objc func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            typingCounterSave(isTyping: false)
        }
    }
    
    func typingCounterSave(isTyping: Bool) {
        reference(.Typing).document(chatRoomId).updateData([FUser.currentId() : isTyping])
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            typingCounterStart()
            return true
    }
}


//MARK: Fix UI issue for iphone x
extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}

//MARK: UIImagePickerController delegate methods
extension ChatPageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: Record Audio message
extension ChatPageVC : IQAudioRecorderViewControllerDelegate {
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true, completion: nil)
        self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

