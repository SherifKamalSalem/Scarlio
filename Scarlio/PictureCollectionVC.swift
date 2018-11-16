//
//  PictureCollectionVC.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/16/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

class PictureCollectionVC: UICollectionViewController {

    var allImages: [UIImage] = []
    var allImagesLinks: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "All Pictures"
        if allImagesLinks.count > 0 {
            downloadImages()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return allImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! PictureCell
        cell.generateCell(image: allImages[indexPath.row])
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = IDMPhoto.photos(withImages: allImages)
        let browser = IDMPhotoBrowser(photos: photos)
        browser?.displayDoneButton = true
        browser?.setInitialPageIndex(UInt(indexPath.row))
        self.present(browser!, animated: true, completion: nil)
    }
    
    //MARK: Download Images
    func downloadImages() {
        for imageLink in allImagesLinks {
            downloadImage(imageUrl: imageLink) { (image) in
                if image != nil {
                    self.allImages.append(image!)
                    self.collectionView.reloadData()
                }
            }
        }
    }

}
