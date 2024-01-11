//
//  Date.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import SwiftUI

extension Locale {
    
    static let simplifiedChinese = Locale(identifier: "zh-Hans")
    static let filipino = Locale(identifier: "fil")
    static let english = Locale(identifier: "en")
    static let german = Locale(identifier: "de")

}

extension String {
    
    /// Converts ISO String Date to Date
    func toDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self) ?? Date()
    }
    
}

extension Date {
    
    /// Formats the Date to `dd mm`
    /// e.g. 1 Jan
    func toDayMonthFormat(locale identifier: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: identifier)
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
    
    /// Returns the Year from Date `E`
    /// e.g. 1 Jan  2022 =  2022
    /// - parameter isLongYear: A value to indicate if it will use 4-digit year
    func toYearFormat(locale identifier: String, isLongYear: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: identifier)
        let longYear = "yyyy"
        let shortYear = "yy"
        let year = isLongYear ? longYear : shortYear
        dateFormatter.dateFormat = "\(year)"
        return dateFormatter.string(from: self)
    }
        
    /// Returns the weekday index from 1 - 7 : Sun - Sat
    /// e.g. 1 Jan 2022, Sat = 7
    func getWeekday() -> Int {
        self.toDateComp().weekday!
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
    
    /// Counts the number of days between two Dates
    /// - Parameter end: A value to specify the last Date
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
        return numberOfDays.day! + 1
    }
    
}
