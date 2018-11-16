//
//  ProfileTableVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/12/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

class ProfileTableVC: UITableViewController {

    //MARK: -Outlets
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var blockUserBtn: UIButton!
    //MARK: Variables
    var user: FUser?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: IBActions   
    @IBAction func callBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func messageBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func blockUserBtnPressed(_ sender: Any) {
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        if currentBlockedIds.contains(user!.objectId) {
            currentBlockedIds.remove(at: currentBlockedIds.index(of: user!.objectId)!)
        } else {
            currentBlockedIds.append(user!.objectId)
        }
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                debugPrint("error updating user \(error!.localizedDescription)")
                return
            }
            self.updateBlockStatus()
        }
        //remove all chats between current user and blocked user
        block(userToBlock: user!)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    //MARK: SetupUI
    func setupUI() {
        if user != nil {
            self.title = "Profile"
            fullnameLbl.text = user!.fullname
            phoneNumberLbl.text = user!.phoneNumber
            updateBlockStatus()
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                self.userProfileImg.image = avatarImage!.circleMasked
            }
        }
    }
    
    func updateBlockStatus() {
        if user?.objectId != FUser.currentId() {
            blockUserBtn.isHidden = false
            messageBtn.isHidden = false
            callBtn.isHidden = false
        } else {
            blockUserBtn.isHidden = true
            messageBtn.isHidden = true
            callBtn.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockUserBtn.setTitle("Unblock User", for: .normal)
        } else {
            blockUserBtn.setTitle("Block User", for: .normal)
        }
    }
}
