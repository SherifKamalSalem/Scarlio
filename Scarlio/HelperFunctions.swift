//
//  HelperFunctions.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/7/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

private let dateFormat = "yyyyMMddHHmmss"

//MARK: Global Functions
func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func imageFromInitials(firstName: String?, lastName: String?, withBlock: @escaping (_ image: UIImage) -> Void) {
    var string: String!
    var size = 36
    
    if firstName != nil && lastName != nil {
        string = String(firstName!.first!).uppercased() + String(lastName!.first!).uppercased()
    } else {
        string = String(firstName!.first!).uppercased()
        size = 72
    }
    
    let lblNameInitialize = UILabel()
    lblNameInitialize.frame.size = CGSize(width: 100, height: 100)
    lblNameInitialize.textColor = .white
    lblNameInitialize.font = UIFont(name: lblNameInitialize.font.fontName, size: CGFloat(size))
    lblNameInitialize.text = string
    lblNameInitialize.textAlignment = NSTextAlignment.center
    lblNameInitialize.backgroundColor = .lightGray
    lblNameInitialize.layer.cornerRadius = 25
    
    UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
    lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    withBlock(img!)
}

func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void) {
    var image: UIImage?
    let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
    image = UIImage(data: decodedData! as Data)
    withBlock(image)
}

//MARK: getting the time elapsed from last update (just now , min, hour)
func timeElapsed(date: Date) -> String {
    let seconds = NSDate().timeIntervalSince(date)
    var elapsed: String?
    if seconds < 60 {
        elapsed = "Just now"
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        var minTxt = "min"
        if minutes > 1 {
            minTxt = "mins"
        }
        elapsed = "\(minutes) \(minTxt)"
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        var hourTxt = "hour"
        if hours > 1 {
            hourTxt = "hours"
        }
        elapsed = "\(hours) \(hourTxt)"
    } else {
        let currentDateFormatter = dateFormatter()
        currentDateFormatter.dateFormat = "dd/MM/YYYY"
        elapsed = "\(currentDateFormatter.string(from: date))"
    }
    return elapsed!
}

//MARK: for avatar
func dataImageFromString(pictureString: String, withBlock: (_ image: Data?) -> Void) {
    let imageData = NSData(base64Encoded: pictureString, options: NSData.Base64DecodingOptions(rawValue: 0))
    withBlock(imageData as Data?)
}

//MARK: for calls and chats
func dictionaryFromSnapshots(snapshots: [DocumentSnapshot]) -> [NSDictionary]  {
    var allMessages: [NSDictionary] = []
    for snapshot in snapshots {
        allMessages.append(snapshot.data() as! NSDictionary)
    }
    return allMessages
}

//MARK: UIImageExtensiion for making circular masked effect
extension UIImage {
    var isPortrait:  Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func scaleImageToSize(newSize: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
