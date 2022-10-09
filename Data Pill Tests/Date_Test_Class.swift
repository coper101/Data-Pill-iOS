//
//  Date_Test_Class.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 9/10/22.
//

import XCTest
import Data_Pill

final class Date_Test_Class: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

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
    
    // MARK: - toNumOfDays()
    func test_to_num_of_days() throws {
        let start = "2022-10-01T00:00:00+00:00".toDate()
        let end = "2022-10-11T00:00:00+00:00".toDate()
        let output = start.toNumOfDays(to: end)
        XCTAssertEqual(output, 10)
    }
    
}
