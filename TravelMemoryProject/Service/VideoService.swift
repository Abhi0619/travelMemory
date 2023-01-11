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
import Foundation
import AVKit

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
    
    var URLArr = [URL]()
    var StopVideoBtnTap = false
    typealias CompletionHandler = (_ success : URL) -> Void
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
        StopVideoBtnTap = true
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
    
    
    private func saveVideo(at mediaUrl: URL, completionHandler: CompletionHandler) {
        let compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mediaUrl.path)
        if compatible {
            UISaveVideoAtPathToSavedPhotosAlbum(mediaUrl.path, self, #selector(video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            Toast(text: "Video Saved!").show()
            print("Video Saved!")
            completionHandler(mediaUrl)
            
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
        URLArr.append(mediaURL)
        if self.StopVideoBtnTap {
            AVMutableComposition().mergeVideo(URLArr) { url, error in
                self.saveVideo(at: url!) { success in
                    print("Merged")
                    self.StopVideoBtnTap = false
                    self.URLArr.removeAll()
                    if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                        let newItem = TravelMemory(context:context)
                        if let latitude = self.latitude,let longitude = self.longitude  {
                            newItem.fileName = success.lastPathComponent
                            newItem.videoUrl = success
                            newItem.latitude = Double(latitude)
                            newItem.longitude = Double(longitude)
                            newItem.isSync = false
                            newItem.createdAt = Date.currentDate()
                            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                        }else {
                            Toast(text: "Please allow location access to save your video").show()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                exit(-1)
                            }
                        }
                    }
                }
            }
        }
        
    }
}

extension AVMutableComposition {
    
    func mergeVideo(_ urls: [URL], completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil, nil)
            return
        }
        
        let outputURL = documentDirectory.appendingPathComponent("\(Date.getCurrentDate()).mp4")
        
        // If there is only one video, we dont to touch it to save export time.
        if let url = urls.first, urls.count == 1 {
            do {
                try FileManager().copyItem(at: url, to: outputURL)
                completion(outputURL, nil)
            } catch let error {
                completion(nil, error)
            }
            return
        }
        
        let maxRenderSize = CGSize(width: 1280.0, height: 720.0)
        var currentTime = CMTime.zero
        var renderSize = CGSize.zero
        // Create empty Layer Instructions, that we will be passing to Video Composition and finally to Exporter.
        var instructions = [AVMutableVideoCompositionInstruction]()
        
        urls.enumerated().forEach { index, url in
            let asset = AVAsset(url: url)
            let assetTrack = asset.tracks.first!
            
            // Create instruction for a video and append it to array.
            let instruction = AVMutableComposition.instruction(assetTrack, asset: asset, time: currentTime, duration: assetTrack.timeRange.duration, maxRenderSize: maxRenderSize)
            instructions.append(instruction.videoCompositionInstruction)
            
            // Set render size (orientation) according first video.
            if index == 0 {
                renderSize = instruction.isPortrait ? CGSize(width: maxRenderSize.height, height: maxRenderSize.width) : CGSize(width: maxRenderSize.width, height: maxRenderSize.height)
            }
            
            do {
                let timeRange = CMTimeRangeMake(start: .zero, duration: assetTrack.timeRange.duration)
                // Insert video to Mutable Composition at right time.
                try insertTimeRange(timeRange, of: asset, at: currentTime)
                currentTime = CMTimeAdd(currentTime, assetTrack.timeRange.duration)
            } catch let error {
                completion(nil, error)
            }
        }
        
        // Create Video Composition and pass Layer Instructions to it.
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = instructions
        // Do not forget to set frame duration and render size. It will crash if you dont.
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = renderSize
        
        guard let exporter = AVAssetExportSession(asset: self, presetName: AVAssetExportPreset1280x720) else {
            completion(nil, nil)
            return
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        // Pass Video Composition to the Exporter.
        exporter.videoComposition = videoComposition
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exporter.outputURL, nil)
            }
        }
    }
    
    static func instruction(_ assetTrack: AVAssetTrack, asset: AVAsset, time: CMTime, duration: CMTime, maxRenderSize: CGSize)
    -> (videoCompositionInstruction: AVMutableVideoCompositionInstruction, isPortrait: Bool) {
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        
        // Find out orientation from preffered transform.
        let assetInfo = orientationFromTransform(assetTrack.preferredTransform)
        
        // Calculate scale ratio according orientation.
        var scaleRatio = maxRenderSize.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleRatio = maxRenderSize.height / assetTrack.naturalSize.height
        }
        
        // Set correct transform.
        var transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        transform = assetTrack.preferredTransform.concatenating(transform)
        layerInstruction.setTransform(transform, at: .zero)
        
        // Create Composition Instruction and pass Layer Instruction to it.
        let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
        videoCompositionInstruction.timeRange = CMTimeRangeMake(start: time, duration: duration)
        videoCompositionInstruction.layerInstructions = [layerInstruction]
        
        return (videoCompositionInstruction, assetInfo.isPortrait)
    }
    
    static func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        
        switch [transform.a, transform.b, transform.c, transform.d] {
        case [0.0, 1.0, -1.0, 0.0]:
            assetOrientation = .right
            isPortrait = true
            
        case [0.0, -1.0, 1.0, 0.0]:
            assetOrientation = .left
            isPortrait = true
            
        case [1.0, 0.0, 0.0, 1.0]:
            assetOrientation = .up
            
        case [-1.0, 0.0, 0.0, -1.0]:
            assetOrientation = .down
            
        default:
            break
        }
        
        return (assetOrientation, isPortrait)
    }
    
}
