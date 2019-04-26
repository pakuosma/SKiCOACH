//
//  SessionViewController.swift
//  SKiCOACH
//
//  Created by Markus Turtinen on 11.4.2019.
//  Copyright © 2019 Team Red. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import MapKit

class SessionViewController: UIViewController {

    var locationSensor:LocationSensor? = nil
    var locationUpdateObserver:Any? = nil
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.locationSensor = appDelegate.locationSensor
        self.locationSensor?.setLocationHandler{ locations in
            for location in locations {
                print(location)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            
            self.locationSensor!.start()
            
            self.locationSensor?.setLocationHandler({ (locations) in
                for location in locations{
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    let anotation = MKPointAnnotation()
                    anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    print(location)
                    // self.mapView!.addAnnotation(anotation)
                }
            })
            
            break
        case .restricted:
            break
        case .denied:
            break
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        if let observer = locationUpdateObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
//
//        self.locationSensor!.stop()
//        UserDefaults.standard.set(false, forKey: LocationSensor.SENSOR_LOCATION_SETTING_STATUS)
//    }

}



//class LocationSensor: NSObject, CLLocationManagerDelegate{
//  let locationManager = CLLocationManager()
//override init(){
//  super.init()
//locationManager.delegate = self
//    }

//  func start(){

//}
//  func stop(){

// }
//  func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){

//    }
//  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation] ){
//}
//}

