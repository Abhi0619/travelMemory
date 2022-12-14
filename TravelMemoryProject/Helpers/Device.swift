//
//  Device.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//


import UIKit

struct Device {
    
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
}
