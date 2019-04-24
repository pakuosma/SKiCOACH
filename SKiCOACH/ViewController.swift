//
//  ViewController.swift
//  SKiCOACH
//
//  Created by Markus Turtinen on 11.4.2019.
//  Copyright © 2019 Team Red. All rights reserved.
//
import UIKit
import WatchConnectivity
import MapKit
import CoreLocation
import CoreData

extension Notification.Name {
    static let receivedWatchMessage = Notification.Name("receivedWatchMessage")
}

class ViewController: UIViewController {
    
    @IBOutlet weak var skatingStyleImage: UIImageView!
    @IBOutlet weak var sensingSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var fromWatchLabel: UILabel!
    
    var locationSensor:LocationSensor? = nil
    var distance:Double = 0
    
    let session = WCSession.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceived), name: .receivedWatchMessage, object: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.locationSensor = appDelegate.locationSensor
        
//        if UserDefaults.standard.bool(forKey: LocationSensor.SENSOR_LOCATION_SETTING_STATUS) {
//            self.sensingSwitch.isOn = true
//        }else{
//            self.sensingSwitch.isOn = false
//        }

    }
    
    @objc func messageReceived(info: Notification)
    {
        let message = info.userInfo!
        DispatchQueue.main.async {
            self.fromWatchLabel.text = message["msg"] as? String
        }
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
            if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
                self.session.sendMessage(["msg":"start classic training"], replyHandler: nil, errorHandler: nil)
            }
            break
        case 1:
            skatingStyleImage.image = UIImage.init(named: "select-skate")
            if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
                self.session.sendMessage(["msg":"start skate training"], replyHandler: nil, errorHandler: nil)
            }
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



