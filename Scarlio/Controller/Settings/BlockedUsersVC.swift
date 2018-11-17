//
//  BlockedUsersVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class BlockedUsersVC: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationLbl: UILabel!
    //MARK: Variables
    var blockedUsers: [FUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        loadBlockedUsers()
    }
    
    //MARK: Load Blocked Users
    func loadBlockedUsers() {
        if FUser.currentUser()!.blockedUsers.count > 0 {
            ProgressHUD.show()
            getUsersFromFirestore(withIds: FUser.currentUser()!.blockedUsers) { (allBlockedUsers) in
                ProgressHUD.dismiss()
                self.blockedUsers = allBlockedUsers
                self.tableView.reloadData()
            }
        }
        
    }
}

extension BlockedUsersVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notificationLbl.isHidden = blockedUsers.count != 0
        return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.delegate = self
        cell.generateCellWith(fUser: blockedUsers[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var tempBlockedUsers = FUser.currentUser()!.blockedUsers
        var userIdToUnblock = blockedUsers[indexPath.row].objectId
        tempBlockedUsers.remove(at: tempBlockedUsers.index(of: userIdToUnblock)!)
        blockedUsers.remove(at: indexPath.row)
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : tempBlockedUsers]) { (error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            self.tableView.reloadData()
        }
    }
}

extension BlockedUsersVC : UserTableDelegate {
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileTableVC") as! ProfileTableVC
        profileVC.user = blockedUsers[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
