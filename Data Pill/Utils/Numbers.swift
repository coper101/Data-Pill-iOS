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
    func toGB(from unit: Unit = .mb) -> Double {
        if unit == .mb {
            return self / 1_000
        }
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
    
    /// convert to Int64
    func toInt64() -> Int64 {
        Int64(self)
    }
    
}
