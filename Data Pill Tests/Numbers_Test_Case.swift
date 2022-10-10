//
//  Data_Pill_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 9/10/22.
//

import XCTest
@testable import Data_Pill

final class Numbers_Test_Case: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {}

    // MARK: - toInt()
    func test_non_zero_int_conversion() throws {
        let output = 40.1.toInt()
        XCTAssertEqual(output, 40)
    }
    
    func test_zero_int_conversion() throws {
        let output = 0.001.toInt()
        XCTAssertEqual(output, 0)
    }
    
    func test_negative_int_conversion() throws {
        let number = -2.0
        let output = number.toInt()
        XCTAssertEqual(output, 0)
    }
    
    // MARK: - toIntOrDp()
    func test_round_4_decimal_places() throws {
        let output = 3.2032.toIntOrDp()
        XCTAssertEqual(output, "3.20")
    }
    
    func test_round_2_decimal_places() throws {
        let output = 3.20.toIntOrDp()
        XCTAssertEqual(output, "3.20")
    }
    
    func test_round_0_decimal_place() throws {
        let output = 3.00.toIntOrDp()
        XCTAssertEqual(output, "3")
    }
    
    func test_round_negative_decimal_place() throws {
        let number = -2.0
        let output = number.toIntOrDp()
        XCTAssertEqual(output, "0")
    }

    // MARK: - toDp()
    func test_4_decimal_places() throws {
        let output = 4.123456.toDp(n: 4)
        XCTAssertEqual(output, "4.1234")
    }
    
    func test_2_decimal_places() throws {
        let output = 4.123456.toDp(n: 2)
        XCTAssertEqual(output, "4.12")
    }
    
    func test_1_decimal_places() throws {
        let output = 4.123456.toDp(n: 1)
        XCTAssertEqual(output, "4.1")
    }
    
    func test_negative_decimal_places() throws {
        let number = -4.12356
        let output = number.toDp(n: 1)
        XCTAssertEqual(output, "0")
    }
    
    // MARK: - toPerc()
    func test_to_percentage() throws {
        let output = 2.toPercentage(with: 10)
        XCTAssertEqual(output, 20)
    }
    
    func test_to_percentage_exceeds_max() throws {
        let output = 14.toPercentage(with: 10)
        XCTAssertEqual(output, 100)
    }
    
    func test_to_percentage_negative() throws {
        let number = -2.0
        let output = number.toPercentage(with: 10)
        XCTAssertEqual(output, 0)
    }
    
    // MARK: - toGB()
    func test_megabyte_to_gigabye() throws {
        let output = 1_400.toGB()
        XCTAssertEqual(output, 1.4)
    }
    
    func test_negative_megabyte_to_gigabye() throws {
        let number = -1_400.0
        let output = number.toGB()
        XCTAssertEqual(output, 0.0)
    }
    
}
