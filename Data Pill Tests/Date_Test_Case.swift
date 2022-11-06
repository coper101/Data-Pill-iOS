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
    
    // MARK: - toDayMonthFormat()
    func test_to_day_month_format() throws {
        let date = "2022-10-09T00:00:00+00:00".toDate()
        let output = date.toDayMonthFormat()
        XCTAssertEqual(output, "9 Oct")
    }
    
    func test_to_day_month_invalid_format() throws {
        let date = "2022-10-32T00:00:00+00:00".toDate()
        let output = date.toDayMonthFormat()
        XCTAssertNotEqual(output, "32 Oct")
    }
    
    // MARK: - toDayMonthYearFormat()
    func test_to_day_month_year_format() throws {
        let date = "2022-10-09T00:00:00+00:00".toDate()
        let output = date.toDayMonthYearFormat()
        XCTAssertEqual(output, "9 Oct 2022")
    }
    
    func test_to_day_month_year_invalid_format() throws {
        let date = "2022-10-32T00:00:00+00:00".toDate()
        let output = date.toDayMonthYearFormat()
        XCTAssertNotEqual(output, "32 Oct 2022")
    }

    // MARK: - toDayFormat()
    func test_to_day_format() throws {
        let date = "2022-10-09T00:00:00+00:00".toDate()
        let output = date.toDayFormat()
        XCTAssertEqual(output, "9")
    }
    
    func test_to_day_invalid_format() throws {
        let date = "2022-10-32T00:00:00+00:00".toDate()
        let output = date.toDayFormat()
        XCTAssertNotEqual(output, "32")
    }

    // MARK: - isToday()
    func test_date_is_today() throws {
        let date = Date()
        let output = date.isToday()
        XCTAssertTrue(output)
    }
    
    func test_date_is_not_today() throws {
        let date = Calendar.current.date(
            byAdding: .day, value: -1, to: .init())!
        let output = date.isToday()
        XCTAssertFalse(output)
    }
    
    // MARK: - fromDateRange()
    func test_from_date_range_in() throws {
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let range = startDate.fromDateRange()
        let output = range.contains("2022-10-02T00:00:00+00:00".toDate())
        XCTAssertTrue(output)
    }
    
    func test_from_date_range_out() throws {
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let range = startDate.fromDateRange()
        let output = range.contains("2022-09-30T00:00:00+00:00".toDate())
        XCTAssertFalse(output)
    }
    
    
    // MARK: - toDateRange()
    func test_to_date_range_in() throws {
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        let range = endDate.toDateRange()
        let output = range.contains("2022-10-01T00:00:00+00:00".toDate())
        XCTAssertTrue(output)
    }
    
    func test_to_date_range_out() throws {
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        let range = endDate.toDateRange()
        let output = range.contains("2022-11-01T00:00:00+00:00".toDate())
        XCTAssertFalse(output)
    }
    
    // MARK: - isDateInRange()
    func test_date_in_range_in() throws {
        let date = "2022-10-02T00:00:00+00:00".toDate()
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-30T00:00:00+00:00".toDate()
        )
        XCTAssertTrue(output)
    }
    
    func test_date_not_in_range_out_same() throws {
        let date = "2022-10-01T00:00:00+00:00".toDate()
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-01T00:00:00+00:00".toDate()
        )
        XCTAssertFalse(output)
    }
    
    func test_date_not_in_range_out_lower() throws {
        let date = "2022-09-30T00:00:00+00:00".toDate()
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-30T00:00:00+00:00".toDate()
        )
        XCTAssertFalse(output)
    }
    
    func test_date_not_in_range_out_higher() throws {
        let date = "2022-11-01T00:00:00+00:00".toDate()
        let output = date.isDateInRange(
            from: "2022-10-01T00:00:00+00:00".toDate(),
            to: "2022-10-30T00:00:00+00:00".toDate()
        )
        XCTAssertFalse(output)
    }
    
    // MARK: - addDay()
    func test_add_a_day() throws {
        let date = "2022-10-01T00:00:00+00:00".toDate()
        let output = date.addDay(value: 1)
        XCTAssertEqual(output, "2022-10-02T00:00:00+00:00".toDate())
    }
    
    func test_add_2_days() throws {
        let date = "2022-10-01T00:00:00+00:00".toDate()
        let output = date.addDay(value: 2)
        XCTAssertEqual(output, "2022-10-03T00:00:00+00:00".toDate())
    }
    
    func test_add_30_days() throws {
        let date = "2022-10-05T00:00:00+00:00".toDate()
        let output = date.addDay(value: 30)
        XCTAssertEqual(output, "2022-11-04T00:00:00+00:00".toDate())
    }
    
    // MARK: - toNumOfDays()
    func test_to_num_of_days() throws {
        let start = "2022-10-01T00:00:00+00:00".toDate()
        let end = "2022-10-10T00:00:00+00:00".toDate()
        let output = start.toNumOfDays(to: end)
        XCTAssertEqual(output, 10)
    }
    
}
