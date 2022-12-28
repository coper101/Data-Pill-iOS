//
//  Validator.swift
//  Data Pill
//
//  Created by Wind Versi on 28/12/22.
//

import Foundation

class Validator {
    
    /// Returns whether the value has exceed the min or max value
    /// - Parameters:
    ///   - value : A value to determine if it has exceeded min or max value
    ///   - max : A value to compare if it has reached the maximum value
    ///   - min : A value to compare if it has reached the minimum value
    static func hasExceededLimit(
        value: String,
        max: Double,
        min: Double
    ) -> Bool {
        guard let value = Double(value) else {
            return false
        }
        let overMax = value > max
        let underMin = value < min
        return overMax || underMin
    }
    
}
