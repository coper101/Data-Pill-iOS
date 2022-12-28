//
//  Stepper_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 11/10/22.
//

import XCTest
@testable import Data_Pill

final class Stepper_Test_Case: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {}

    // MARK: Plus
    func test_plus_in_range() {
        // (1) Given
        // (2) When
        let output = Stepper.plus(value: "0.0", max: 5.0, by: 1.0)
        // (3) Then
        XCTAssertEqual(output, "1.0")
    }
    
    func test_plus_max_value() {
        // (1) Given
        // (2) When
        let output = Stepper.plus(value: "5.0", max: 5.0, by: 1.0)
        // (3) Then
        XCTAssertEqual(output, "5.0")
    }
    
    func test_plus_exceeds_max_value() {
        // (1) Given
        // (2) When
        var hasExceeded = false
        let output = Stepper.plus(
            value: "5.0",
            max: 5.0,
            by: 1.0,
            onExceed: {
                hasExceeded = true
            }
        )
        // (3) Then
        XCTAssertEqual(hasExceeded, true)
    }
    
    func test_plus_value_out_of_range() {
        // (1) Given
        // (2) When
        let output = Stepper.plus(value: "5.0", max: 4.0, by: 1.0)
        // (3) Then
        XCTAssertEqual(output, "5.0")
    }
    
    func test_plus_in_range_decimal() {
        // (1) Given
        // (2) When
        let output = Stepper.plus(value: "0.0", max: 5.0, by: 0.1)
        // (3) Then
        XCTAssertEqual(output, "0.1")
    }
    
    // MARK: Minus
    func test_minus_in_range() {
        // (1) Given
        // (2) When
        let output = Stepper.minus(value: "5.0", by: 1.0)
        // (3) Then
        XCTAssertEqual(output, "4.0")
    }
    
    func test_minus_min_value() {
        // (1) Given
        // (2) When
        let output = Stepper.minus(value: "0.0", by: 1)
        // (3) Then
        XCTAssertEqual(output, "0.0")
    }
    
    func test_minus_out_of_range() {
        // (1) Given
        // (2) When
        let output = Stepper.minus(value: "-1.0", by: 1.0)
        // (3) Then
        XCTAssertEqual(output, "-1.0")
    }

}
