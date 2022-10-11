//
//  Validation.swift
//  Data Pill
//
//  Created by Wind Versi on 11/10/22.
//

import Foundation

class Stepper {
    
    /// increases the value of stepper
    /// - Parameters:
    ///   - value: A value to  increment by one
    ///   - max    : A value to limit the value from increasing
    static func plus(value: String, max: Double) -> String {
        guard var doubleValue = Double(value) else {
            /// no change
            return value
        }
        doubleValue += 1
        guard doubleValue <= max else {
            /// no change
            return value
        }
        return "\(doubleValue)"
    }
    
    /// increases the value of stepper
    /// - Parameters:
    ///   - value : A value to  decrement by one
    ///   - minus : A value to limit the value from decreasing
    static func minus(value: String, min: Double = 0) -> String {
        guard var doubleValue = Double(value) else {
            /// no change
            return value
        }
        doubleValue -= 1
        guard doubleValue >= min else {
            /// no change
            return value
        }
        return "\(doubleValue)"
    }
    
}
