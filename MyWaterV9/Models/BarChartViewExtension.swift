//
//  BarChartViewExtension.swift
//  MyWaterV9
//
//  Created by Charlie on 7/5/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import Charts

extension BarChartView {
    func LoadSettings() {
        backgroundColor = .clear
        rightAxis.enabled = false
        xAxis.enabled = false
        
        //xAxis.avoidFirstLastClippingEnabled = true
        drawGridBackgroundEnabled = false
        
        leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        leftAxis.labelTextColor = UIColor(named: "Text Color")!
        leftAxis.axisLineColor = .clear
        leftAxis.labelPosition = .outsideChart
        leftAxis.axisMinimum = 0.0
        
        pinchZoomEnabled = false
        doubleTapToZoomEnabled = false
        
        //animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        noDataTextColor = UIColor(named: "Text Color") ?? .red
        noDataText = "No Data to show. Drink more Water!"
    }
}
