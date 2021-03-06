//
//  PhotoMediaItem.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/15/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem {
    
    override func mediaViewDisplaySize() -> CGSize {
        let defaultSize: CGFloat = 256
        var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
        if self.image != nil && self.image.size.height > 0 && self.image.size.width > 0 {
            let aspect = self.image.size.width / self.image.size.height
            if self.image.size.width > self.image.size.height {
                thumbSize = CGSize(width: defaultSize, height: defaultSize / aspect)
            } else {
                thumbSize = CGSize(width: defaultSize * aspect, height: defaultSize)
            }
        }
        return thumbSize
    }
}
