//
//  RecentChatsCell.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/13/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

protocol RecentChatsDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatsCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var lastMsgLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var msgCounterLbl: UILabel!
    @IBOutlet weak var msgCounterBGView: UIView!
    //MARK: Variables
    var indexPath: IndexPath!
    let tapGesture = UITapGestureRecognizer()
    var delegate: RecentChatsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msgCounterBGView.layer.cornerRadius = msgCounterBGView.frame.width / 2
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        userProfileImg.addGestureRecognizer(tapGesture)
    }

    //MARK: Configure Cell
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.nameLbl.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMsgLbl.text = recentChat[kLASTMESSAGE] as? String
        self.msgCounterLbl.text = recentChat[kCOUNTER] as? String
        if let avatarStr = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarStr as! String) { (avatarImg) in
                if avatarImg != nil {
                    self.userProfileImg.image = avatarImg!.circleMasked
                }
            }
        }
        if recentChat[kCOUNTER] as! Int != 0 {
            self.msgCounterLbl.text = "\(recentChat[kCOUNTER] as! Int)"
            self.msgCounterBGView.isHidden = false
            self.msgCounterLbl.isHidden = false
        } else {
            self.msgCounterBGView.isHidden = true
            self.msgCounterLbl.isHidden = true
        }
        var date: Date!
        if let createdAt = recentChat[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: createdAt as! String)
            }
        } else {
            date = Date()
        }
        self.dateLbl.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap() {
        print("avatar tap \(indexPath)")
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }
}
