//
//  EditProfileTableVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class EditProfileTableVC: UITableViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet var avatarTapGRecognizer: UITapGestureRecognizer!
    
    //MARK: - Variables
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func setupUI() {
        let currentUser = FUser.currentUser()
        userProfileImg.isUserInteractionEnabled = true
        firstNameTxtField.text = currentUser?.firstname
        lastNameTxtField.text = currentUser?.lastname
        emailTxtField.text = currentUser?.email
        if currentUser?.avatar != "" {
            imageFromData(pictureData: currentUser!.avatar) { (image) in
                if image != nil {
                    self.userProfileImg.image = image!.circleMasked
                }
            }
        }
    }
    
    
    @IBAction func avatarImgTapped(_ sender: Any) {
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if firstNameTxtField.text != "" && lastNameTxtField.text != "" && emailTxtField.text != "" {
            ProgressHUD.show("Saving...")
            //Block save button
            saveBtn.isEnabled = false
            let fullName = firstNameTxtField.text! + " " + lastNameTxtField!.text!
            var withValues = [kFIRSTNAME : firstNameTxtField.text!, kLASTNAME : lastNameTxtField.text!, kFULLNAME : fullName]
            if avatarImage != nil {
                let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
                let avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                withValues[kAVATAR] = avatarString
            }
            //update current user
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error?.localizedDescription)
                        print("Couldn't update user \(error?.localizedDescription)")
                    }
                    return
                }
                ProgressHUD.showSuccess("Saved Successfully!")
                self.saveBtn.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            ProgressHUD.showError("All Fields are Required")
        }
    }
}
