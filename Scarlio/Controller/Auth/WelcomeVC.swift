//
//  WelcomeCV.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/7/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeVC: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var repeatTxtField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: IBActions
    @IBAction func loginBtnPressed(_ sender: Any) {
        dismissKeyboard()
        if emailTxtField.text != "" && passwordTxtField.text != "" {
            loginUser()
        } else {
            ProgressHUD.showError("Email and Password is missing")
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        dismissKeyboard()
        if emailTxtField.text != "" && passwordTxtField.text != "" && repeatTxtField.text != "" {
            if passwordTxtField.text == repeatTxtField.text {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords don't match")
            }
            
        } else {
            ProgressHUD.showError("Email and Password is missing")
        }
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func loginUser() {
        ProgressHUD.show("Login...")
        FUser.loginUserWith(email: emailTxtField.text!, password: passwordTxtField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            self.goToApp()
        }
    }
    
    func registerUser() {
        performSegue(withIdentifier: "toFinishReg", sender: self)
        cleanTextFields()
        dismissKeyboard()
    }
    //MARK: Go to App
    func goToApp() {
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    func cleanTextFields() {
        emailTxtField.text = ""
        passwordTxtField.text = ""
        repeatTxtField.text = ""
    }
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFinishReg" {
            let vc = segue.destination as! FinishRegisterationVC
            vc.email = emailTxtField.text!
            vc.password = passwordTxtField.text!
        }
    }
}
