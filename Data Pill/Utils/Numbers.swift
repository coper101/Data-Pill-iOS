//
//  Numbers.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import Foundation

extension Double {
    
    /// Convert decimal to a whole number.
    /// Negative number is not acceptable
    func toInt() -> Int {
        return (self.isInfinite || self < 0) ? 0 : Int(self)
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
    
    /// convert decimal number from MB to GB
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
}

extension Int64 {
    
    /// convert bytes (B) to megabytes (MB)
    func toMB() -> Double {
        Double(self) / pow(1_024, 2)
    }

}

extension UInt64 {
    
    /// convert UInt64 to Int64
    func toInt64() -> Int64 {
        Int64(self)
    }
    
}
