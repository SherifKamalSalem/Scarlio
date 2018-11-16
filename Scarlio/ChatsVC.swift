//
//  ChatsVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/12/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsVC: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    //MARK: Variables
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListener: ListenerRegistration?
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecentChats()
        tableView.tableFooterView = UIView()
        setTableViewHeader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener?.remove()
    }

    //MARK: IBActions
    @IBAction func createChatBtnPressed(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userTableVC") as? UserTableVC
        self.navigationController?.pushViewController(userVC!, animated: true)
    }
    
    //MARK: load recent chats
    func loadRecentChats() {
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            if !snapshot.isEmpty {
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: Custom table View header
    func setTableViewHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 40))
        //buttonView.backgroundColor = UIColor.blue
        let groupButton = UIButton(frame: CGRect(x:  buttonView.frame.width - 80, y: 5, width: 100, height: 30))
        groupButton.setTitleColor(UIColor.white, for: .normal)
        groupButton.setTitle("New Group", for: .normal)
        groupButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        groupButton.layer.cornerRadius = 7
        groupButton.addTarget(self, action: #selector(groupButtonPressed), for: .touchUpInside)
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
    }
    
    func showUserProfile(user: FUser) {
        print("user profile")
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileTableVC") as! ProfileTableVC
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: Helper Functions
    func updatePushMembers(recent: NSDictionary, isMute: Bool) {
        var membersToPush = recent[kMEMBERSTOPUSH] as! [String]
        if isMute {
            let index = membersToPush.index(of: FUser.currentId())!
            membersToPush.remove(at: index)
        } else {
            membersToPush.append(FUser.currentId())
        }
        //save to firebase
        updateExistingRecent(withValues: [kMEMBERSTOPUSH : membersToPush], chatRoomId: recent[kCHATROOMID] as! String, members: recent[kMEMBERS] as! [String])
    }
    
    @objc func groupButtonPressed() {
        
    }
}

extension ChatsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        } else {
            return recentChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentChatsCell", for: indexPath) as! RecentChatsCell
        cell.delegate = self
        var recent: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var tempRecent: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            tempRecent = filteredChats[indexPath.row]
        } else {
            tempRecent = recentChats[indexPath.row]
        }
        var muteTitle = "Unmute"
        var mute = false
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.recentChats.remove(at: indexPath.row)
            deleteRecentChat(recentChats: tempRecent)
            self.tableView.reloadData()
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            self.updatePushMembers(recent: tempRecent, isMute: mute)
        }
        muteAction.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        return [deleteAction, muteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var recent: NSDictionary
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }
        //restart chat
        restartChat(recent: recent)
        
        let chatPageVC = ChatPageVC()
        chatPageVC.hidesBottomBarWhenPushed = true
        chatPageVC.titleName = recent[kWITHUSERUSERNAME] as? String
        chatPageVC.memberIds = recent[kMEMBERS] as? [String]
        chatPageVC.membersToPush = recent[kMEMBERSTOPUSH] as? [String]
        chatPageVC.chatRoomId = recent[kCHATROOMID] as? String
        chatPageVC.isGroup = recent[kTYPE] as! String == kGROUP
        navigationController?.pushViewController(chatPageVC, animated: true)
    }
}

//MARK: recent chat delegate

extension ChatsVC : RecentChatsDelegate {
    func didTapAvatarImage(indexPath: IndexPath) {
        var recentChat: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            recentChat = filteredChats[indexPath.row]
        } else {
            recentChat = recentChats[indexPath.row]
        }
        if recentChat[kTYPE] as! String == kPRIVATE {
            print("user dictionary")
            
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    let userDict = snapshot.data() as! NSDictionary
                    print("user dictionary \(userDict)")
                    let tmpUser = FUser(_dictionary: userDict)
                    self.showUserProfile(user: tmpUser)
                }
            }
        }
    }
}

// Search results extenstion
extension ChatsVC : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
