//
//  BackgroundCollectionVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import ProgressHUD

class BackgroundCollectionVC: UICollectionViewController {

    var backgrounds: [UIImage] = []
    let userDefaults = UserDefaults.standard
    private let imagesNames = ["bg0", "bg1", "bg2", "bg3", "bg4", "bg5", "bg6", "bg7", "bg8", "bg9", "bg10", "bg11"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetToDefaults))
        self.navigationItem.rightBarButtonItem = resetButton
        setupImageArray()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return backgrounds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "backgroundCollectionCell", for: indexPath) as! BackgroundCollectionCell
        
        cell.generateCell(image: backgrounds[indexPath.row])
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userDefaults.set(imagesNames[indexPath.row], forKey: kBACKGROUNDIMAGE)
        userDefaults.synchronize()
        ProgressHUD.showSuccess("Set Successfully!")
    }
    
    //MARK: Helper funcs
    func setupImageArray() {
        for imageName in imagesNames {
            let image = UIImage(named: imageName)
            if image != nil {
                backgrounds.append(image!)
            }
        }
    }
    
    @objc func resetToDefaults() {
        userDefaults.removeObject(forKey: kBACKGROUNDIMAGE)
        userDefaults.synchronize()
        ProgressHUD.showSuccess("Reset Successfully!")
    }
}
