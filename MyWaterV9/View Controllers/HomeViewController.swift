//
//  ViewController.swift
//  MyWaterV9
//
//  Created by Charlie on 7/4/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import UIKit
import BAFluidView
import WatchConnectivity
import HealthKit
import AVFoundation
//import CoreMotion

class HomeViewController: UIViewController {

    //Cache References
    let dataController = DataController.instance
    //let motionManager = CMMotionManager()
    let healthKitAssistant = HKHealthStore()
    var watchSession: WCSession?
    
    //SFX
    let waterButtonSFX = URL(fileURLWithPath: Bundle.main.path(forResource: "waterButtonSFX", ofType: ".aifc")!)
    let waterFillSFX = URL(fileURLWithPath: Bundle.main.path(forResource: "waterFillSFX", ofType: ".flac")!)
    var audioPlayer = AVAudioPlayer()
    
    //NSNotification Variables
    let notifCenter = NotificationCenter.default
    let notifName = NSNotification.Name(rawValue: "Values Changed")
    
    //var backgroundWater = BAFluidView()
    var backgroundWater: BAFluidView?
    
    //IBOutlets
    @IBOutlet weak var currentWaterLabel: UILabel!
    @IBOutlet weak var totalWaterLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    //LifeCycles - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        WatchDelegateSetup()
        AuthorizeNotifications()
        AuthorizeHealthKit()
        
        CheckDate()
        //StartDeviceMotion()
        LoadBackgroundWater()
        LoadWaterText()
        
        notifCenter.addObserver(self, selector: #selector(UpdateValues), name: notifName, object: nil)
        backgroundWater?.fill(to: dataController.currentPercentage ?? 0.0)
       
        nameLabel.text = "Hello, \(dataController.userName ?? "")"
        
        audioPlayer.enableRate = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        backgroundWater?.startAnimation()
//        backgroundWater?.startTiltAnimation()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backgroundWater?.fillColor = UIColor(named: "Water Color") ?? .clear
    }
    
    //IBActions
    @IBAction func AddWater(_ sender: UIButton) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: waterButtonSFX)
            audioPlayer.play()
        } catch {
            print("ERROR: Unable to play SFX - \(error.localizedDescription)")
        }

        UpdateWater()
    }
}

