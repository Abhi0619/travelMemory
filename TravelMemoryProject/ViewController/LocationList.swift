//
//  LocationList.swift
//  TravelMemoryProject
//
//  Created by IPS-161 on 12/12/22.
//

import UIKit
import AVFoundation
import AVKit
class LocationList: UIViewController {
    
    @IBOutlet weak var locationTblView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    var arrData: [TravelMemory] = []
    var playerviewcontroller = AVPlayerViewController()
    var playerview = AVPlayer ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationTblView.delegate = self
        self.locationTblView.dataSource = self
        fetchCoreData()
    }
    func fetchCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
            if let Coredata = try? context.fetch(TravelMemory.fetchRequest()) as! [TravelMemory]{
                arrData = Coredata
                print(arrData.count)
            }
        }
    }
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 15, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}
extension LocationList {
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
extension LocationList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        lblNoData.text = arrData.count == 0 ? "No Avaliable Data" : ""
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! locationCell
        let fileName = URL(fileURLWithPath: "\(arrData[indexPath.row].videoUrl)").deletingPathExtension().lastPathComponent

        Swift.print(fileName)
        cell.lblVideoURL.text = fileName
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("---------------------------")
        if let filevideoUrl = arrData[indexPath.row].videoUrl {
            playerview = AVPlayer(url: filevideoUrl)
            playerviewcontroller.player = playerview
            self.present(playerviewcontroller, animated: true){
                self.playerviewcontroller.player?.play()
            }
        }
    }
    
}

