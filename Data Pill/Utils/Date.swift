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
    
    /// Format the Date to `dd mm yyyy` or `dd mm yy`
    /// e.g. 1 Jan 2022
    func toDayMonthYearFormat(isLongYear: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        let longYear = "yyyy"
        let shortYear = "yy"
        let year = isLongYear ? longYear : shortYear
        dateFormatter.dateFormat = "d MMM \(year)"
        return dateFormatter.string(from: self)
    }
   
    /// Formats the Date to `dd mm`
    /// e.g. 1 Jan
    func toDayMonthFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        return dateFormatter.string(from: self)
    }
    
    /// Formats the Date to `dd mm`
    /// e.g. 1 Jan  =  1
    func toDayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    /// Formats the Date to `E`
    /// e.g. 1 Jan  2022 =  Sat
    func toWeekdayFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
    
    func toDateComp() -> DateComponents {
        Calendar.current.dateComponents(
            [.day, .month, .year, .weekday],
            from: self
        )
    }
    
    /// Checks Date is Today's Date
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Counts the number of days between two Dates
    /// - Parameter end: A value to specify the last Date
    func toNumOfDays(to end: Date) -> Int {
        Calendar.current.daysBetween(start: self, end: end)
    }
    
    /// Creates a range from the specified Date to Any Date
    func fromDateRange() -> PartialRangeFrom<Date> {
        let startComponents = self.toDateComp()
        return Calendar.current.date(from: startComponents)!...
    }
    
    /// Creates a range from Any Date to specified Date
    func toDateRange() -> PartialRangeThrough<Date> {
        let endComponents = self.toDateComp()
        return ...Calendar.current.date(from: endComponents)!
    }
    
    /// Checks if Date is in range from the specified start Date and end Date
    /// - Parameters:
    ///    - from : The starting date of the range
    ///    - to : The ending date of the range
    func isDateInRange(from start: Date, to end: Date) -> Bool {
        let startDate = Calendar.current.startOfDay(for: start)
        let endDate = Calendar.current.startOfDay(for: end)
        if endDate < startDate {
            return false
        }
        let dateInterval = DateInterval(start: startDate, end: endDate)
        return dateInterval.contains(self)
    }
    
    /// Returns a new Date after adding number of days
    /// - Parameter value: The number of days to add
    func addDay(value: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: value, to: self)
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
        return numberOfDays.day! + 1
    }
    
}