//MARK: - Update Water
extension HomeViewController {
    @objc private func UpdateWater() {
        //Alert Controller
        let alertController = UIAlertController(title: "How much water did you drink?", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        //Alert Action Definition
        let alertAction = UIAlertAction(title: "Enter", style: .default) { (action) in
            if let waterAmount = Int16(textField.text!) {
                var oldWaterAmount = self.dataController.currentWater!
                let newWaterAmount = oldWaterAmount + waterAmount
                self.dataController.currentWater = newWaterAmount
                
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: self.waterFillSFX)
                    self.audioPlayer.enableRate = true
                    self.audioPlayer.numberOfLoops = -1
                    self.audioPlayer.rate = 2
                    self.audioPlayer.volume = 0.25
                    self.audioPlayer.play()
                    
                    
                } catch {
                    print("ERROR: Unable to play waterFillSFX - \(error.localizedDescription)")
                }
                
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
                    if oldWaterAmount < newWaterAmount {
                        oldWaterAmount += 1
                        self.currentWaterLabel.text = "\(oldWaterAmount)mL"
                        let percentage = Double(oldWaterAmount) / Double(self.dataController.totalWater!)
                        
                        self.backgroundWater?.fill(to: NSNumber(value: percentage))
                        
                        
                    } else {
                        timer.invalidate()
                        self.audioPlayer.stop()
                    }
                }
                
                self.SendMessageToWatch()
                self.dataController.saveWaterData(water: newWaterAmount, date: Date().GetTodaysDate())

                
                self.SendWaterToHealthKit(amount: waterAmount)
            }
        }
        
        //Update Alert Controller
        alertController.addTextField { (alertTextField) in
            alertTextField.keyboardType = .numberPad
            alertTextField.placeholder = "mL"
            textField = alertTextField
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

//MARK: - Text Update
extension HomeViewController {
    private func LoadWaterText() {
        DispatchQueue.main.async {
            self.currentWaterLabel.text = "\(self.dataController.currentWater ?? 0)mL"
            self.totalWaterLabel.text = "\(self.dataController.totalWater ?? 0)mL"
        }

    }
}

//MARK: - Background Water
extension HomeViewController {
    private func LoadBackgroundWater() {
        backgroundWater = BAFluidView(frame: self.view.frame, maxAmplitude: 10, minAmplitude: 1, amplitudeIncrement: 2, startElevation: 0.0 )
        backgroundWater?.fillDuration = 1
        backgroundWater?.lineWidth = 0
        backgroundWater?.strokeColor = UIColor(named: "Water Color") ?? .clear
        backgroundWater?.fillColor = UIColor(named: "Water Color") ?? .clear
        backgroundWater?.fillRepeatCount = 0
        backgroundWater?.fillAutoReverse = true
        
        
        backgroundWater?.keepStationary()
        backgroundWater?.startAnimation()
        //backgroundWater?.startTiltAnimation()
        
        self.view.insertSubview(backgroundWater!, at: 0)
    }
}

//MARK: - NSNotification Method
extension HomeViewController {
    @objc private func UpdateValues() {
        self.backgroundWater?.fill(to: self.dataController.currentPercentage ?? 0.0)
        LoadWaterText()
        nameLabel.text = "Hello, \(dataController.userName ?? "")"
        self.SendMessageToWatch()
    }
}

//MARK: - Date Checker
extension HomeViewController {
    private func CheckDate() {
        if let lastDate = dataController.lastAccessedDate {
            if lastDate != Date().GetTodaysDate() {
                var dayToAdd = DateComponents()
                dayToAdd.day = 1
                
                var modifiedDate = lastDate
                while modifiedDate != Date().GetTodaysDate() {
                    modifiedDate = Calendar.current.date(byAdding: dayToAdd, to: modifiedDate, wrappingComponents: false)!
                    dataController.saveWaterData(water: 0, date: modifiedDate)
                }
                dataController.currentWater = 0
                dataController.lastAccessedDate = Date().GetTodaysDate()
            }
        }
    }
}

//MARK: - WCSessionDelegate
extension HomeViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch Session is Connected")
        self.SendMessageToWatch()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
        session.sendMessage(["Label": "-1"], replyHandler: nil, errorHandler: nil)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
        session.sendMessage(["Label": "-1"], replyHandler: nil, errorHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message Recieved")
        DispatchQueue.main.async {
            print(message)
            let value = message["Update"] as! Int16
            
            if value != -1 {
                var oldWaterAmount = self.dataController.currentWater!
                let newWaterAmount = oldWaterAmount + value
                self.dataController.currentWater = newWaterAmount
                self.dataController.saveWaterData(water: newWaterAmount, date: Date().GetTodaysDate())

                //self.SendMessageToWatch()
                
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
                    if oldWaterAmount < newWaterAmount {
                        oldWaterAmount += 1
                        self.currentWaterLabel.text = "\(oldWaterAmount)mL"
                    } else {
                        timer.invalidate()
                    }
                }
            } else {
                self.SendMessageToWatch()
            }
        }
    }
        
}

//MARK: - Watch Methods
extension HomeViewController {
    func SendMessageToWatch() {
        DispatchQueue.main.async {
            if let validSession = self.watchSession, self.watchSession!.isReachable {
                let data = ["Label": "\(self.dataController.currentWater ?? 0)mL / \(self.dataController.totalWater ?? 0)mL" ]
                validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    func WatchDelegateSetup() {
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession?.delegate = self
            watchSession?.activate()
            print("Watch Delegate Setup Complete - HomeView")
         }
    }
}

//MARK: - Local User Notifications
extension HomeViewController {
    func AuthorizeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if success {
                print("All set!")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - HealthKit
extension HomeViewController {
    func AuthorizeHealthKit() {
        let water = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        
        let sharing: Set<HKSampleType> = [water]
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("Error: Unable to connect to Health Kit")
            return
        }
        
        healthKitAssistant.requestAuthorization(toShare: sharing, read: nil) { (success, error) in
            print("Sucess: Writing to Health Kit")
        }
    }
    
    func SendWaterToHealthKit(amount: Int16) {
        guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Water Same Type Not Available")
            return
        }
        
        let waterQuantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(amount))
        let today = Date()
        let waterQuantitySample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: today, end: today)
        
        healthKitAssistant.save(waterQuantitySample) { (success, error) in
            print("Saving Data to HealthKit Store...")
            if success {
                print("Success: \(success)")
            }

            if let error = error {
                print("Error: Unable to save Water Data to Health Kit\(error)")
            }
        }
    }
}

//MARK: - Core Motion
//extension HomeViewController {
//    private func StartDeviceMotion() {
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 0.2
//            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
//                let notifCenter = NotificationCenter.default
//                var userInfo: [String: CMDeviceMotion?]? = nil
//                if let data = data {
//                    userInfo = ["data": data]
//                }
//                notifCenter.post(name: NSNotification.Name(rawValue: kBAFluidViewCMMotionUpdate), object: self, userInfo: userInfo! as [AnyHashable : Any])
//                print(data!)
//            }
//
//        }
//    }
//}
