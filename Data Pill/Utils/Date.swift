//
//  Date.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation

extension String {
    
    /// Converts ISO String Date to Date
    func toDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self) ?? Date()
    }
    
}

extension Date {
    
    func toDayMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter.string(from: self)
    }
  
    func toDayMonthFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        return dateFormatter.string(from: self)
    }
    
    func toDayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    func toWeekdayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func toDateComp() -> DateComponents {
        Calendar.current.dateComponents(
            [.day, .month, .year, .weekday],
            from: self
        )
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func toNumOfDays(to end: Date) -> Int {
        Calendar.current.daysBetween(start: self, end: end)
    }
}

extension Calendar {
    
    func daysBetween(start: Date, end: Date) -> Int {
        let from = startOfDay(for: start)
        let to = startOfDay(for: end)
        let numberOfDays = dateComponents(
            [.day],
            from: from,
            to: to
        )
        return numberOfDays.day!
    }
    
}
