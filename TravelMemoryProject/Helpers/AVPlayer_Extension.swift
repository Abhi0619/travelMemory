//
//  AVPlayer_Extension.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//


import Foundation
import AVFoundation

extension AVPlayer {
    
    enum observableKey: String {
        case loadedTimeRanges = "currentItem.loadedTimeRanges"
    }
    
}
