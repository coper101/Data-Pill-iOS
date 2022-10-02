//
//  DataManipulation.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation

func dayPillIndex(_ data: Data) -> Int {
    guard let date = data.date else {
        return 1
    }
    let weekday =  date.toDateComp().weekday ?? 1
    return weekday - 1
}

func totalUsedData(
    _ data: [Data],
    from start: Date,
    to end: Date
) -> Double {
    guard
        let firstDay = data.first(where: { $0.date == start }),
        let lastDay = data.first(where: { $0.date == end }),
        let firstDayDate = firstDay.date,
        let lastDayDate = lastDay.date
    else {
        return 0
    }
    let period = firstDayDate...lastDayDate
    return data
        .filter {
            guard let date = $0.date else {
                return false
            }
            return period.contains(date)
        }
        .reduce(0) { $0 + $1.dailyUsedData }
}
