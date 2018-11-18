//
//  NewGroupVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class NewGroupVC: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var subjectTxtField: UITextField!
    @IBOutlet weak var groupSummaryLbl: UILabel!
    @IBOutlet weak var groupIconImg: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var participantsLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    //MARK: - Variables
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        groupIconImg.isUserInteractionEnabled = true
        groupIconImg.addGestureRecognizer(iconTapGesture)
        updateParticipants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subjectTxtField.layer.cornerRadius = 8
    }
    
    //MARK: - Helper Functions
    
    func updateParticipants() {
        participantsLbl.text = "PARTICIPANTS:  \(allMembers.count)"
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createBtnPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }
    
    //MARK: - IBActions
    @objc func createBtnPressed(_ sender: Any) {
        if subjectTxtField.text != nil {
            memberIds.append(FUser.currentId())
            let avatarData = UIImage(named: "groupIcon")?.jpegData(compressionQuality: 0.7)
            var avatar = avatarData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            if groupIcon != nil {
                let avatarData = groupIcon!.jpegData(compressionQuality: 0.7)
                let avatar = avatarData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            }
            let groupId = UUID().uuidString
            let group = Group(groupId: groupId, subject: subjectTxtField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar!)
            group.saveGroup()
            //MARK: - Create Group Recent
            startGroupChat(group: group)
            //MARK: - Go to Chat Page
            let chatPageVC = ChatPageVC()
            chatPageVC.titleName = group.groupDictionary[kNAME] as? String
            chatPageVC.memberIds = group.groupDictionary[kMEMBERS] as? [String]
            chatPageVC.membersToPush = group.groupDictionary[kMEMBERS] as? [String]
            chatPageVC.chatRoomId = groupId
            chatPageVC.isGroup = true
            chatPageVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatPageVC, animated: true)
        } else {
            ProgressHUD.showError("Subject is required!")
        }
    }
    
    @IBAction func iconGestureTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editIconBtnPressed(_ sender: Any) {
        showIconOptions()
    }
    
    //MARK: - Helper functions
    func showIconOptions() {
        let optionMenu = UIAlertController(title: "Choose Group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (action) in
            
        }
        if groupIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
                self.groupIcon = nil
                self.groupIconImg.image = UIImage(named: "cameraIcon")
                self.editBtn.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        //for iPad not to crash
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverpresentController = optionMenu.popoverPresentationController {
                currentPopoverpresentController.sourceView = editBtn
                currentPopoverpresentController.sourceRect = editBtn.bounds
                
                currentPopoverpresentController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            present(optionMenu, animated: true, completion: nil)
        }
    }
}

extension NewGroupVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupMemberCVCell", for: indexPath) as! GroupMemberCVCell
        cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        return cell
    }
}

extension NewGroupVC : GroupMemberCVCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        collectionView.reloadData()
    }
}
