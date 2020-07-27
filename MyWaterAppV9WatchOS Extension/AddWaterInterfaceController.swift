//
//  AddWaterInterfaceController.swift
//  MyWaterAppV9WatchOS Extension
//
//  Created by Charlie on 7/8/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity

//protocol AddWaterInterfaceDelegate {
//    func sendValue(value: Int16)
//}

class AddWaterInterfaceController: WKInterfaceController {
    
    //Cache References
    let session = WCSession.default
    //var delegate: AddWaterInterfaceDelegate?
    
    //IBOutlet
    @IBOutlet weak var currentDisplayValueLabel: WKInterfaceLabel!
    
    //Value Variable
    var currentValue = "0"
    
    override func awake(withContext context: Any?) {
        currentDisplayValueLabel.setText("\(currentValue)mL")
        
    }
    
    override func willActivate() {
        super.willActivate()
        session.delegate = self
        session.activate()
    }
    
    override func willDisappear() {
        //currentValue = "0"
        print("willDisappear AddWaterInterface")
        ClearValue()
    }
    
    //IBActions
    @IBAction func clearButton() {
        ClearValue()
    }
    @IBAction func _1Button() {
        AppendValue(value: 1)
    }
    @IBAction func _2Button() {
        AppendValue(value: 2)
    }
    @IBAction func _3Button() {
        AppendValue(value: 3)
    }
    @IBAction func _4Button() {
        AppendValue(value: 4)
    }
    @IBAction func _5Button() {
        AppendValue(value: 5)
    }
    @IBAction func _6Button() {
        AppendValue(value: 6)
    }
    @IBAction func _7Button() {
        AppendValue(value: 7)
    }
    @IBAction func _8Button() {
        AppendValue(value: 8)
    }
    @IBAction func _9Button() {
        AppendValue(value: 9)
    }
    @IBAction func _0Button() {
        if currentValue != "0" {
            AppendValue(value: 0)
        }
    }
    @IBAction func AddWaterButton() {
        //delegate?.sendValue(value: Int16(currentValue) ?? 0)
        session.sendMessage(["Update": Int16(currentValue) ?? 0], replyHandler: nil, errorHandler: nil)
        dismiss()
    }
}

//Button Methods
extension AddWaterInterfaceController {
    func AppendValue(value: Int) {
        //let newValue = "\(value)"
        if currentValue == "0" {
            currentDisplayValueLabel.setText("\(value)mL")
            currentValue = String(value)
        } else {
            let newValue = "\(currentValue)\(value)"
            currentDisplayValueLabel.setText("\(newValue)mL")
            currentValue = newValue
        }
    }
    
    func ClearValue() {
        currentValue = "0"
        currentDisplayValueLabel.setText("\(currentValue)mL")
    }
}

//MARK: - WCSessionDelegate
extension AddWaterInterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session Connected - AddWaterView")
    }
}
