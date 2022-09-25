//
//  Data.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import Foundation

struct Data: Identifiable {
    let date: Date
    var dataUsed: Double = 0.13 /// in GB
    var id: String {
        date.toDayMonthYearFormat()
    }
    
    var debugDescription: String {
        """
            \n
            \(date.toWeekdayFormat())
            \(date.toDayMonthYearFormat())
            \n
            """
    }
}

/// get the previous days of the week including today
func weekData(_ data: [Data]) -> [Data] {
    guard
        let today = data.last,
        let weekday = today.date.toDateComp().weekday
    else {
        return .init()
    }
    return data.suffix(weekday)
}

func dayPillIndex(_ data: Data) -> Int {
    let weekday =  data.date.toDateComp().weekday ?? 1
    return weekday - 1
}
