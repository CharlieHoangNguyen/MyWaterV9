//
//  SettingsViewController.swift
//  
//
//  Created by Charlie on 7/5/20.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController {

    //Cache References
    let dataController = DataController.instance
    private var timePicker: UIDatePicker?
    
    //NSNotification Center
    let notifCenter = NotificationCenter.default
    let notifName = NSNotification.Name(rawValue: "Values Changed")
    
    //IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var homeTabBar: UIView!
    @IBOutlet weak var reminderTimeTextField: UITextField!
    
    //LifeCycles - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        homeTabBar.layer.cornerRadius = 5
        notifCenter.addObserver(self, selector: #selector(UpdateValues), name: notifName, object: nil)
        InitializeNumberPadSettings()
        InitiailizeTimePickerSettings()

        UpdateValues()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(gestureReconizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func viewDidTap(gestureReconizer: UITapGestureRecognizer) {
        dataController.userName = nameTextField.text
        //weightShouldReturn()
        view.endEditing(true)
    }
    
    @IBAction func DefaultGoatButtonPressed(_ sender: UIButton) {
        dataController.SetDefaultGoal()
    }
    
    @IBAction func CustomGoalButtonPressed(_ sender: UIButton) {
        //Alert Controller
        let alertController = UIAlertController(title: "What's your goal?", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let alertAction = UIAlertAction(title: "Enter", style: .default) { (action) in
            if let newGoal = Int16(textField.text!) {
                self.dataController.SetCustomGoal(goal: newGoal)
            }
        }
        
        //Update Alert Controller
        alertController.addTextField { (alertTextField) in
            alertTextField.keyboardType = .numberPad
            alertTextField.placeholder = "\(self.dataController.totalWater ?? 0)mL"
            textField = alertTextField
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

//NSNotification Center Methods
extension SettingsViewController {
    @objc private func UpdateValues() {
        nameTextField.text = dataController.userName
        weightTextField.text = String(dataController.userWeight!)
        dailyGoalLabel.text = "Daily Goal: \(dataController.totalWater ?? 0)mL"
        
        if let reminderTime = UserDefaults.standard.object(forKey: "Reminder Time") as? Date {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            
            reminderTimeTextField.text = timeFormatter.string(from: reminderTime)
        } else {
            reminderTimeTextField.text = "9:00 AM"
            timePickerShouldReturn()
        }
    }
}

//MARK: - Numberpad/Date Picker Settings Settings
extension SettingsViewController {
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
        if let weightText = weightTextField.text, let weight = Int16(weightText) {
            dataController.userWeight = weight
            dataController.SetDefaultGoal()
        } else {
            weightTextField.text = String(dataController.userWeight!)
            //dataController.SetDefaultGoal()
        }
        weightTextField.resignFirstResponder()
    }
    
    private func InitiailizeTimePickerSettings() {
        let doneToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolBar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(timePickerShouldReturn))
        
        let items = [flexSpace, doneButton]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        timePicker?.addTarget(self, action: #selector(UpdateReminderTime), for: .valueChanged)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissTimePicker))
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
        reminderTimeTextField.inputView = timePicker
        reminderTimeTextField.inputAccessoryView = doneToolBar
    }
    
    @objc private func timePickerShouldReturn() {
        
        if let timeToRemind = reminderTimeTextField.text {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            
            let content = UNMutableNotificationContent()
            content.title = "Stay Hydrated"
            content.body = "\(dataController.userName ?? ""), Remember to drink lots of water today!"
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzBuzz"]
            content.sound = .default
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let time = timeFormatter.date(from: timeToRemind)
            UserDefaults.standard.set(time, forKey: "Reminder Time")

            var timeComponents = DateComponents()
            timeComponents.hour = NSCalendar.current.component(.hour, from: time!)
            timeComponents.minute = NSCalendar.current.component(.minute, from: time!)
            print(timeComponents)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request, withCompletionHandler: nil)
        }
        
        reminderTimeTextField.resignFirstResponder()
    }
    
    @objc private func DismissTimePicker() {
        view.endEditing(true)
    }
    
    @objc private func UpdateReminderTime(timePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        reminderTimeTextField.text = timeFormatter.string(from: timePicker.date)
    }
}

//MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = nameTextField.text {
            dataController.userName = name
        }
        textField.resignFirstResponder()
        return true
    }
}
