//
//  Validator_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 29/12/22.
//

import XCTest
@testable import Data_Pill

final class Validator_Test_Case: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    /// hasExceededLimit()
    func test_has_exceeded_limit_above_max() throws {
        // (1) Given
        let value = "6.0"
        let max = 5.0
        let min = 0.0
        // (2) When
        let hasExceeded = Validator.hasExceededLimit(
            value: value,
            max: max,
            min: min
        )
        // (3) Then
        XCTAssertTrue(hasExceeded)
    }
    
    func test_has_exceeded_limit_below_min() throws {
        // (1) Given
        let value = "-1.0"
        let max = 5.0
        let min = 0.0
        // (2) When
        let hasExceeded = Validator.hasExceededLimit(
            value: value,
            max: max,
            min: min
        )
        // (3) Then
        XCTAssertTrue(hasExceeded)
    }
    
    func test_has_not_exceeded_limit() throws {
        // (1) Given
        let value = "4.0"
        let max = 5.0
        let min = 0.0
        // (2) When
        let hasExceeded = Validator.hasExceededLimit(
            value: value,
            max: max,
            min: min
        )
        // (3) Then
        XCTAssertFalse(hasExceeded)
    }
    
    
}
