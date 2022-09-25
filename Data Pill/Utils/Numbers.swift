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
        Int(self)
    }
    
    /// retains 1 decimal place of a decimal number
    func to1dp() -> String {
        String(format: "%.1f", self)
    }
    
    /// convert to a percentage number
    func toPerc(max: Double) -> Int {
        print("toPerc: ", (self / max) * 100)
        return Int((self / max) * 100)
    }
    
}
