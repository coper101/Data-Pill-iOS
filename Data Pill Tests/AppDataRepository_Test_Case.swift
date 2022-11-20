//
//  AppDataRepository_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 23/10/22.
//

import XCTest
@testable import Data_Pill

final class AppDataRepository_Test_Case: XCTestCase {

    var repository: MockAppDataRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = MockAppDataRepository()
    }

    override func tearDownWithError() throws {
        repository = nil
    }
    
    // MARK: - setUsageType()
    func test_set_usage_type_is_correct() throws {
        // (1) Given
        let input = ToggleItem.plan.rawValue
        // (2) When
        repository.setUsageType(input)
        // (3) Then
        let output = repository.usageType
        XCTAssertEqual(output, ToggleItem.plan)
    }
    
    // MARK: - setIsNotification()
    func test_set_is_notification_is_correct() throws {
        // (1) Given
        let input = false
        // (2) When
        repository.setIsPeriodAuto(input)
        // (3) Then
        let output = repository.isPeriodAuto
        XCTAssertEqual(output, false)
    }
    
    // MARK: - setDataAmount()
    func test_set_data_amount_is_correct() throws {
        // (1) Given
        let input = 10.0
        // (2) When
        repository.setDataAmount(input)
        // (3) Then
        let output = repository.dataAmount
        XCTAssertEqual(output, 10.0)
    }
    
    // MARK: - setStartDate()
    func test_set_start_date_is_correct() throws {
        // (1) Given
        let input = "2022-10-01T00:00:00+00:00".toDate()
        // (2) When
        repository.setStartDate(input)
        // (3) Then
        let output = repository.startDate
        XCTAssertEqual(output, "2022-10-01T00:00:00+00:00".toDate())
    }
    
    // MARK: - setEndDate()
    func test_set_end_date_is_correct() throws {
        // (1) Given
        let input = "2022-10-05T00:00:00+00:00".toDate()
        // (2) When
        repository.setEndDate(input)
        // (3) Then
        let output = repository.endDate
        XCTAssertEqual(output, "2022-10-05T00:00:00+00:00".toDate())
    }
    
    // MARK: - setDataLimit()
    func test_set_data_limit_is_correct() throws {
        // (1) Given
        let input = 9.0
        // (2) When
        repository.setDataLimit(input)
        // (3) Then
        let output = repository.dataLimit
        XCTAssertEqual(output, 9.0)
    }
    
    // MARK: - setDataLimitPerDay()
    func test_set_data_limit_per_day_is_correct() throws {
        // (1) Given
        let input = 1.0
        // (2) When
        repository.setDataLimitPerDay(input)
        // (3) Then
        let output = repository.dataLimitPerDay
        XCTAssertEqual(output, 1.0)
    }
    
    // MARK: - setPlusStepperValue()
    func test_set_plus_stepper_value_is_data_correct() throws {
        // (1) Given
        let input = 0.1
        // (2) When
        repository.setPlusStepperValue(input, type: .data)
        // (3) Then
        let output = repository.dataPlusStepperValue
        XCTAssertEqual(output, 0.1)
    }
    
    func test_set_plus_stepper_value_is_daily_limit_correct() throws {
        // (1) Given
        let input = 0.1
        // (2) When
        repository.setPlusStepperValue(input, type: .dailyLimit)
        // (3) Then
        let output = repository.dataLimitPerDayPlusStepperValue
        XCTAssertEqual(output, 0.1)
    }
    
    func test_set_plus_stepper_value_is_total_limit_correct() throws {
        // (1) Given
        let input = 0.1
        // (2) When
        repository.setPlusStepperValue(input, type: .planLimit)
        // (3) Then
        let output = repository.dataLimitPlusStepperValue
        XCTAssertEqual(output, 0.1)
    }
    
    // MARK: - setMinusStepperValue()
    func test_set_minus_stepper_value_is_data_correct() throws {
        // (1) Given
        let input = 0.1
        // (2) When
        repository.setMinusStepperValue(input, type: .data)
        // (3) Then
        let output = repository.dataMinusStepperValue
        XCTAssertEqual(output, 0.1)
    }
    
    func test_set_minus_stepper_value_is_daily_limit_correct() throws {
        // (1) Given
        let input = 0.1
        // (2) When
        repository.setMinusStepperValue(input, type: .dailyLimit)
        // (3) Then
        let output = repository.dataLimitPerDayMinusStepperValue
        XCTAssertEqual(output, 0.1)
    }
    
    func test_set_minus_stepper_value_is_total_limit_correct() throws {
        // (1) Given
        let input = 0.1
        // (2) When
        repository.setMinusStepperValue(input, type: .planLimit)
        // (3) Then
        let output = repository.dataLimitMinusStepperValue
        XCTAssertEqual(output, 0.1)
    }

}
