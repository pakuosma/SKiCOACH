//
//  InterfaceController.swift
//  SKiCOACHWatch Extension
//
//  Created by Markus Turtinen on 11.4.2019.
//  Copyright © 2019 Team Red. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    let session = WCSession.default
    
    @IBAction func toPhoneTapped() {
        self.session.sendMessage(["msg":"A reply from Watch!"], replyHandler: nil, errorHandler: nil)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePhoneData), name: .receivedPhoneData, object: nil)
        
        // Configure interface objects here.
    }

    @objc func didReceivePhoneData(info:Notification){
        let msg = info.userInfo!
        self.messageLabel.setText(msg["msg"] as? String)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //code
    }
}
