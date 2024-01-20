//
//  DayPill.swift
//  Data Pill
//
//  Created by Wind Versi on 28/11/22.
//

import Foundation

enum Day: String, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

extension Day {
    
    var shortName: String {
        switch self {
        case .sunday:
            "Sun"
        case .monday:
            "Mon"
        case .tuesday:
            "Tue"
        case .wednesday:
            "Wed"
        case .thursday:
            "Thu"
        case .friday:
            "Fri"
        case .saturday:
            "Sat"
        }
    }
}

struct DayPill: Identifiable {
    let color: Colors
    let day: Day
    var id: String { self.day.rawValue }
}
