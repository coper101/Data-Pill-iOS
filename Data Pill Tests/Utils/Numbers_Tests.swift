//
//  Numbers_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 9/10/22.
//

import XCTest
@testable import Data_Pill

final class Numbers_Tests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}
    
    // MARK: - Prefix Day
    func test_prefix_day_is_1_day() throws {
        // (1) Given
        let input = 1
        // (2) When
        let output = input.prefixDay()
        // (3) Then
        XCTAssertEqual(output, "1 Day")
    }
    
    func test_prefix_day_is_2_days() throws {
        // (1) Given
        let input = 2
        // (2) When
        let output = input.prefixDay()
        // (3) Then
        XCTAssertEqual(output, "2 Days")
    }
    
    func test_prefix_day_is_negative_1_day() throws {
        // (1) Given
        let input = -1
        // (2) When
        let output = input.prefixDay()
        // (3) Then
        XCTAssertEqual(output, "-1 Day")
    }
    
    // MARK: - To Weekday Name
    func test_to_weekday_name_sunday() throws {
        // (1) Given
        let input = 1
        // (2) When
        let output = input.toShortWeekdayName()
        // (3) Then
        XCTAssertEqual(output, "Sun")
    }
    
    func test_to_weekday_name_saturday() throws {
        // (1) Given
        let input = 7
        // (2) When
        let output = input.toShortWeekdayName()
        // (3) Then
        XCTAssertEqual(output, "Sat")
    }

    // MARK: - To Int
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
    
    // MARK: - To Int or Dp
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

    // MARK: - To Dp
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
    
    // MARK: - To Percentage
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
    
    // MARK: - To GB
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
    
    // MARK: - From MB to B
    func test_megabyte_to_byte() throws {
        // (1) Given
        let input = 10.0
        // (2) When
        let output = input.toBytesFromMegabytes()
        // (3) Then
        XCTAssertEqual(output, 10_000_000)
    }
    
    func test_negative_megabyte_to_byte() throws {
        // (1) Given
        let input = -10.0
        // (2) When
        let output = input.toBytesFromMegabytes()
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    // MARK: Displays
    /// - Calculated Used Data
    func test_calculate_used_data_accumulate_in_gb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.gb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 1)
    }
    
    func test_calculate_used_data_accumulate_in_mb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.mb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 1_000)
    }
    
    func test_calculate_used_data_accumulate_in_gb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.gb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    func test_calculate_used_data_accumulate_in_mb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.mb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    func test_calculate_used_data_deduct_in_gb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.gb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 4)
    }
    
    func test_calculate_used_data_deduct_in_mb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.mb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 4_000)
    }
    
    func test_calculate_used_data_deduct_in_gb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.gb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    func test_calculate_used_data_deduct_in_mb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.mb
        // (2) When
        let output = used.calculateUsedData(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    /// - Calculated Used Data
    func test_calculate_max_data_in_gb() throws {
        // (1) Given
        let max = 5.0
        let unit = Unit.gb
        // (2) When
        let output = max.calculateMaxData(dataUnit: unit)
        // (3) Then
        XCTAssertEqual(output, 5)
    }
    
    func test_calculate_max_data_in_gb_zero() throws {
        // (1) Given
        let max = 0.0
        let unit = Unit.gb
        // (2) When
        let output = max.calculateMaxData(dataUnit: unit)
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    func test_calculate_max_data_in_mb() throws {
        // (1) Given
        let max = 5.0
        let unit = Unit.mb
        // (2) When
        let output = max.calculateMaxData(dataUnit: unit)
        // (3) Then
        XCTAssertEqual(output, 5_000)
    }
    
    func test_calculate_max_data_in_mb_zero() throws {
        // (1) Given
        let max = 0.0
        let unit = Unit.mb
        // (2) When
        let output = max.calculateMaxData(dataUnit: unit)
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    /// - displayed usage
    func test_displayed_usage_accumulate_in_gb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.gb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "1 / 5 GB")
    }
    
    func test_displayed_usage_accumulate_in_gb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.gb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "0 / 5 GB")
    }
    
    func test_displayed_usage_deduct_in_gb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.gb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "4 / 5 GB")
    }
    
    func test_displayed_usage_deduct_in_gb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.gb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "5 / 5 GB")
    }
    
    func test_displayed_usage_accumulate_in_mb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.mb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "1,000 / 5,000 MB")
    }
    
    func test_displayed_usage_accumulate_in_mb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.accumulate
        let unit = Unit.mb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "0 / 5,000 MB")
    }
    
    func test_displayed_usage_deduct_in_mb() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.mb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "4,000 / 5,000 MB")
    }
    
    func test_displayed_usage_deduct_in_mb_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.deduct
        let unit = Unit.mb
        // (2) When
        let output = used.displayedUsage(
            maxData: max,
            fillUsageType: type,
            dataUnit: unit
        )
        // (3) Then
        XCTAssertEqual(output, "5,000 / 5,000 MB")
    }
    
    /// - displayed usaged in percentage
    func test_displayed_usaged_in_percentage_accumulate() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.accumulate
        // (2) When
        let output = used.displayedUsageInPercentage(maxData: max, fillUsageType: type)
        // (3) Then
        XCTAssertEqual(output, 20)
    }
    
    func test_displayed_usaged_in_percentage_accumulate_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.accumulate
        // (2) When
        let output = used.displayedUsageInPercentage(maxData: max, fillUsageType: type)
        // (3) Then
        XCTAssertEqual(output, 0)
    }
    
    func test_displayed_usaged_in_percentage_deduct() throws {
        // (1) Given
        let used = 1.0
        let max = 5.0
        let type = FillUsage.deduct
        // (2) When
        let output = used.displayedUsageInPercentage(maxData: max, fillUsageType: type)
        // (3) Then
        XCTAssertEqual(output, 80)
    }
    
    func test_displayed_usaged_in_percentage_deduct_zero() throws {
        // (1) Given
        let used = 0.0
        let max = 5.0
        let type = FillUsage.deduct
        // (2) When
        let output = used.displayedUsageInPercentage(maxData: max, fillUsageType: type)
        // (3) Then
        XCTAssertEqual(output, 100)
    }
}
