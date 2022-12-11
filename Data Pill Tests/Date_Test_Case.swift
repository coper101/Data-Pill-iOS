//
//  Date_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 9/10/22.
//

import XCTest
@testable import Data_Pill

final class Date_Test_Case: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}
    
    /// toDayMonthFormat
    func test_to_day_month_format() throws {
        // (1) Given
        let date = "2022-10-09T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toDayMonthFormat()
        // (3) Then
        XCTAssertEqual(output, "9 Oct")
    }
    
    func test_to_day_month_invalid_format() throws {
        // (1) Given
        let date = "2022-10-32T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toDayMonthFormat()
        // (3) Then
        XCTAssertNotEqual(output, "32 Oct")
    }
    
    /// toDayMonthYearFormat
    func test_to_day_month_year_format() throws {
        // (1) Given
        let date = "2022-10-09T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toDayMonthYearFormat()
        // (3) Then
        XCTAssertEqual(output, "9 Oct 2022")
    }
    
    func test_to_day_month_year_invalid_format() throws {
        // (1) Given
        let date = "2022-10-32T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toDayMonthYearFormat()
        // (3) Then
        XCTAssertNotEqual(output, "32 Oct 2022")
    }

    /// toDayFormat
    func test_to_day_format() throws {
        // (1) Given
        let date = "2022-10-09T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toDayFormat()
        // (3) Then
        XCTAssertEqual(output, "9")
    }
    
    func test_to_day_invalid_format() throws {
        // (1) Given
        let date = "2022-10-32T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toDayFormat()
        // (3) Then
        XCTAssertNotEqual(output, "32")
    }
    
    /// toWeekdayFormat
    func test_to_weekday_format() throws {
        // (1) Given
        let date = "2022-10-31T00:00:00+00:00".toDate()
        // (2) When
        let output = date.toWeekdayFormat()
        // (3) Then
        XCTAssertEqual(output, "Mon")
    }
    
    /// isToday
    func test_date_is_today() throws {
        // (1) Given
        let date = Date()
        // (2) When
        let output = date.isToday()
        // (3) Then
        XCTAssertTrue(output)
    }
    
    func test_date_is_not_today() throws {
        // (1) Given
        let date = Calendar.current.date(
            byAdding: .day, value: -1, to: .init())!
        // (2) When
        let output = date.isToday()
        // (3) Then
        XCTAssertFalse(output)
    }
    
    func test_from_date_range_in() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let range = startDate.fromDateRange()
        // (2) When
        let output = range.contains("2022-10-02T00:00:00+00:00".toDate())
        // (3) Then
        XCTAssertTrue(output)
    }
    
    func test_from_date_range_out() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let range = startDate.fromDateRange()
        // (2) When
        let output = range.contains("2022-09-30T00:00:00+00:00".toDate())
        // (3) Then
        XCTAssertFalse(output)
    }
    
    func test_to_date_range_in() throws {
        // (1) Given
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        let range = endDate.toDateRange()
        // (2) When
        let output = range.contains("2022-10-01T00:00:00+00:00".toDate())
        // (3) Then
        XCTAssertTrue(output)
    }
    
    func test_to_date_range_out() throws {
        // (1) Given
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        let range = endDate.toDateRange()
        // (2) When
        let output = range.contains("2022-11-01T00:00:00+00:00".toDate())
        // (3) Then
        XCTAssertFalse(output)
    }
    
    func test_date_in_range_is_in_range() throws {
        // (1) Given
        let date = "2022-10-02T00:00:00+00:00".toDate()
        // (2) When
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-30T00:00:00+00:00".toDate()
        )
        // (3) Then
        XCTAssertTrue(output)
    }
    
    func test_date_not_in_range_is_out_of_range_same() throws {
        // (1) Given
        let date = "2022-10-01T00:00:00+00:00".toDate()
        // (2) When
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-01T00:00:00+00:00".toDate()
        )
        // (3) Then
        XCTAssertFalse(output)
    }
    
    func test_date_not_in_range_is_out_of_range_lower() throws {
        // (1) Given
        let date = "2022-09-30T00:00:00+00:00".toDate()
        // (2) When
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-30T00:00:00+00:00".toDate()
        )
        // (3) Then
        XCTAssertFalse(output)
    }
    
    func test_date_not_in_is_out_of_range_higher() throws {
        // (1) Given
        let date = "2022-11-01T00:00:00+00:00".toDate()
        // (2) When
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-30T00:00:00+00:00".toDate()
        )
        // (3) Then
        XCTAssertFalse(output)
    }
    
    func test_add_a_day() throws {
        // (1) Given
        let date = "2022-10-01T00:00:00+00:00".toDate()
        // (2) When
        let output = date.addDay(value: 1)
        // (3) Then
        XCTAssertEqual(output, "2022-10-02T00:00:00+00:00".toDate())
    }
    
    func test_add_two_days() throws {
        // (1) Given
        let date = "2022-10-01T00:00:00+00:00".toDate()
        // (2) When
        let output = date.addDay(value: 2)
        // (3) Then
        XCTAssertEqual(output, "2022-10-03T00:00:00+00:00".toDate())
    }
    
    func test_add_thirty_days() throws {
        // (1) Given
        let date = "2022-10-05T00:00:00+00:00".toDate()
        // (2) When
        let output = date.addDay(value: 30)
        // (3) Then
        XCTAssertEqual(output, "2022-11-04T00:00:00+00:00".toDate())
    }
    
    func test_to_num_of_days() throws {
        // (1) Given
        let start = "2022-10-01T00:00:00+00:00".toDate()
        let end = "2022-10-10T00:00:00+00:00".toDate()
        // (2) When
        let output = start.toNumOfDays(to: end)
        // (3) Then
        XCTAssertEqual(output, 10)
    }
    
}
