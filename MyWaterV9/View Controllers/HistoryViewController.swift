//
//  HistoryViewController.swift
//  MyWaterV9
//
//  Created by Charlie on 7/5/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import UIKit
import Charts

class HistoryViewController: UIViewController {

    //Cache Reference
    let dataController = DataController.instance
    
    //IBOutlets
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var homeTabBar: UIView!
    @IBOutlet weak var dateToShowLabel: UILabel!
    @IBOutlet weak var valueToShowLabel: UILabel!
    
    //Bar Chart Data
    var dateAsString = Array<String>(repeating: "", count: 30)
    
    //LifeCycles - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        barChartView.delegate = self
        
        homeTabBar.layer.cornerRadius = 5
        
        LoadBarChart()
        UpdateValuesToShow(date: "", value: 0)
    }

    //IBActions
    @IBAction func _3DaysButtonPressed(_ sender: UIButton) { //2 5 7 10
        UpdateValues(range: 2, daysText: "2 Days")
    }
    
    @IBAction func _7DaysButtonPressed(_ sender: UIButton) {
        UpdateValues(range: 5, daysText: "5 Days")
    }
    
    @IBAction func _2WeeksButtonPressed(_ sender: UIButton) {
        UpdateValues(range: 7, daysText: "7 Days")
    }
    
    @IBAction func _1MonthPressed(_ sender: UIButton) {
        UpdateValues(range: 10, daysText: "10 Days")
    }
}

//MARK: - Load BarChartView
extension HistoryViewController {
    func UpdateValuesToShow(date: String, value: Int) {
        dateToShowLabel.text = date
        if date == "" {
            valueToShowLabel.text = ""
        } else {
            valueToShowLabel.text = "\(value)mL"
        }
    }
    
    func UpdateValues(range: Int, daysText: String) {
        UpdateValuesToShow(date: "", value: 0)
        barChartView.clear()
        dateAsString = Array<String>(repeating: "", count: 30)
        if let barData = GetBarData(maxRange: range) {
            print("BarDataCount: \(barData.count)")
            barChartView.data = SetData(dataEntry: barData)
            print(barData)
        } else {
            barChartView.clear()
        }
        
        daysLabel.text = daysText
        print(dateAsString)
    }
    
    private func LoadBarChart() {
        barChartView.LoadSettings()
        barChartView.leftAxis.axisMaximum = Double(dataController.totalWater!)
        UpdateValues(range: 2, daysText: "2 Days")
    }
    
    private func SetData(dataEntry: [BarChartDataEntry]) -> BarChartData {
        let dataSet = BarChartDataSet(entries: dataEntry, label:
            "Water")
        dataSet.label = "mL of Water"
        dataSet.drawValuesEnabled = false
        //dataSet.valueTextColor = UIColor(named: "Text Color")!
        dataSet.setColors(UIColor(named: "Text Color")!)
        
        let data = BarChartData(dataSet: dataSet)
        return data
    }
}

//MARK: - Data Controller Methods
extension HistoryViewController {
    func GetBarData(maxRange: Int) -> [BarChartDataEntry]? {
        var waterData = dataController.fetchWaterData()
        waterData = waterData?.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending })

        var barData = [BarChartDataEntry]()
        if waterData!.count != 0 {
            print("Water Count: \(waterData!.count)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM, d YYYY"
            
            for index in 0..<maxRange {
                var newData: BarChartDataEntry?
                if index < waterData!.count {
                    let dateAsString = dateFormatter.string(from: waterData![index].date!)
                    self.dateAsString[maxRange - 1 - index] = dateAsString
                    newData = BarChartDataEntry(x: Double(maxRange - 1 - index), y: Double(waterData![index].intake))
                } else {
                    newData = BarChartDataEntry(x: Double(maxRange - waterData!.count - index + 1), y: Double(0))
                }
                barData.append(newData!)
            }
            barData.reverse()
            print(barData)
            return barData

        } else {
            return nil
        }
    }
}

//MARK: - ChartViewDelegate
extension HistoryViewController: ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        UpdateValuesToShow(date: dateAsString[Int(entry.x)], value: Int(entry.y))
        print("Index : \(entry.x)")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        UpdateValuesToShow(date: "", value: 0)
        print("Nothing Selected")
    }

}
