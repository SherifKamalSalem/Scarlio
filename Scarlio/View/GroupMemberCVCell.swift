//
//  GroupMemberCVCell.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

protocol GroupMemberCVCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCVCell: UICollectionViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    var indexPath: IndexPath!
    
    //MARK: - Variables
    var delegate: GroupMemberCVCellDelegate?
    
    func generateCell(user: FUser, indexPath: IndexPath) {
        self.indexPath = indexPath
        nameLbl.text = user.firstname
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (image) in
                if image != nil {
                    self.userProfileImg.image = image!.circleMasked
                }
            }
        }
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        
    }
    
}
