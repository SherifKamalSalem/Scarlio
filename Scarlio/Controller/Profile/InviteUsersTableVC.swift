//
//  InviteUsersTableVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/18/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class InviteUsersTableVC: UITableViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var headerView: UIView!
    
    
    //MARK: - Variables
    var allUsers: [FUser] = []
    var allUserGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []
    var newMembersIds: [String] = []
    var currentMemberIds: [String] = []
    var group: NSDictionary?
    
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers(filter: kCITY)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        currentMemberIds = group![kMEMBERS] as! [String]
    }

    //MARK: - Helper Functions
    
    func loadUsers(filter: String) {
        ProgressHUD.show()
        var query: Query!
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        query.getDocuments { (snapshot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUserGrouped = [:]
            if error != nil {
                debugPrint(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            if !snapshot.isEmpty {
                for userDict in snapshot.documents {
                    let userDict = userDict.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDict)
                    
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                self.splitDataIntoSections()
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    //MARK: Helper functions
    fileprivate func splitDataIntoSections() {
        var sectionTitle: String = ""
        for user in 0..<self.allUsers.count {
            let currentUser = self.allUsers[user]
            let firstChar = currentUser.firstname.first
            let firstCharString = "\(firstChar ?? "A")"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.allUserGrouped[sectionTitle] = []
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
            }
            self.allUserGrouped[firstCharString]?.append(currentUser)
        }
    }
    
    //MARK: - Update Group
    func updateGroup(group: NSDictionary) {
        let tempMembers = currentMemberIds + newMembersIds
        let tempMembersToPush = group[kMEMBERSTOPUSH] as! [String] + newMembersIds
        let withValues = [kMEMBERS : tempMembers, kMEMBERSTOPUSH : tempMembersToPush]
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        createRecent(forNewMembers: tempMembersToPush, groupId: group[kGROUPID] as! String, groupName: group[kNAME] as! String, avatar: group[kAVATAR] as! String)
        updateExistingRecent(withValues: withValues, chatRoomId: group[kGROUPID] as! String, members: tempMembers)
        goToGroupChat(membersToPush: tempMembersToPush, members: tempMembers)
    }
    
    func goToGroupChat(membersToPush: [String], members: [String]) {
        let chatVC = ChatPageVC()
        chatVC.titleName = group![kNAME] as! String
        chatVC.memberIds = members
        chatVC.membersToPush = membersToPush
        chatVC.chatRoomId = group![kGROUPID] as! String
        chatVC.isGroup = true
        chatVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.allUserGrouped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = self.sectionTitleList[section]
        let users = self.allUserGrouped[sectionTitle]
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        var user: FUser?
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUserGrouped[sectionTitle]
        user = users![indexPath.row]
        cell.generateCellWith(fUser: user!, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleList[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUserGrouped[sectionTitle]
        let selectedUser = users![indexPath.row]
        if currentMemberIds.contains(selectedUser.objectId) {
            ProgressHUD.showError("Already in the group!")
            return
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        //Add/Remove users
        let isSelected = newMembersIds.contains(selectedUser.objectId)
        if isSelected {
            let objectIndex = newMembersIds.index(of: selectedUser.objectId)!
            newMembersIds.remove(at: objectIndex)
        } else {
            newMembersIds.append(selectedUser.objectId)
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = newMembersIds.count > 0
    }
    
    //MARK: - IBActions
    
    
    @IBAction func filteredSegmentValueChanged(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    @objc func doneBtnPressed(_ sender: Any) {
        updateGroup(group: group!)
    }
}


//MARK: user table view cell delegate
extension InviteUsersTableVC : UserTableDelegate {
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileTableVC") as! ProfileTableVC
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUserGrouped[sectionTitle]
        profileVC.user = users![indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
