//
//  SettingsTableVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/12/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class SettingsTableVC: UITableViewController {

    //MARK: Outlets
    
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var avatarStatusSwitch: UISwitch!
    @IBOutlet weak var versionNumberLbl: UILabel!
    
    //Variables
    var avatarStatus: Bool = false
    var firstLoad: Bool?
    let userDefaults = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FUser.currentUser() != nil {
            setupUI()
            loadUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return 5
        }
        return 2
    }
    
    //MARK: - Table view delegate
    
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
    

    //MARK: Logout
    
    @IBAction func showAvatarStatusChanged(_ sender: UISwitch) {
        avatarStatus = sender.isOn
        saveUserDefaults()
    }
    
    
    
    @IBAction func tellFriendBtnPressed(_ sender: Any) {
        let text = "Hay! Lets chat on Scarlio \(kAPPURL)"
        let objectsToShare: [Any] = [text]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.setValue("Lets Chat on Scarlio", forKey: "subject")
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func clearCacheBtnPressed(_ sender: Any) {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentURL().path)
            for file in files {
                try FileManager.default.removeItem(atPath: "\(getDocumentURL().path)/\(file)")
            }
            ProgressHUD.showSuccess("Cache cleaned successfully.")
        } catch {
            ProgressHUD.showError("Couldn't clean media files")
        }
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete this account", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverpresentController = optionMenu.popoverPresentationController {
                currentPopoverpresentController.sourceView = deleteAccountBtn
                currentPopoverpresentController.sourceRect = deleteAccountBtn.bounds
                
                currentPopoverpresentController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcomeVC")
        present(mainView, animated: true, completion: nil)
    }
    
    //MARK: setup UI
    func setupUI() {
        let currentUser = FUser.currentUser()!
        fullnameLbl.text = currentUser.fullname
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (image) in
                if image != nil {
                    self.userProfileImg.image = image!.circleMasked
                }
            }
        }
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumberLbl.text = version
        }
        
    }
    //MARK: User defaults
    
    func saveUserDefaults() {
        userDefaults.set(avatarStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        avatarStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        avatarStatusSwitch.isOn = avatarStatus
    }
    
    //MARK: delete Account
    
    func deleteUser() {
        //locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        //remotely
        reference(.User).document(FUser.currentId()).delete()
        FUser.deleteUser { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError("Couldn't Delete User")
                }
                return
            }
            self.showLoginView()
        }
    }
}
