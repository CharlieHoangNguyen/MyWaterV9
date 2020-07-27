//
//  DataController.swift
//  MyWaterV9
//
//  Created by Charlie on 7/5/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class DataController {
    
    //Static Instance
    static let instance = DataController()
    
    //Container Context
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //NSNotification Center
    let notifCenter = NotificationCenter.default
    let notifName = NSNotification.Name(rawValue: "Values Changed")
    
    //String Variables
    let userAccDataEntityString = "UserAccountData"
    let waterDataEntityString = "WaterIntakeData"
    
    //MARK: - Water Variables
    var currentWater: Int16? {
        set {
            saveUserData(userName: userName!, userWeight: userWeight!, currentWater: newValue!, totalWater: totalWater!, today: lastAccessedDate!)
            //PostNotification()
        }
        get { return fetchUserData()?.currentWater }
    }

    var totalWater: Int16? {
        set {
            saveUserData(userName: userName!, userWeight: userWeight!, currentWater: currentWater!, totalWater: newValue!, today: lastAccessedDate!)
            PostNotification()
        }
        get { return fetchUserData()?.totalWater }
    }

    var currentPercentage: NSNumber? {
        get {
            if let total = totalWater {
                if let current = currentWater {
                    return NSNumber(value: Double(current) / Double(total))
                }
            }
            return 0.0
        }
    }
    
    //MARK: - User Data Variables
    var userName: String? {
        set {
            saveUserData(userName: newValue!, userWeight: userWeight!, currentWater: currentWater!, totalWater: totalWater!, today: lastAccessedDate!)
            PostNotification()
        }
        get { return fetchUserData()?.name }
    }

    var userWeight: Int16? {
        set {
            //totalWater = Int16(Double(newValue!) * 5/8 * 29.57)
            saveUserData(userName: userName!, userWeight: newValue!, currentWater: currentWater!, totalWater: totalWater!, today: lastAccessedDate!)
            PostNotification()
        }
        get { return fetchUserData()?.weight }
    }
    
    var lastAccessedDate: Date? {
        set {
            saveUserData(userName: userName!, userWeight: userWeight!, currentWater: currentWater!, totalWater: totalWater!, today: newValue!)
        }
        get { return fetchUserData()?.lastDate }
    }
}

//MARK: - Custom/Default Goal Methods
extension DataController {
    func SetDefaultGoal() {
        totalWater = Int16(Double(userWeight!) * 5/8 * 29.57)
    }
    
    func SetCustomGoal(goal: Int16) {
        totalWater = goal
    }
}


//MARK: - User Data
extension DataController {
    func saveUserData(userName: String, userWeight: Int16, currentWater: Int16, totalWater: Int16, today: Date) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userAccDataEntityString)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
            //print("SUCCESS: Deleted instances of UserAccountData")
        } catch {
            print("ERROR: Unable to Delete instances of UserAccountData - \(error.localizedDescription)")
        }
        
        let data = UserAccountData(context: managedContext)
        data.totalWater = totalWater
        data.name = userName
        data.weight = userWeight
        data.currentWater = currentWater
        data.lastDate = today

        do {
            try managedContext.save()
        } catch {
            print("ERROR: Unable to save User Data - \(error.localizedDescription)")
        }
    }
    
    func fetchUserData() -> UserAccountData? {
        //var data: UserAccountData?
        var fetchResults = [UserAccountData]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: userAccDataEntityString)
        do {
            fetchResults = try managedContext.fetch(fetchRequest) as! [UserAccountData]
            //print("SUCESS: Able to Fetch User Data")
        } catch {
            print("ERROR: Unable to Fetch User Data - \(error.localizedDescription)")
        }
        
        if !fetchResults.isEmpty {
            return fetchResults[0]
            //return data
        }
        return nil
    }
}

//MARK: - Water Data
extension DataController {
    func saveWaterData(water: Int16, date: Date) {
        var dataExist = false
        if let waterDateArray = fetchWaterData() {
            for data in waterDateArray {
                if data.date == date {
                    data.intake = water
                    dataExist = true
                }
            }
        } else {
            let newWaterData = WaterIntakeData(context: managedContext)
            newWaterData.date = date
            newWaterData.intake = water
        }
        
        if !dataExist  {
            let newWaterData = WaterIntakeData(context: managedContext)
            newWaterData.date = date
            newWaterData.intake = water
        }
        
        do {
            try managedContext.save()
        } catch {
            print("ERROR: Unable to add Water Data - \(error.localizedDescription)")
        }
    }
    
    func fetchWaterData() -> [WaterIntakeData]? {
        var fetchResults = [WaterIntakeData]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: waterDataEntityString)
        
        do {
            fetchResults = try managedContext.fetch(fetchRequest) as! [WaterIntakeData]
        } catch {
            print("ERROR: Unable to fetch Water Data - \(error.localizedDescription)")
        }
        
        return fetchResults
    }
    
}

//MARK: - NSNotification Function
extension DataController {
    func PostNotification() {
        notifCenter.post(name: notifName, object: nil)
    }
}


