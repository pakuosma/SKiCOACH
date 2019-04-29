//
//  SessionViewController.swift
//  SKiCOACH
//
//  Created by Markus Turtinen on 11.4.2019.
//  Copyright © 2019 Team Red. All rights reserved.
//

import UIKit
import WatchConnectivity
import AVFoundation
import CoreLocation
import UserNotifications
import MapKit


class SessionViewController: UIViewController {

    var timer = Timer()
    var lazyTimer = Timer()
    var heartBeatTimer = Timer()
    var distanceTimer = Timer()
    var feedbackTimer = Timer()
    var counter = 0.0
    let myInterval:TimeInterval = 1.0//15
    var trainingTime:TimeInterval = 0.0
    var locationSensor:LocationSensor? = nil
    var locationUpdateObserver:Any? = nil
    var debugStr = ""
    //var watchMessageSent = false
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var speedCurrentLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let session = WCSession.default
    let talker = AVSpeechSynthesizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceLabel.text = "\(counter)"
        //timer = Timer.scheduledTimer(timeInterval: 0.1, target:self,
        timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector:#selector(SessionViewController.fireUpdateTimer),
            userInfo: nil, repeats: true)
        lazyTimer = Timer.scheduledTimer(timeInterval: 3.0, target:self, selector:#selector(SessionViewController.fireLazyTimer),
                                     userInfo: nil, repeats: true)
        heartBeatTimer = Timer.scheduledTimer(timeInterval: 4.0, target:self, selector:#selector(SessionViewController.fireHeartBeatTimer),
                                         userInfo: nil, repeats: true)
        distanceTimer = Timer.scheduledTimer(timeInterval: 15.0, target:self, selector:#selector(SessionViewController.fireDistanceTimer),
                                              userInfo: nil, repeats: true)
        
        feedbackTimer = Timer.scheduledTimer(timeInterval: 14.0, target:self, selector:#selector(SessionViewController.fireFeedbackTimer),
                                             userInfo: nil, repeats: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.locationSensor = appDelegate.locationSensor
        self.locationSensor?.setLocationHandler{ locations in
            for location in locations {
                print(location)
            }
        }
    }
    
    @objc func fireUpdateTimer(){
        //counter += 0.1
        //timerLabel.text = String(format: "%.1f",counter)
        
        trainingTime += myInterval
        timerLabel.text = formatTimeInterval(timeInterval: trainingTime)
    }
    
    @objc func fireLazyTimer(){
        let speedCurrent = Int.random(in: 13..<17)
        speedCurrentLabel.text = (String(speedCurrent))
    }

    @objc func fireHeartBeatTimer(){
        let heartbeat = Int.random(in: 85..<91)
        //let heartRateInFloat = Float.random(in: 0..<1)
        hrLabel.text = String(heartbeat)
        
    }
    
    @objc func fireDistanceTimer(){
        //let heartRateInFloat = Float.random(in: 0..<1)
        counter += 0.1
        distanceLabel.text = String(format: "%.1f",counter)
    }
    
    @objc func fireFeedbackTimer(timer: Timer) {
/*        let weatherFeedback = AVSpeechUtterance(string: "Weather is minus five celsius and the snow is hard packed. Your waxing should work well.")
        weatherFeedback.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.stopSpeaking(at: .immediate)
        talker.speak(weatherFeedback)
        let styleFeedback = AVSpeechUtterance(string: "You've spend seventy four percent on freestyle wassberg, five percent on double poling, twenty one percent on gliding.")
        talker.speak(styleFeedback)
        let cheerishFeedback = AVSpeechUtterance(string: "You are going strong! Good work!")
        talker.speak(cheerishFeedback)
 */
    }
    
    
    func formatTimeInterval(timeInterval:TimeInterval) -> String {
        let secondsInHour = 3600
        let secondsInMinute = 60
        var time = Int(timeInterval)
        let hours = time / secondsInHour
        time = time % secondsInHour
        let minutes = time / secondsInMinute
        let seconds = time % secondsInMinute
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.session.isPaired == true && self.session.isWatchAppInstalled == true {
            //send a control message to Apple Watch to start training there as well!
            
            /*let siriFeedback = AVSpeechUtterance(string: "Message received to start training on watch")
            siriFeedback.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.stopSpeaking(at: .immediate)
            talker.speak(weatherFeedback)*/
            
            //limit messaging for video
            //if watchMessageSent == false {
                self.session.sendMessage(["msg":"ctrl_message_start_training_on_watch"], replyHandler: nil, errorHandler:nil)
                //watchMessageSent = true
            //}

        }

        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            
            self.locationSensor?.setLocationHandler({ (locations) in
                for location in locations{
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    let anotation = MKPointAnnotation()
                    anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    print(location)
                    //FIX ME location
                    self.mapView!.addAnnotation(anotation)
                }
            })
            self.locationSensor!.start()
            self.locationSensor?.locationManager.requestLocation()
            
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

