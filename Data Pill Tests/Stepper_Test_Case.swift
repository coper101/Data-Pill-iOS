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

    // MARK: - plus()
    func test_plus_in_range() {
        let output = Stepper.plus(value: "0.0", max: 5.0)
        XCTAssertEqual(output, "1.0")
    }
    
    func test_plus_max_value() {
        let output = Stepper.plus(value: "5.0", max: 5.0)
        XCTAssertEqual(output, "5.0")
    }
    
    func test_plus_value_out_of_range() {
        let output = Stepper.plus(value: "5.0", max: 4.0)
        XCTAssertEqual(output, "5.0")
    }
    
    // MARK: - minus()
    func test_minus_in_range() {
        let output = Stepper.minus(value: "5.0")
        XCTAssertEqual(output, "4.0")
    }
    
    func test_minus_min_value() {
        let output = Stepper.minus(value: "0.0")
        XCTAssertEqual(output, "0.0")
    }
    
    func test_minus_out_of_range() {
        let output = Stepper.minus(value: "-1.0")
        XCTAssertEqual(output, "-1.0")
    }

}
