//
//  String_Extension.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//


import Foundation
import AVFoundation

//MARK: String Extensions
extension String {
    
    static func duration(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let secondsText = String(format: "%02d", Int(totalSeconds) % 60)
        let minutesText = String(format: "%02d", Int(totalSeconds) / 60)
        return  "\(minutesText):\(secondsText)"
    }
    
}
