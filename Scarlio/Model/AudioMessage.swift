//
//  AudioMessage.swift
//  Scarlio
//
//  Created by Sherif Kamal on 11/16/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioMessage {
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target: UIViewController) {
        let controller = IQAudioRecorderViewController()
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
