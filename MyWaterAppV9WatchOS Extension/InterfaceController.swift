//
//  InterfaceController.swift
//  MyWaterAppV9WatchOS Extension
//
//  Created by Charlie on 7/6/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity



class InterfaceController: WKInterfaceController{
    
    //Cache References
    let session = WCSession.default

    //IBOutlets
    @IBOutlet weak var waterLabel: WKInterfaceLabel!
    @IBOutlet weak var addButton: WKInterfaceButton!
    @IBOutlet weak var warningMessage: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        waterLabel.setHidden(true)
        addButton.setHidden(true)
        warningMessage.setHidden(false)
        

    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        session.delegate = self
        session.activate()
        super.willActivate()
        print("willActivate")
        if WCSession.isSupported() {
            AskToUpdate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("View did deactive")
    }

}

//MARK: - WCSessionDelegate
extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.AskToUpdate()
        print("AskToUpdate()")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message Recieved - Watch")
        DispatchQueue.main.async {
            if let textToDisplay = message["Label"] as? String {
                self.waterLabel.setText(textToDisplay)
                self.waterLabel.setHidden(false)
                self.addButton.setHidden(false)
                self.warningMessage.setHidden(true)
            }
            
        }
    }
}

//MARK: - Update Method
extension InterfaceController {
    func AskToUpdate() {
//        session.sendMessage(["Update": -1], replyHandler: nil, errorHandler: nil)
        session.sendMessage(["Update": -1], replyHandler: nil) { (error) in
            print("Unable to sendMessage")
            self.waterLabel.setHidden(true)
            self.addButton.setHidden(true)
            self.warningMessage.setHidden(false)
        }
    }
}
