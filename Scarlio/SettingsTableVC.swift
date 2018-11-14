//
//  SettingsTableVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/12/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    //MARK: Logout
    @IBAction func logoutBtnPressed(_ sender: Any) {
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
    }
    
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcomeVC")
        present(mainView, animated: true, completion: nil)
    }
}
