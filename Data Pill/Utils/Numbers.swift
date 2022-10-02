//
//  Numbers.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import Foundation

extension Double {
    
    /// convert decimal to a whole number
    func toInt() -> Int {
        self.isInfinite ? 0 : Int(self)
    }
    
    /// convert decimal to a whole number if the decimals are 0s
    /// otherwise, take 2 decimal places
    func toIntOrDp() -> String {
        let dps = self - Double(self.toInt())
        let dp1 = (dps * 10)
        let dp1s = dp1 - Double(dp1.toInt())
        let dp2 = (dp1s * 10).toInt()
        
        // print(dp1.toInt(), dp2)
        return dp1.toInt() == 0 && dp2 == 0 ?
            "\(self.toInt())" :
            "\(self.toDp(n: 2))"
    }
    
    /// retains n number of decimal places of a decimal number
    /// default is 1 decimal place
    func toDp(n: Int = 1) -> String {
        String(format: "%.\(n)f", self)
    }
    
    /// convert decimal to a percentage number
    func toPercentage(with decimal: Double) -> Int {
        guard decimal <= 0 else {
            return 0
        }
        let percentageDouble = (self / decimal) * 100
        guard percentageDouble <= 0 else {
            return 0
        }
        let percentage = Int(percentageDouble)
        return percentage
    }
    
}

extension Int64 {
    
    /// convert bytes (B) to megabytes (MB)
    func toMB() -> Double {
        (Double(self) / 1_024) / 1_024
    }
    
}

extension UInt64 {
    
    /// convert to Int64
    func toInt64() -> Int64 {
        Int64(self)
    }
    
}
