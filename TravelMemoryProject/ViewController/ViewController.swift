//
//  ViewController.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//

import UIKit
import MapKit
import AVKit
import AVFoundation
import GoogleMaps
class ViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate {
    //MARK: - IBOutlet
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var mapKitView: MKMapView!
    var locationManager = CLLocationManager()
    
    //MARK: - Instance Method
    var isFromWidget: Bool = false
    var arrData: [TravelMemory] = []
    var playerviewcontroller = AVPlayerViewController()
    var playerview = AVPlayer ()
    var latitude:CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    //Application Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if isFromWidget {
            VideoService.instance.launchVideoRecorder(in: self, completion: nil)
            VideoService.instance.delegate = self
        }
        //        determineMyCurrentLocation()
        
        //MARK: GOOGLEMAP
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 1000
        self.locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreData()
        createDirectoryPath()
    }
    
    //MARK: GOOGLEMAP METHOD
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 20)
        self.googleMapView.animate(to: camera)
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
    @IBAction func btnSystemTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SystemVC") as! SystemVC
        navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - Application Mehod
extension ViewController {
    
    func setRegionWhenLatLongGet() {
        if CLLocationManager.locationServicesEnabled() {
            mapKitView.showsUserLocation = true
            mapKitView.delegate = self
            if let latitude = latitude, let longitude = longitude {
                mapKitView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 10, longitudinalMeters: 10), animated: true)
            }
            fetchStadiumsOnMap(arrData)
            locationManager.stopUpdatingLocation()
        } else {
            // Do something to let users know why they need to turn it on.
            
        }
    }
    
    func fetchStadiumsOnMap(_ stadiums: [TravelMemory]) {
        for stadium in stadiums {
            let marker = MyGMSMarker()
            marker.position = CLLocationCoordinate2D(latitude:
                                                        stadium.latitude as! CLLocationDegrees, longitude: stadium.longitude as! CLLocationDegrees)
            marker.title = "I added this with a long tap"
            marker.snippet = ""
            marker.identifier = stadium.videoUrl
            marker.map = googleMapView
            
            
            /*let annotations = MyPointAnnotation()
            annotations.identifier = stadium.videoUrl
            print(latitude)
            print(longitude)
            annotations.coordinate = CLLocationCoordinate2D(latitude:
                                                                stadium.latitude as! CLLocationDegrees, longitude: stadium.longitude as! CLLocationDegrees)
            mapKitView.addAnnotation(annotations)*/
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let marker = marker as? MyGMSMarker {
            if let string = marker.identifier {
                print(string)
                let fileURL = NSURL(fileURLWithPath:"\(string)")
                print(fileURL)
                playerview = AVPlayer(url: string)
                playerviewcontroller.player = playerview
                self.present(playerviewcontroller, animated: true){
                    self.playerviewcontroller.player?.play()
                }
            }
        }
        return true
    }
   
    func fetchCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
            if let Coredata = try? context.fetch(TravelMemory.fetchRequest()) as! [TravelMemory]{
                arrData = Coredata
                print(arrData.count)
                fetchStadiumsOnMap(arrData)
            }
        }
    }
    
    func createDirectoryPath() {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let DirPath = DocumentDirectory.appendingPathComponent("FOLDER_NAME")
        let fileManager = FileManager.default
        let filePath = DirPath!.path
        if !fileManager.fileExists(atPath: filePath){
            do
            {
                try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
                UserDefaults.standard.set(DirPath!.path, forKey: "DirectoryPath")
            }
            catch let error as NSError
            {
                print("Unable to create directory \(error.debugDescription)")
            }
        }else{
            print("Folder Available....")
        }
        print("Dir Path = \(DirPath!)")
    }
    
}

//MARK: - MapView Extension
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let a = view.annotation as? MyPointAnnotation {
            if let string = a.identifier {
                print(string)
                let fileURL = NSURL(fileURLWithPath:"\(string)")
                print(fileURL)
                playerview = AVPlayer(url: fileURL as URL)
                playerviewcontroller.player = playerview
                self.present(playerviewcontroller, animated: true){
                    self.playerviewcontroller.player?.play()
                }
            }
        }
    }
}

//MARK: - For adding extra Paremeter in MKPointAnnotation
class MyPointAnnotation : MKPointAnnotation {
    var identifier: String?
}

//MARK: - Video Service Protocol Delegate Method
extension ViewController: VideoServiceDelegate {
    func videoDidFinishSaving(error: Error?, url: URL?) {
        let success: Bool = error == nil
        if success {
            
        }
        let title = success ? "Success" : "Error"
        let message = success ? "Video was saved" : "Could not save video"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
/*
 //MARK: - MAP Location Delegate Method
 extension ViewController: CLLocationManagerDelegate {
 func determineMyCurrentLocation() {
 locationManager = CLLocationManager()
 locationManager.delegate = self
 locationManager.desiredAccuracy = kCLLocationAccuracyBest
 
 locationManager.requestAlwaysAuthorization()
 
 if CLLocationManager.locationServicesEnabled() {
 locationManager.startUpdatingLocation()
 //locationManager.startUpdatingHeading()
 
 }
 }
 
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 let userLocation:CLLocation = locations[0] as CLLocation
 
 // Call stopUpdatingLocation() to stop listening for location updates,
 // other wise this function will be called every time when user location changes.
 
 // manager.stopUpdatingLocation()
 
 print("user latitude = \(userLocation.coordinate.latitude)")
 print("user longitude = \(userLocation.coordinate.longitude)")
 latitude = userLocation.coordinate.latitude
 longitude = userLocation.coordinate.longitude
 setRegionWhenLatLongGet()
 //        addAsset(image: UIImage(named: "img")!, location: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) )
 }
 
 func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
 {
 print("Error \(error)")
 }
 }*/
class MyGMSMarker: GMSMarker {
    
    var identifier: URL?
}
