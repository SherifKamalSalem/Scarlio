//
//  UserTableViewCell.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/12/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

protocol UserTableDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class UserTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    //MARK: Variables
    var indexPath: IndexPath!
    var tapGestureRecognizer = UITapGestureRecognizer()
    var delegate: UserTableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGestureRecognizer.addTarget(self, action: #selector(avatarTap))
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func generateCellWith(fUser: FUser, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.fullNameLbl.text = fUser.fullname
        if fUser.avatar != "" {
            imageFromData(pictureData: fUser.avatar) { (avatar) in
                if avatar != nil {
                    self.userImg.image = avatar!.circleMasked
                }
            }
        }
    }
    
    @objc func avatarTap() {
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }
}
