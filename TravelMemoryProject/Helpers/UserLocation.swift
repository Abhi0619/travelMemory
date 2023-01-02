

import Foundation
import UIKit
import CoreLocation
import MapKit

enum LocationPermission: Int {
    case Accepted;
    case Denied;
    case Error;
}

class UserLocation: NSObject  {
    
    // MARK: - Variables
    var locationManger: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.activityType = .automotiveNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        return locationManager
    }()
    
    var permissionStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    // Will be assigned by host controller. If not set can throw Exception.
    typealias LocationBlock = (CLLocation?, NSError?)->()
    var completionBlock : LocationBlock? = nil
    weak var controller: UIViewController!
    
    // MARK: - Init
    static let sharedInstance = UserLocation()
    
    
    // MARk: - Func
    func fetchUserLocationForOnce( block: LocationBlock?) {
        
        locationManger.delegate = self
        completionBlock = block
        if checkAuthorizationStatus() {
            locationManger.startUpdatingLocation()
        }else{
            completionBlock?(nil,nil)
        }
    }
    
    func checkAuthorizationStatus() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        // If status is denied or only granted for when in use
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            let title = "k_location_no_access_title"
            let msg = "k_location_no_access_msg"
            
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            
            let cancel = UIAlertAction(title: "cancle_btn_title", style: UIAlertAction.Style.cancel, handler: nil)
            let settings = UIAlertAction(title: "setting_btn_title", style: UIAlertAction.Style.default, handler: { (action) in
                if #available(iOS 10.0, *) {
                   // UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                   // UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            })
            
            alert.addAction(cancel)
            alert.addAction(settings)
            if controller == nil {
              //  AppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }else {
                controller.present(alert, animated: true, completion: nil)
            }
            return false
        } else if status == CLAuthorizationStatus.notDetermined {
            locationManger.requestWhenInUseAuthorization()
            return false
        } else if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            return true
        }
        return false
    }
}

// MARK: - Location manager Delegation
extension UserLocation: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // let lastLocation = locations.last!
        
        manager.desiredAccuracy = 1000 // 1km accuracy
        if locations.last!.horizontalAccuracy > manager.desiredAccuracy {
            // This location is inaccurate. Throw it away and wait for the next call to the delegate.
            print("i don't want this location")
            return
        }
        // This is where you do something with your location that's accurate enough.
        guard let userLocation = locations.first else {
            print("error getting user location")
            return
        }
        DispatchQueue.main.async {
            self.completionBlock?(userLocation,nil)
            manager.stopUpdatingLocation()
            self.completionBlock = nil
        }
        
    }
    
    func addressFromlocation(location: CLLocation, block: @escaping (String)->()){
        let geoLocation = CLGeocoder()
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if let pmark = placeMarks, pmark.count > 0 {
                let place :CLPlacemark = pmark.last! as CLPlacemark
                if let addr = place.addressDictionary {
                    var str = ""
                    if let arr = addr["FormattedAddressLines"] as? NSArray{
                        str = arr.componentsJoined(by: ",")
                    }
                    block(str)
                }
            }
        })
    }
    func filterAndAddLocation(_ location: CLLocation) -> Bool{
        let age = -location.timestamp.timeIntervalSinceNow
        
        if age > 10{
            return false
        }
        
        if location.horizontalAccuracy < 0{
            return false
        }
        
        if location.horizontalAccuracy > 100{
            return false
        }
        
        
        return true
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.completionBlock?(nil,error as NSError?)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManger.startUpdatingLocation()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
