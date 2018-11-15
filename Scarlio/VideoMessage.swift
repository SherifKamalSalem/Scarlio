//
//  VideoMessage.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/15/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import ProgressHUD

class VideoMessage: JSQMediaItem {
    
    var image: UIImage?
    var videoImgView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    init(withFileURL: NSURL, maskOutgoing: Bool) {
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        videoImgView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        if let status = status {
            print("status \(status)")
            if status == 1 {
                return nil
            }
            
            if status == 2 && (self.videoImgView == nil) {
                let size = self.mediaViewDisplaySize()
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                let icon = UIImage.jsq_defaultPlay()?.jsq_imageMasked(with: .white)
                let iconView = UIImageView(image: icon)
                iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                iconView.contentMode = .center
                
                let imageView = UIImageView(image: self.image!)
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                self.videoImgView = imageView
            }
        }
        return self.videoImgView
    }
}
