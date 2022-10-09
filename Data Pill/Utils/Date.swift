//
//  Date.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation

extension String {
    
    /// Converts ISO String Date to Date
    public func toDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self) ?? Date()
    }
    
}

extension Date {
    
    /// Format the Date to `dd mm yyyy`
    /// e.g. 1 Jan 2022
    public func toDayMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter.string(from: self)
    }
   
    /// Formats the Date to `dd mm`
    /// e.g. 1 Jan
    public func toDayMonthFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        return dateFormatter.string(from: self)
    }
    
    /// Formats the Date to `dd mm`
    /// e.g. 1 Jan  =  1
    public func toDayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    func toDateComp() -> DateComponents {
        Calendar.current.dateComponents(
            [.day, .month, .year, .weekday],
            from: self
        )
    }
    
    /// Checks Date is Today's Date
    public func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Counts the number of days between two Dates
    /// - Parameter end: A value to specify the last Date
    public func toNumOfDays(to end: Date) -> Int {
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
