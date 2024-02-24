//
//  Numbers.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import Foundation
import SwiftUI

extension Int {
    
    /// Appends the word Day or Days
    func prefixDay() -> String {
        let s = (self > 1) ? "s" : ""
        return "\(self) Day\(s)"
    }
    
    /// Returns a localized type weekday name of the weekday index
    /// e.g. 1 = Sun
    func toLocalizedShortWeekdayName() -> LocalizedStringKey {
        let weekday = self
        if weekday == 1 {
            return "Sun"
        }
        else if weekday == 2 {
            return "Mon"
        }
        else if weekday == 3 {
            return "Tue"
        }
        else if weekday == 4 {
            return "Wed"
        }
        else if weekday == 5 {
            return "Thu"
        }
        else if weekday == 6 {
            return "Fri"
        } else {
            return "Sat"
        }
    }
    
    /// Returns a non-localized type weekday name of the weekday index
    /// e.g. 1 = Sun
    func toShortWeekdayName() -> String {
        let weekday = self
        if weekday == 1 {
            return "Sun"
        }
        else if weekday == 2 {
            return "Mon"
        }
        else if weekday == 3 {
            return "Tue"
        }
        else if weekday == 4 {
            return "Wed"
        }
        else if weekday == 5 {
            return "Thu"
        }
        else if weekday == 6 {
            return "Fri"
        } else {
            return "Sat"
        }
    }
    
    func toDay() -> Day {
        let weekday = self
        if weekday == 1 {
            return .sunday
        }
        else if weekday == 2 {
            return .monday
        }
        else if weekday == 3 {
            return .tuesday
        }
        else if weekday == 4 {
            return .wednesday
        }
        else if weekday == 5 {
            return .thursday
        }
        else if weekday == 6 {
            return .friday
        } else {
            return .saturday
        }
    }
    
}

extension Double {
    
    /// Convert decimal to a whole number.
    /// Negative number is not acceptable
    func toInt() -> Int {
        (self.isInfinite || self < 0) ? 0 : Int(self)
    }
    
    /// Convert decimal to a whole number if the decimals are 0s.
    /// Otherwise, take 2 decimal places
    func toIntOrDp() -> String {
        let dps = self - Double(self.toInt())
        let dp1 = (dps * 10)
        let dp1s = dp1 - Double(dp1.toInt())
        let dp2 = (dp1s * 10).toInt()
        
        return (dp1.toInt() == 0 && dp2 == 0) ?
            "\(self.toInt())" :
            "\(self.toDp(n: 2))"
    }
    
    /// Retains n number of decimal places of a decimal number without rounding up or down.
    /// Default is 1 decimal place
    /// - Parameter n: A value to specify the number of decimal places
    func toDp(n: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = n
        formatter.roundingMode = .down
        let number = NSNumber(value: self)
        let formatedNumber = formatter.string(from: number) ?? "0"
        return (self < 0) ? "0" : formatedNumber
    }
    
    /// Convert decimal to a percentage number.
    /// - Parameter decimal: A denaminator value to divide with the decimal number
    func toPercentage(with decimal: Double) -> Int {
        /// prevent infinty
        guard decimal > 0 else {
            return 0
        }
        let percentageDouble = (self / decimal) * 100
        /// prevent infinty
        guard percentageDouble > 0 else {
            return 0
        }
        var percentage = Int(percentageDouble)
        /// limit to max 100
        if percentage > 100 {
            percentage = 100
        }
        return percentage
    }
        
    /// Convert decimal number from MB to GB
    /// no changes for unit that is not MB
    /// - Parameter unit: A value to specify the current unit to convet from
    func toGB(from unit: Unit = .mb) -> Double {
        if (self < 0) {
            return 0
        }
        if (unit == .mb) {
            return self / 1_000
        }
        /// no change
        return self
    }
    
    /// Convert decimal number from GB to MB
    func toMB() -> Double {
        if (self < 0) {
            return 0
        }
        return self * 1_000
    }
    
    /// Convert decimal number from MB to Bytes
    func toBytesFromMegabytes() -> Double {
        if (self < 0) {
            return 0
        }
        return self * 1_000_000
    }
    
    /// Calculate the used amount (GB) based on `FillUsage` type
    /// - converts to MB based on `Unit`
    func calculateUsedData(maxData: Double, fillUsageType: FillUsage, dataUnit: Unit) -> Double {
        let usedData = self
        var result: Double = 0
        switch fillUsageType {
        case .accumulate:
            result = usedData
        case .deduct:
            result = maxData - usedData
        }
        switch dataUnit {
        case .gb:
            return result
        case .mb:
            return result.toMB()
        }
    }
    
    /// Calculate the max amount (GB)
    /// - converts to MB based on `Unit`
    func calculateMaxData(dataUnit: Unit) -> Double {
        let max = self
        switch dataUnit {
        case .gb:
            return max
        case .mb:
            return max.toMB()
        }
    }
    
    /// Displayed used amount (GB) over max amount (GB limit)
    func displayedUsage(maxData: Double, fillUsageType: FillUsage, dataUnit: Unit) -> String {
        let used = self.calculateUsedData(
            maxData: maxData,
            fillUsageType: fillUsageType,
            dataUnit: dataUnit
        )
        let max = maxData.calculateMaxData(dataUnit: dataUnit)
        
        switch dataUnit {
        case .gb:
            return "\(used.toDp(n: 2)) / \(max.toDp(n: 2)) \(dataUnit.rawValue)"
        case .mb:
            return "\(used.toDp(n: 0)) / \(max.toDp(n: 0)) \(dataUnit.rawValue)"
        }
    }
    
    /// Displayed used amount (GB) in percentage
    func displayedUsageInPercentage(maxData: Double, fillUsageType: FillUsage) -> Int {
        let usedData = self
        let percentageUsed = usedData.toPercentage(with: maxData)
        let percentageRemaining = 100 - percentageUsed

        switch fillUsageType {
        case .accumulate:
            return percentageUsed
        case .deduct:
            return percentageRemaining
        }
    }
}

extension Int64 {
    
    /// convert bytes (B) to megabytes (MB)
    func toMB() -> Double {
        Double(self) / pow(1_024, 2)
    }
    
    /// convert bytes (B) to megabytes (MB)
    func toBytes() -> Double {
        Double(self) * pow(1_024, 2)
    }
}

extension UInt64 {
    
    /// convert UInt64 to Int64
    func toInt64() -> Int64 {
        .init(self)
    }
    
}
