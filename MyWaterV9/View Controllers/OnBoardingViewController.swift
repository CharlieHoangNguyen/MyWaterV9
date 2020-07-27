//
//  OnBoardingViewController.swift
//  MyWaterV9
//
//  Created by Charlie on 7/5/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import Foundation
import UIKit
import BAFluidView
import AVFoundation

class OnBoardingViewController: UIViewController {
    
    //Cache References
    let dataController = DataController.instance
    
    //SFX
    let waterButtonSFX = URL(fileURLWithPath: Bundle.main.path(forResource: "waterButtonSFX", ofType: ".aifc")!)
    let waterFillSFX = URL(fileURLWithPath: Bundle.main.path(forResource: "waterFillSFX", ofType: ".flac")!)
    var audioPlayer = AVAudioPlayer()
    
    //IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var warningMessage: UILabel!
    @IBOutlet weak var backgroundWater: BAFluidView!
    
    //LifeCycles - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        InitializeNumberPadSettings()
        warningMessage.isHidden = true
        backgroundWater.fillColor = UIColor(named: "Water Color") ?? .blue
        backgroundWater.strokeColor = UIColor(named: "Water Color") ?? .blue
        backgroundWater.fillDuration = 5
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backgroundWater.fillColor = UIColor(named: "Water Color") ?? .blue
    }
    
    //IBActions
    @IBAction func ContinueButtonPressed(_ sender: UIButton) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: waterButtonSFX)
            audioPlayer.play()
        } catch {
            print("ERROR: Unable to play SFX - \(error.localizedDescription)")
        }
        
        if let name = nameTextField.text, let weightText = weightTextField.text, let weight = Int16(weightText) {
            dataController.saveUserData(userName: name, userWeight: weight, currentWater: 0, totalWater: 0, today: Date().GetTodaysDate())
            

            
            dataController.userWeight = weight
            dataController.SetDefaultGoal()
            
            self.view.insertSubview(backgroundWater, aboveSubview: warningMessage)
            backgroundWater.fill(to: 1)
            
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
            
            var count = 0.0
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                if count < 5 {
                    count += 1
                } else {
                    self.LoadMainView()
                    timer.invalidate()
                    self.audioPlayer.stop()
                }
            }
        } else {
            warningMessage.isHidden = false
        }
    }
    
    //Load Main View
    private func LoadMainView() {
        performSegue(withIdentifier: "ToMainview", sender: self)
    }
}

//MARK: - UITextFieldDelegate
extension OnBoardingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}

//MARK: - NumberPad Settings
extension OnBoardingViewController {
    private func InitializeNumberPadSettings() {
        let doneToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolBar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(weightShouldReturn))
        
        let items = [flexSpace, doneButton]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        
        weightTextField.inputAccessoryView = doneToolBar
    }
    
    @objc private func weightShouldReturn() {
        weightTextField.resignFirstResponder()
    }
}
