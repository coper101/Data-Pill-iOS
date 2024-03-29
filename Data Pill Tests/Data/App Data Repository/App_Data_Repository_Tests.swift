//
//  App_Data_Repository_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 23/10/22.
//

@testable import Data_Pill
import XCTest

final class App_Data_Repository_Tests: XCTestCase {

    private var repository: MockAppDataRepository!

    override func setUpWithError() throws {
        continueAfterFailure = false
        repository = MockAppDataRepository()
    }

    override func tearDownWithError() throws {
        repository = nil
    }
    
    // MARK: - Was Guide Shown
    func test_set_was_guide_shown() throws {
        // (1) Given
        let wasShown = true
        // (2) When
        repository.setWasGuideShown(wasShown)
        // (3) Then
        XCTAssertEqual(repository.wasGuideShown, true)
    }
    
    func test_set_was_guide_not_shown() throws {
        // (1) Given
        let wasShown = false
        // (2) When
        repository.setWasGuideShown(wasShown)
        // (3) Then
        XCTAssertEqual(repository.wasGuideShown, false)
    }
    
    // MARK: - Is Plan Active
    func test_set_is_plan_active() throws {
        // (1) Given
        let isActive = true
        // (2) When
        repository.setIsPlanActive(isActive)
        // (3) Then
        XCTAssertEqual(repository.isPlanActive, true)
    }
    
    func test_set_is_plan_not_active() throws {
        // (1) Given
        let isActive = false
        // (2) When
        repository.setIsPlanActive(isActive)
        // (3) Then
        XCTAssertEqual(repository.isPlanActive, false)
    }
    
    // MARK: - Usage Type
    func test_set_plan_usage_type() throws {
        // (1) Given
        let type = ToggleItem.plan.rawValue
        // (2) When
        repository.setUsageType(type)
        // (3) Then
        XCTAssertEqual(repository.usageType, ToggleItem.plan)
    }
    
    func test_set_daily_usage_type() throws {
        // (1) Given
        let type = ToggleItem.daily.rawValue
        // (2) When
        repository.setUsageType(type)
        // (3) Then
        XCTAssertEqual(repository.usageType, ToggleItem.daily)
    }
    
    // MARK: - Is Period Auto
    func test_set_is_auto_period() throws {
        // (1) Given
        let isAuto = true
        // (2) When
        repository.setIsPeriodAuto(isAuto)
        // (3) Then
        XCTAssertEqual(repository.isPeriodAuto, true)
    }
    
    func test_set_is_not_auto_period() throws {
        // (1) Given
        let isAuto = false
        // (2) When
        repository.setIsPeriodAuto(isAuto)
        // (3) Then
        XCTAssertEqual(repository.isPeriodAuto, false)
    }
    
    // MARK: - Plus Stepper Value
    func test_set_plus_stepper_value_is_data_correct() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        repository.setPlusStepperValue(value, type: .data)
        // (3) Then
        XCTAssertEqual(repository.dataPlusStepperValue, 0.1)
    }
    
    func test_set_plus_stepper_value_is_daily_limit_correct() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        repository.setPlusStepperValue(value, type: .dailyLimit)
        // (3) Then
        XCTAssertEqual(repository.dataLimitPerDayPlusStepperValue, 0.1)
    }
    
    func test_set_plus_stepper_value_is_total_limit_correct() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        repository.setPlusStepperValue(value, type: .planLimit)
        // (3) Then
        XCTAssertEqual(repository.dataLimitPlusStepperValue, 0.1)
    }
    
    // MARK: - Minus Stepper Value
    func test_set_minus_stepper_value_is_data_correct() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        repository.setMinusStepperValue(value, type: .data)
        // (3) Then
        XCTAssertEqual(repository.dataMinusStepperValue, 0.1)
    }
    
    func test_set_minus_stepper_value_is_daily_limit_correct() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        repository.setMinusStepperValue(value, type: .dailyLimit)
        // (3) Then
        XCTAssertEqual(repository.dataLimitPerDayMinusStepperValue, 0.1)
    }
    
    func test_set_minus_stepper_value_is_total_limit_correct() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        repository.setMinusStepperValue(value, type: .planLimit)
        // (3) Then
        XCTAssertEqual(repository.dataLimitMinusStepperValue, 0.1)
    }

}
