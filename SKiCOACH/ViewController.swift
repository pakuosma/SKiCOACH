//
//  ViewController.swift
//  SKiCOACH
//
//  Created by Elina Kuosmanen on 12/03/2019.
//  Copyright © 2019 Elina Kuosmanen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var skatingStyleImage: UIImageView!
    @IBOutlet weak var sensingSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var locationSensor:LocationSensor? = nil
    
    var distance:Double = 0
    
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.locationSensor = appDelegate.locationSensor
        
//        if UserDefaults.standard.bool(forKey: LocationSensor.SENSOR_LOCATION_SETTING_STATUS) {
//            self.sensingSwitch.isOn = true
//        }else{
//            self.sensingSwitch.isOn = false
//        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.didChangeDatePicker(_sender: datePicker)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        if let observer = locationUpdateObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
    }

    @IBAction func didChangeSensingSwitch(_ sender: UISwitch) {
        if sender.isOn {
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways,.authorizedWhenInUse,.notDetermined:
                UserDefaults.standard.set(true,
                                            forKey: LocationSensor.SENSOR_LOCATION_SETTING_STATUS)
                self.locationSensor!.start()
                self.didChangeDatePicker(_sender: datePicker)
            case .restricted,.denied:
                sender.isOn = false
                break
            }
        }else{
            self.locationSensor!.stop()
            UserDefaults.standard.set(false,
                                      forKey: LocationSensor.SENSOR_LOCATION_SETTING_STATUS)
        }
    }
    
    @IBAction func didChangeDatePicker(_sender: UIDatePicker) {
        
        if let sensor = self.locationSensor{
            if let locations = sensor.getLocations(on: datePicker.date){
                mapView!.removeAnnotations(mapView!.annotations)
                
                for location in locations {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude,
                                                                    longitude: location.longitude)
                    mapView!.addAnnotation(annotation)
                }
                
            }
        }
    }
    @IBAction func pushedSkatingStyleButtons(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            skatingStyleImage.image = UIImage.init(named: "select-classic")
            break
        case 1:
            skatingStyleImage.image = UIImage.init(named: "select-skate")
            break
        default:
            break
        }
    }
    

}

extension Date {
    func roundDate(calendar cal: Calendar) -> Date {
        let year  = cal.component(.year, from: self)
        let month = cal.component(.month, from: self)
        let day   = cal.component(.day, from: self)
        return cal.date(from: DateComponents(year: year, month: month, day: day))!
    }
}



