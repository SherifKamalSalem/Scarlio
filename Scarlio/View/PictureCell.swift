//
//  PictureCell.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/16/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
}
