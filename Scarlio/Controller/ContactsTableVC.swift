//
//  ContactsTableVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import Contacts
import FirebaseFirestore
import ProgressHUD


class ContactsTableVC: UITableViewController {
    
    var users: [FUser] = []
    var matchedUsers: [FUser] = [] //users who use this app and in your contacts list
    var filteredMatchedUsers: [FUser] = [] //users we search for and filtered in search result
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList: [String] = []
    
    var isGroup = false
    var memberIdsOfGroupChat: [String] = []  //Ids of members of chat group
    var membersOfGroupChat: [FUser] = []
    
    var isAuth = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var contacts: [CNContact] = {
        requestForAccess(completionHandler: { (isAuth) in
            print("status \(isAuth)")
        })
        
        //get your contacts and put them in array
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResults = try     contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        return results
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        //to remove empty cell lines
        tableView.tableFooterView = UIView()
        loadUsers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setupBarButtons()
    }
    
    //MARK: TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return self.allUsersGrouped.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            print("count 1\(filteredMatchedUsers.count)")
            return filteredMatchedUsers.count
        } else {
            // find section title
            let sectionTitle = self.sectionTitleList[section]
            // find users for given section title
            let users = self.allUsersGrouped[sectionTitle]
            // return count for users
            print("count 2\(users!.count)")
            return users!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        var user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredMatchedUsers[indexPath.row]
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            //get all users of the section
            let users = self.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        
        cell.delegate = self
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return self.sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let userToChat: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            userToChat = filteredMatchedUsers[indexPath.row]
        } else {
            let users = self.allUsersGrouped[sectionTitle]
            userToChat = users![indexPath.row]
        }
        if !isGroup {
            //one on one chat
            if !checkBlockedStatus(ofUser: userToChat) {
                let chatVC = ChatPageVC()
                chatVC.titleName = userToChat.firstname
                chatVC.memberIds = [FUser.currentId(), userToChat.objectId]
                chatVC.membersToPush = [FUser.currentId(), userToChat.objectId]
                chatVC.chatRoomId = startPrivateChat(firstUser: FUser.currentUser()!, secondUser: userToChat)
                chatVC.isGroup = false
                chatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                ProgressHUD.showError("This User is not available for chat!")
            }
        } else {
            //for group chat put checkmark beside the name
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
            }
            //add/remove user from member chat array
            let isSelected = memberIdsOfGroupChat.contains(userToChat.objectId)
            if isSelected {
                let objectIndex = memberIdsOfGroupChat.index(of: userToChat.objectId)
                memberIdsOfGroupChat.remove(at: objectIndex!)
                membersOfGroupChat.remove(at: objectIndex!)
            } else {
                memberIdsOfGroupChat.append(userToChat.objectId)
                membersOfGroupChat.append(userToChat)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = memberIdsOfGroupChat.count > 0
        }
    }
    
    func compareUsers() {
        for user in users {
            if user.phoneNumber != "" {
                let contact = searchForContactUsingPhoneNumber(phoneNumber: user.phoneNumber)
                //if we have a match, we add to our array to display them
                if contact.count > 0 {
                    matchedUsers.append(user)
                }
                self.tableView.reloadData()
            }
        }
        // updateInformationLabel()
        self.splitDataInToSection()
    }
    
    //MARK: Contacts
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        
        var result: [CNContact] = []
        //go through all contacts
        for contact in self.contacts {
            if !contact.phoneNumbers.isEmpty {
                //get the digits only of the phone number and replace + with 00
                let phoneNumberToCompareAgainst = updatePhoneNumber(phoneNumber: phoneNumber, replacePlusSign: true)
                //go through every number of each contact
                for phoneNumber in contact.phoneNumbers {
                    let fulMobNumVar  = phoneNumber.value
                    let countryCode = fulMobNumVar.value(forKey: "countryCode") as? String
                    let phoneNumber = fulMobNumVar.value(forKey: "digits") as? String
                  
                    let contactNumber = removeCountryCode(countryCodeLetters: countryCode!, fullPhoneNumber: phoneNumber!)
                    //compare phoneNumber of contact with given user's phone number
                    if contactNumber == phoneNumberToCompareAgainst {
                        result.append(contact)
                    }
                }
            }
        }
        return result
    }
    
    
    func updatePhoneNumber(phoneNumber: String, replacePlusSign: Bool) -> String {
        if replacePlusSign {
            return phoneNumber.replacingOccurrences(of: "+", with: "").components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
            
        } else {
            return phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
        }
    }
    
    func requestForAccess(completionHandler: (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
//            self.contacts.Storage.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
//                if access {
//                    completionHandler(accessGranted: access)
//                }
//                else {
//                    if authorizationStatus == CNAuthorizationStatus.Denied {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
//                            self.showMessage(message)
//                        })
//                    }
//                }
//            })
            print("denied")
            
        default:
            completionHandler(false)
        }
    }
    
    
    func removeCountryCode(countryCodeLetters: String, fullPhoneNumber: String) -> String {
        
        let countryCode = CountryCode()
        let countryCodeToRemove = countryCode.codeDictionaryShort[countryCodeLetters.uppercased()]
        //remove + from country code
        let updatedCode = updatePhoneNumber(phoneNumber: countryCodeToRemove!, replacePlusSign: true)
        //remove countryCode
        let replacedNUmber = fullPhoneNumber.replacingOccurrences(of: updatedCode, with: "").components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
        
                print("Code \(countryCodeLetters)")
                print("full number \(fullPhoneNumber)")
                print("code to remove \(updatedCode)")
                print("clean number is \(replacedNUmber)")
        
        return replacedNUmber
    }
    
    fileprivate func splitDataInToSection() {
        // set section title "" at initial
        var sectionTitle: String = ""
        // iterate all records from array
        for i in 0..<self.matchedUsers.count {
            // get current record
            let currentUser = self.matchedUsers[i]
            // find first character from current record
            let firstChar = currentUser.firstname.first!
            // convert first character into string
            let firstCharString = "\(firstChar)"
            // if first character not match with past section title then create new section
            if firstCharString != sectionTitle {
                // set new title for section
                sectionTitle = firstCharString
                // add new section having key as section title and value as empty array of string
                self.allUsersGrouped[sectionTitle] = []
                // append title within section title list
                self.sectionTitleList.append(sectionTitle)
            }
            // add record to the section
            self.allUsersGrouped[firstCharString]?.append(currentUser)
        }
        tableView.reloadData()
    }
    
    //MARK: Filtering results
    func filteredContent(forText searchText: String, scope: String = "All") {
        filteredMatchedUsers = matchedUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: Helper Functions
    
    //MARK: setup buttons
    func setupBarButtons() {
        if isGroup {
            //for group
            let nextBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBtnPressed))
            self.navigationItem.rightBarButtonItem = nextBtn
            self.navigationItem.rightBarButtonItems!.first!.isEnabled = false
        } else {
            //for one to one chat
            let inviteBtn = UIBarButtonItem(image: UIImage(named: "invite"), style: .plain, target: self, action: #selector(inviteBtnPressed))
            
            let searchBtn = UIBarButtonItem(image: UIImage(named: "nearMe"), style: .plain, target: self, action: #selector(searchNearByBtnPressed))
            
            self.navigationItem.rightBarButtonItems = [inviteBtn, searchBtn]
        }
    }
    
    //MARK: - Load Users
    func loadUsers() {
        ProgressHUD.show()
        reference(.User).order(by: kFIRSTNAME, descending: false).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            if !snapshot.isEmpty {
                self.matchedUsers = []
                self.users.removeAll()
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    if fUser.objectId != FUser.currentId() {
                        self.users.append(fUser)
                    }
                }
                ProgressHUD.dismiss()
                self.tableView.reloadData()
            }
            ProgressHUD.dismiss()
            self.compareUsers()
        }
    }
    
    //MARK: IBActions
    
    @objc func nextBtnPressed() {
        
    }
    
    @objc func inviteBtnPressed() {
        let text = "Hay! Lets chat on Scarlio \(kAPPURL)"
        let objectsToShare: [Any] = [text]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.setValue("Lets Chat on Scarlio", forKey: "subject")
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func searchNearByBtnPressed() {
        let userVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userTableVC") as! UserTableVC
        self.navigationController?.pushViewController(userVC, animated: true)
    }
}

extension ContactsTableVC : UISearchResultsUpdating, UserTableDelegate {
    
    //fill filteredUser array with results according to search bar text
    func updateSearchResults(for searchController: UISearchController) {
        filteredContent(forText: searchController.searchBar.text!)
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileTableVC") as! ProfileTableVC
        var user: FUser!
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredMatchedUsers[indexPath.row]
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.row]
            let users = self.allUsersGrouped[sectionTitle]
            user = users![indexPath.row]
        }
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
