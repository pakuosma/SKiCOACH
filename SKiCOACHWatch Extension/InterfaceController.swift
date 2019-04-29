//
//  InterfaceController.swift
//  SKiCOACHWatch Extension
//
//  Created by Markus Turtinen on 11.4.2019.
//  Copyright © 2019 Team Red. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation
import CoreMotion
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    let myInterval:TimeInterval = 6.0
    private var countdownSeconds = 5
    private var isStarted = false
    private var countdownTimer = Timer()
    private var hrTimer = Timer()
    private var feedbackTimer = Timer()
    private var timer = Timer()

    private var isRunning = true
    
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var elapsedLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    @IBOutlet weak var workoutTimer: WKInterfaceTimer!
    @IBOutlet weak var intervalTimer: WKInterfaceTimer!
    
    @IBOutlet weak var startStopButton: WKInterfaceButton!

    let session = WCSession.default
    let talker = AVSpeechSynthesizer()
    
    @IBAction func startStopAction() {
        isStarted = !isStarted //toggle the button
        if isStarted{
            statusLabel.setText("")
            startStopButton.setTitle("Stop")
            workoutTimer.setHidden(false)//true
            loopTimer(interval: myInterval)
            intervalTimer.setHidden(false)
            countdownSeconds = 5
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireCountdownTimer), userInfo: nil, repeats: true)
            self.session.sendMessage(["msg":"ctrl_message_start_training_on_iphone"], replyHandler: nil, errorHandler: nil)
        } else {
            startStopButton.setTitle("Start")
            workoutTimer.stop()
            intervalTimer.stop()
            timer.invalidate() //stop timer
        }
    }

     @objc func fireCountdownTimer(timer: Timer) {
        let utterance = AVSpeechUtterance(string: String(countdownSeconds))
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.stopSpeaking(at: .immediate)
        talker.speak(utterance)
        countdownSeconds -= 1
        if countdownSeconds <= 0 {
            let utterance = AVSpeechUtterance(string: "Let's go training!")
            talker.speak(utterance)
            countdownTimer.invalidate()
            intervalTimer.setHidden(true)
            workoutTimer.setHidden(false)
            countdownSeconds = 5
        }
     }

    @objc func fireHRTimer(timer: Timer) {
        let heartRate = Int.random(in: 85..<91)
        //let heartRateInFloat = Float.random(in: 0..<1)
        heartRateLabel.setText(String(heartRate))
    }

    @objc func fireFeedbackTimer(timer: Timer) {
        let weatherFeedback = AVSpeechUtterance(string: "Weather is minus five celsius and the snow is hard packed. Your waxing should work well.")
        weatherFeedback.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.stopSpeaking(at: .immediate)
        talker.speak(weatherFeedback)
        let styleFeedback = AVSpeechUtterance(string: "You've spend seventy four percent on freestyle wassberg, five percent on double poling, twenty one percent on gliding.")
        talker.speak(styleFeedback)
        let cheerishFeedback = AVSpeechUtterance(string: "You are going strong! Good work!")
        talker.speak(cheerishFeedback)
    }
    
    func loopTimer(interval:TimeInterval){ //NSTimer to end at event.
        if timer.isValid {
            timer.invalidate()
        }
        //timer = Timer.scheduledTimer(withTimeInterval: <#T##TimeInterval#>, repeats: <#T##Bool#>, block: <#T##(Timer) -> Void#>)
        timer = Timer.scheduledTimer(timeInterval: interval,
                                                       target: self,
                                                       selector: #selector(loopTimerDidEnd),
                                                       userInfo: nil,
                                                       repeats: false)
        wkTimerReset(timer: intervalTimer, interval: interval)
        wkTimerReset(timer: workoutTimer, interval: 0)
    }
    
    
    @objc func loopTimerDidEnd(timer:Timer){
        intervalTimer.stop()
        timer.invalidate()
    }

    
    func wkTimerReset(timer:WKInterfaceTimer,interval:TimeInterval){
        timer.stop()
        let time  = NSDate(timeIntervalSinceNow: interval)
        timer.setDate(time as Date)
        timer.start()
    }
    
    @IBAction func toPhoneTapped() {
        self.session.sendMessage(["msg":"A reply from Watch!"], replyHandler: nil, errorHandler: nil)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePhoneData), name: .receivedPhoneData, object: nil)
        
        // Configure interface objects here.
    }

    @objc func didReceivePhoneData(info:Notification){
        //Handle message received from iPhone
        let msg = info.userInfo!
        print(msg["msg"] as? String) //debug
        
        if (msg["msg"] as? String) == "ctrl_message_start_training_on_watch" {
            print("debug: ctrl_message_start_training_on_watch") //debug
            
            let utterance = AVSpeechUtterance(string: "Hi this is Siri on Apple Watch - starting the trainign on watch app as well!")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            talker.stopSpeaking(at: .immediate)
            talker.speak(utterance)
            
            //Receipt back to iPhone
            self.session.sendMessage(["msg":"ctrl_message_start_training_ack"], replyHandler: nil, errorHandler: nil)
            
            self.startStopAction() // call to start training on AppleWatch as well!
        }
        
    
        //self.messageLabel.setText(msg["msg"] as? String)
        self.statusLabel.setText(msg["msg"] as? String)
        
        //let utterance = AVSpeechUtterance(string: "Train harder!")
        let utterance = AVSpeechUtterance(string: msg["msg"] as! String)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.stopSpeaking(at: .immediate)
        talker.speak(utterance)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        hrTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fireHRTimer), userInfo: nil, repeats: true)
        
        feedbackTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(fireFeedbackTimer), userInfo: nil, repeats: false)
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        hrTimer.invalidate()
        feedbackTimer.invalidate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //code
    }
}
