//
//  App_Data_Repository_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 23/10/22.
//

import XCTest
@testable import Data_Pill

final class App_Data_Repository_Test_Case: XCTestCase {

    var repository: MockAppDataRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = MockAppDataRepository()
    }

    override func tearDownWithError() throws {
        repository = nil
    }
    
    func test_set_usage_type_is_correct() throws {
        // (1) Given
        let input = ToggleItem.plan.rawValue
        // (2) When
        repository.setUsageType(input)
        // (3) Then
        let output = repository.usageType
        XCTAssertEqual(output, ToggleItem.plan)
    }
    
    func test_set_is_notification_is_correct() throws {
        // (1) Given
        let input = false
        // (2) When
        repository.setIsPeriodAuto(input)
        // (3) Then
        let output = repository.isPeriodAuto
        XCTAssertEqual(output, false)
    }
    
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
