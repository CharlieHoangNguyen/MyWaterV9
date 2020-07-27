//
//  DateExtension.swift
//  MyWaterV9
//
//  Created by Charlie on 7/5/20.
//  Copyright © 2020 Charlie Nguyen. All rights reserved.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func GetTodaysDate() -> Date {
        let today = Date()
        let components = today.get(.day, .month, .year)
        let date = Calendar.current.date(from: components)
        print(date as Any)
        return date!
    }
}
