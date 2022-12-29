//
//  Validation.swift
//  Data Pill
//
//  Created by Wind Versi on 11/10/22.
//

import Foundation

class Stepper {
    
    /// Returns the new value of stepper after incrementing
    /// - Parameters:
    ///   - value : A value to  increment by one
    ///   - max : A value to limit the value from increasing
    ///   - by : A value to specify the accuracy of value to add
    ///   - onExceed : A block to execute when the new value exceeds the max value
    static func plus(
        value: String,
        max: Double,
        by addValue: Double,
        onExceed: Action = {}
    ) -> String {
        guard var doubleValue = Double(value) else {
            /// no change
            onExceed()
            return value
        }
        doubleValue += addValue
        guard doubleValue <= max else {
            /// no change
            onExceed()
            return value
        }
        return .init(format: "%.1f", doubleValue)
    }
    
    /// Returns the new value of stepper after decrementing
    /// - Parameters:
    ///   - value : A value to  decrement by one
    ///   - minus : A value to limit the value from decreasing
    ///   - by    : A value to specify the accuracy of value to minus
    static func minus(
        value: String,
        min: Double = 0,
        by minusValue: Double
    ) -> String {
        guard var doubleValue = Double(value) else {
            /// no change
            return value
        }
        doubleValue -= minusValue
        guard doubleValue >= min else {
            /// no change
            return value
        }
        return .init(format: "%.1f", doubleValue)
    }
    
}
