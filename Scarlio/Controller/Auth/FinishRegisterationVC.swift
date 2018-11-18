//
//  FinishRegisterationVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/9/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class FinishRegisterationVC: UIViewController {

    //MARK:Outlets
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var surnameTxtField: UITextField!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet var avatarTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var avatarImg: UIImageView!
    //MARK: Variables
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImg.isUserInteractionEnabled = true
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        if nameTxtField.text != "" && cityTxtField.text != "" && phoneTxtField.text != "" && countryTxtField.text != "" && surnameTxtField.text != "" {
            FUser.registerUserWith(email: email, password: password, firstName: nameTxtField.text!, lastName: surnameTxtField.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                self.registerUser()
            }
        }
    }
    
    func registerUser() {
        let fullName = nameTxtField.text! + " " + surnameTxtField.text!
        var tempDict: Dictionary = [kFIRSTNAME : nameTxtField.text!, kLASTNAME : surnameTxtField.text, kFULLNAME : fullName, kCOUNTRY : countryTxtField.text!, kCITY : cityTxtField.text!, kPHONE: phoneTxtField.text!] as [String : Any]
        if avatarImage == nil {
            imageFromInitials(firstName: nameTxtField.text!, lastName: surnameTxtField.text!) { (avatarInitials) in
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                tempDict[kAVATAR] = avatar
                self.finishRegistration(withValue: tempDict)
            }
        } else {
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.5)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDict[kAVATAR] = avatar
            self.finishRegistration(withValue: tempDict)
        }
    }
    
    func finishRegistration(withValue value: [String: Any]) {
        updateCurrentUserInFirestore(withValues: value) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                }
                return
            }
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func avatarImgTapped(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
        dismissKeyboard()
    }
    
    
    func goToApp() {
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        nameTxtField.text = ""
        surnameTxtField.text = ""
        countryTxtField.text = ""
        cityTxtField.text = ""
        phoneTxtField.text = ""
    }
}

extension FinishRegisterationVC : ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.avatarImage = images.first!
            self.avatarImg?.image = self.avatarImage!.circleMasked
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
