//
//  Numbers_Test_Case.swift
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

    /// toInt
    func test_convert_decimal_to_int() throws {
        // (1) Given
        let input = 40.1
        // (2) When
        let output = input.toInt()
        // (3) Then
        XCTAssertEqual(output, 40)
    }
    
    func test_convert_zero_to_int() throws {
        // (1) Given
        let input = 0.001
        // (2) When
        let output = input.toInt()
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    func test_convert_negative_number_to_int() throws {
        // (1) Given
        let input = -2.0
        // (2) When
        let output = input.toInt()
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    /// toIntOrDp
    func test_round_decimal_places_to_2_dp() throws {
        // (1) Given
        let input = 1.2345
        // (2) When
        let output = input.toIntOrDp()
        // (3) Then
        XCTAssertEqual(output, "1.23")
    }
    
    func test_round_2_decimal_places_to_1_dp() throws {
        // (1) Given
        let input = 1.2045
        // (2) When
        let output = input.toIntOrDp()
        // (3) Then
        XCTAssertEqual(output, "1.2")
    }
    
    func test_round_zero_decimal_places_to_int() throws {
        // (1) Given
        let input = 1.00
        // (2) When
        let output = input.toIntOrDp()
        // (3) Then
        XCTAssertEqual(output, "1")
    }
    
    func test_round_negative_decimal_place_to_int() throws {
        // (1) Given
        let number = -2.0
        // (2) When
        let output = number.toIntOrDp()
        // (3) Then
        XCTAssertEqual(output, "0")
    }

    /// toDp
    func test_4_decimal_places() throws {
        // (1) Given
        let input = 4.123456
        let n = 4
        // (2) When
        let output = input.toDp(n: n)
        // (3) Then
        XCTAssertEqual(output, "4.1234")
    }
    
    func test_2_decimal_places() throws {
        // (1) Given
        let input = 4.123456
        let n = 2
        // (2) When
        let output = input.toDp(n: n)
        // (3) Then
        XCTAssertEqual(output, "4.12")
    }
    
    func test_1_decimal_places() throws {
        // (1) Given
        let input = 4.123456
        let n = 1
        // (2) When
        let output = input.toDp(n: n)
        // (3) Then
        XCTAssertEqual(output, "4.1")
    }
    
    func test_negative_decimal_places() throws {
        // (1) Given
        let input = -4.12356
        let n = 1
        // (2) When
        let output = input.toDp(n: n)
        // (3) Then
        XCTAssertEqual(output, "0")
    }
    
    /// toPerc
    func test_to_percentage() throws {
        // (1) Given
        let numerator = 2.0
        let denaminator = 10.0
        // (2) When
        let output = numerator.toPercentage(with: denaminator)
        // (3) Then
        XCTAssertEqual(output, 20)
    }
    
    func test_to_percentage_exceeds_max() throws {
        // (1) Given
        let numerator = 14.0
        let denaminator = 10.0
        // (2) When
        let output = numerator.toPercentage(with: denaminator)
        // (3) Then
        XCTAssertEqual(output, 100)
    }
    
    func test_to_percentage_negative() throws {
        // (1) Given
        let numerator = -2.0
        let denaminator = 10.0
        // (2) When
        let output = numerator.toPercentage(with: denaminator)
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    /// toGB
    func test_megabyte_to_gigabye() throws {
        // (1) Given
        let input = 1_400.0
        // (2) When
        let output = input.toGB()
        // (3) Then
        XCTAssertEqual(output, 1.4)
    }
    
    func test_negative_megabyte_to_gigabyte() throws {
        // (1) Given
        let input = -1_400.0
        // (2) When
        let output = input.toGB()
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    /// toInt64
//    func test_unsigned_64_to_int() throws {
//        let uint64: UInt64 = 1_000_000
//    }
    
}
