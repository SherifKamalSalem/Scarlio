//
//  EditGroupVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/18/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class EditGroupVC: UIViewController {

    @IBOutlet weak var userProfileImg: UIImageView!
    
    //MARK: - Outlets
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var groupSubjectTxtField: UITextField!
    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    //MARK: - Variables
    var group: NSDictionary!
    var groupIcon: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraImageView.isUserInteractionEnabled = true
        cameraImageView.addGestureRecognizer(iconTapGesture)
        
        setupUI()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Invite Users", style: .plain, target: self, action: #selector(inviteUsers))]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveBtn.layer.cornerRadius = 8
    }
    
    //MARK: Helper Function
    
    func setupUI() {
        self.title = "Group"
        groupSubjectTxtField.text = group[kNAME] as? String
        imageFromData(pictureData: group[kAVATAR] as! String) { (image) in
            if image != nil {
                self.cameraImageView.image = image?.circleMasked
            }
        }
    }
    
    func showIconOptions() {
        let optionMenu = UIAlertController(title: "Choose Group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (action) in
            
        }
        if groupIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
                self.groupIcon = nil
                self.cameraImageView.image = UIImage(named: "cameraIcon")
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
    
    //MARK: IBActions
    
    @IBAction func editBtnPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func iconTapGestureTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
    }
    
    @objc func inviteUsers() {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "inviteUsersTableVC") as! InviteUsersTableVC
        userVC.group = group
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
}
