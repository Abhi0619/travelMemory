//
//  VideoService.swift
//  CoreMediaDemo
//
//  Created by Tim Beals on 2018-10-12.
//  Copyright © 2018 Roobi Creative. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import SwiftUI
import CoreData
import Toaster
import GoogleMaps

protocol VideoServiceDelegate {
    func videoDidFinishSaving(error: Error?, url: URL?)
}

class VideoService: NSObject {
    var locationManager = CLLocationManager()
    var delegate: VideoServiceDelegate?
    let picker = UIImagePickerController()
    var latitude:CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var isReversebtnTapped: Bool = false
    static let instance = VideoService()
    private override init() {
        super.init()
        // determineMyCurrentLocation()
        fetchUserLocation()
    }
    
}

extension VideoService {
    
    private func isVideoRecordingAvailable() -> Bool {
        let front = UIImagePickerController.isCameraDeviceAvailable(.front)
        let rear = UIImagePickerController.isCameraDeviceAvailable(.rear)
        if !front || !rear {
            return false
        }
        guard let media = UIImagePickerController.availableMediaTypes(for: .camera) else {
            return false
        }
        return media.contains(kUTTypeMovie as String)
    }
    
    
    private func setupVideoRecordingPicker() -> UIImagePickerController {
        
        lazy var SaveButton: UIButton = {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(stopButton), for: .touchUpInside)
            btn.setImage(UIImage(named: "stopIcon"), for: .normal)
            btn.frame.size = CGSize(width: 50, height: 50)
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()
        lazy var reverceButton: UIButton = {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(reverseBtnTapped), for: .touchUpInside)
            btn.setImage(UIImage(named: "rotateCamera"), for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()
        
        lazy var StopLabel: UILabel = {
            let lbl = UILabel()
            lbl.text = "Stop Recording"
            lbl.textColor = UIColor.red
            return lbl
        }()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraDevice =  .rear
        picker.videoQuality = .typeMedium
        picker.mediaTypes = [kUTTypeMovie as String]
        // picker.showsCameraControls = false
        picker.allowsEditing = false
        
        
        
        
        // create the overlay view
        let overlayView = UIView()
        overlayView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // important - it needs to be transparent so the camera preview shows through!
        overlayView.isOpaque = false
        
        picker.view.addSubview(overlayView)
        picker.view.addSubview(SaveButton)
        picker.view.addSubview(StopLabel)
        picker.view.addSubview(reverceButton)
        
        
        
        SaveButton.centerXAnchor.constraint(equalTo: picker.view.centerXAnchor).isActive = true
        StopLabel.centerXAnchor.constraint(equalTo: picker.view.centerXAnchor).isActive = true
        
        
        //with this line you are telling the button to position itself vertically 100 from the bottom of the view. you can change the number to whatever suits your needs
        SaveButton.bottomAnchor.constraint(equalTo: picker.view.bottomAnchor, constant: -75).isActive = true
        StopLabel.bottomAnchor.constraint(equalTo: picker.view.bottomAnchor, constant: -10).isActive = true
        reverceButton.bottomAnchor.constraint(equalTo: picker.view.bottomAnchor, constant: -90).isActive = true
        reverceButton.leftAnchor.constraint(equalTo: SaveButton.rightAnchor, constant: 20).isActive = true
        reverceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        reverceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        // hide the camera controls
        picker.showsCameraControls = false
        picker.cameraOverlayView = overlayView
        
        
        return picker
    }
    @objc func reverseBtnTapped() {
        isReversebtnTapped = true
        picker.stopVideoCapture()
        picker.cameraDevice = picker.cameraDevice == .rear ? .front : .rear
        picker.startVideoCapture()
    }
    @objc func stopButton() {
        isReversebtnTapped = false
        picker.stopVideoCapture()
    }
    
    func launchVideoRecorder(in vc: UIViewController, completion: (() -> ())?) {
        guard isVideoRecordingAvailable() else {
            return }
        
        let picker = setupVideoRecordingPicker()
        if Device.isPhone {
            vc.present(picker, animated: true) {
                
                picker.startVideoCapture()
                Toast(text: "Recording Started").show()
                completion?()
            }
        }
    }
    
    
    private func saveVideo(at mediaUrl: URL) {
        let compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mediaUrl.path)
        if compatible {
            
            UISaveVideoAtPathToSavedPhotosAlbum(mediaUrl.path, self, #selector(video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            Toast(text: "Video Saved!").show()
        }
    }
    
    @objc func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        let videoURL = URL(fileURLWithPath: videoPath as String)
        if !isReversebtnTapped {
            exit(-1)
        }
        
        //  self.delegate?.videoDidFinishSaving(error: error, url: videoURL)
    }
    
    func fetchUserLocation() {
        UserLocation.sharedInstance.fetchUserLocationForOnce() { (location, error) in
            if let location = location {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                print(self.latitude)
                print(self.longitude)
            }else {
                
            }
            
        }
    }
}

extension VideoService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let newItem = TravelMemory(context:context)
            if let latitude = self.latitude,let longitude = self.longitude  {
                newItem.videoUrl = "\(mediaURL)"
                newItem.latitude = Double(latitude)
                newItem.longitude = Double(longitude)
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                self.saveVideo(at: mediaURL)
            }else {
                Toast(text: "Please allow location access to save your video").show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    exit(-1)
                }
            }
        }
    }
}
