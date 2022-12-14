//
//  UISlider_Extension.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//


import UIKit
import AVFoundation

extension UISlider {
    
    func setSliderValue(for player: AVPlayer, progress: CMTime) {
        guard let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let progressSeconds = CMTimeGetSeconds(progress)
        self.value = Float(progressSeconds / totalSeconds)
    }
    
}
