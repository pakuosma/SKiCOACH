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
import AVFoundation
import CoreLocation
import CoreData
import CoreMotion


extension Notification.Name {
    static let receivedWatchMessage = Notification.Name("receivedWatchMessage")
}

class ViewController: UIViewController {
    
    @IBOutlet weak var skatingStyleImage: UIImageView!
    @IBOutlet weak var sensingSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var fromWatchLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let session = WCSession.default
    let talker = AVSpeechSynthesizer()
    var motionManager = CMMotionManager()
    let sensorMessagePlayed = false
    
    var locationSensor:LocationSensor? = nil
    var distance:Double = 0
    
    @IBAction func tapToStart(_ sender: UIButton) {
        self.moveToSessionViewController()
    }

    func moveToSessionViewController(){
        //Open the view shown during a training
        if let sessionViewController = storyboard?.instantiateViewController(withIdentifier: "SessionViewController") as? SessionViewController {
            self.present(sessionViewController, animated: true, completion: nil)
        }
        
        //Check Watch-connectivity and notify user via the message send to the Watch, which speaks it out via Siri!
        if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
            self.session.sendMessage(["msg":"Let's ski Markus! Do your best!"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    @objc func messageReceived(info: Notification)
    {
        let message = info.userInfo!
        DispatchQueue.main.async {
            self.fromWatchLabel.text = message["msg"] as? String
        }
        if (message["msg"] as? String) == "ctrl_message_start_training_on_iphone" {
            print("debug: ctrl_message_start_training_on_iphone") //debug
            
            let utterance = AVSpeechUtterance(string: "Hi this is Siri on iPhone - starting the training here as well!")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.stopSpeaking(at: .immediate)
            talker.speak(utterance)
            
            //Receipt back to Watch
            self.session.sendMessage(["msg":"ctrl_message_start_training_ack"], replyHandler: nil, errorHandler: nil)
            
            //move state back to SessionViewController, enable iOS training start from Watch. This works.
            //DispatchQueue.main.async {
            //    self.moveToSessionViewController()
            //}
        }
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.locationSensor = appDelegate.locationSensor
        
        if sensorMessagePlayed == false {
            let utterance = AVSpeechUtterance(string: "Ski sensor attached. You'll get voice feedback during the training.")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.talker.stopSpeaking(at: .immediate)
            self.talker.speak(utterance)
            let sensorMessagePlayed = true
        }

        
        //greet a welcome via the attached AppleWatch
        if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
            self.session.sendMessage(["msg":"Hello! I'm Siri on Apple Watch and I'll be helping you ski better!"], replyHandler: nil, errorHandler: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageReceived), name: .receivedWatchMessage, object: nil)
        
        
        //let viewController = SessionViewController()
        //self.present(viewController, animated: true, completion: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //if let observer = locationUpdateObserver {
        //NotificationCenter.default.removeObserver(observer)
        //}
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
                self.session.sendMessage(["msg":"Train classic!"], replyHandler: nil, errorHandler: nil)
            }
            break
        case 1:
            skatingStyleImage.image = UIImage.init(named: "select-skate")
            if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
                self.session.sendMessage(["msg":"Train freestyle!"], replyHandler: nil, errorHandler: nil)
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



