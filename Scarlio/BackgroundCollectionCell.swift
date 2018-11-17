//
//  BackgroundCollectionCell.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/17/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

class BackgroundCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImg: UIImageView!
    
    func generateCell(image: UIImage) {
        self.backgroundImg.image = image
    }
}
