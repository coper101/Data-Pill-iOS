//
//  AppViewModel_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 6/11/22.
//

import XCTest
@testable import Data_Pill
import CoreData

final class AppViewModel_Test_Case: XCTestCase {
    
    var appViewModel: AppViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        appViewModel = createAppViewModel()
    }

    override func tearDownWithError() throws {
        appViewModel = nil
    }
    
    func createAppViewModel(
        appDataRepository: AppDataRepositoryProtocol? = nil,
        dataUsageRepository: DataUsageRepositoryProtocol? = nil,
        networkDataRepository: NetworkDataRepositoryProtocol? = nil,
        setupValues: Bool = false
    ) -> AppViewModel {
        let defaultDataUsageRepository = DataUsageRepository(
            database: InMemoryLocalDatabase(
                container: .dataUsage,
                entity: .data
            )
        )
        return .init(
            appDataRepository: appDataRepository ?? MockAppDataRepository(),
            dataUsageRepository: dataUsageRepository ?? defaultDataUsageRepository,
            networkDataRepository: networkDataRepository ?? MockNetworkDataRepository(),
            setupValues: setupValues
        )
    }
    
    // MARK: - Mobile Data
    func test_refresh_used_data_today_no_total_used_data() throws {
        // (1) Given
        let totalUsedData = 100.0
        // (2) When
        appViewModel.refreshUsedDataToday(totalUsedData)
        // (3) Then
        let dateToday = appViewModel.todaysData.date
        let dailyUsedDataToday = appViewModel.todaysData.dailyUsedData
        let totalUsedDataToday = appViewModel.todaysData.totalUsedData
        XCTAssertNotNil(dateToday)
        XCTAssertTrue(dateToday!.isToday())
        XCTAssertEqual(dailyUsedDataToday, 0)
        XCTAssertEqual(totalUsedDataToday, 100.0)
    }
    
    func test_refresh_used_data_today_has_total_used_data() throws {
        // (1) Given
        let totalUsedData = 200.0
        let todaysData = appViewModel.todaysData
        todaysData.totalUsedData = 100.0
        todaysData.hasLastTotal = true
        // (2) When
        appViewModel.dataUsageRepository.updateData(item: todaysData)
        appViewModel.refreshUsedDataToday(totalUsedData)
        // (3) Then
        let dateToday = appViewModel.todaysData.date
        let dailyUsedDataToday = appViewModel.todaysData.dailyUsedData
        let totalUsedDataToday = appViewModel.todaysData.totalUsedData
        XCTAssertNotNil(dateToday)
        XCTAssertTrue(dateToday!.isToday())
        XCTAssertEqual(dailyUsedDataToday, 100.0)
        XCTAssertEqual(totalUsedDataToday, 200.0)
    }
        
    // MARK: - Edit Data Plan
    /// Period
    func test_did_tap_period() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapPeriod()
        // (3) Then
        XCTAssertTrue(appViewModel.isBlurShown)
        XCTAssertTrue(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .dataPlan)
    }
    
    func test_did_tap_period_then_save() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.didTapPeriod()
        appViewModel.startDateValue = startDate
        appViewModel.endDateValue = endDate
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .dataPlan)
        XCTAssertEqual(appViewModel.startDate, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(appViewModel.endDate, "2022-10-30T00:00:00+00:00".toDate())
    }
    
    func test_did_tap_start_period() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapStartPeriod()
        // (3) Then
        XCTAssertFalse(appViewModel.isEndDatePickerShown)
        XCTAssertTrue(appViewModel.isStartDatePickerShown)
    }
    
    func test_did_tap_end_period() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapEndPeriod()
        // (3) Then
        XCTAssertFalse(appViewModel.isStartDatePickerShown)
        XCTAssertTrue(appViewModel.isEndDatePickerShown)
    }
    
    func test_did_tap_done_selecting_start_date() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.didTapStartPeriod()
        appViewModel.startDateValue = startDate
        appViewModel.didTapDone()
        // (3) Then
        XCTAssertFalse(appViewModel.isStartDatePickerShown)
        XCTAssertEqual(appViewModel.startDateValue, "2022-10-01T00:00:00+00:00".toDate())
    }
    
    func test_did_tap_done_selecting_end_date() throws {
        // (1) Given
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.didTapEndPeriod()
        appViewModel.endDateValue = endDate
        appViewModel.didTapDone()
        // (3) Then
        XCTAssertFalse(appViewModel.isEndDatePickerShown)
        XCTAssertEqual(appViewModel.endDateValue, "2022-10-30T00:00:00+00:00".toDate())
    }
    
    func test_update_plan_period() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.isPeriodAuto = true
        appViewModel.startDate = startDate
        appViewModel.endDate = endDate
        appViewModel.updatePlanPeriod()
        // (3) Then
        XCTAssertEqual(appViewModel.startDate, "2022-10-31T00:00:00+00:00".toDate())
        XCTAssertEqual(appViewModel.endDate, "2022-11-29T00:00:00+00:00".toDate())
    }
    
    func test_update_plan_period_is_off() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.isPeriodAuto = false
        appViewModel.startDate = startDate
        appViewModel.endDate = endDate
        appViewModel.updatePlanPeriod()
        // (3) Then
        XCTAssertEqual(appViewModel.startDate, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(appViewModel.endDate, "2022-10-30T00:00:00+00:00".toDate())
    }
        
    /// Data Amount
    func test_did_tap_amount() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapAmount()
        // (3) Then
        XCTAssertTrue(appViewModel.isBlurShown)
        XCTAssertTrue(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .data)
    }
    
    func test_did_tap_amount_then_save() throws {
        // (1) Given
        let dataAmount = "20.0"
        // (2) When
        appViewModel.didTapAmount()
        appViewModel.dataValue = "\(dataAmount)"
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .data)
        XCTAssertEqual(appViewModel.dataAmount, 20.0)
    }
    
    func test_did_tap_plus_for_data_amount() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.didChangePlusStepperValue(value: value, type: .data)
        // (3) Then
        XCTAssertEqual(appViewModel.dataPlusStepperValue, 0.1)
    }
    
    func test_did_tap_minus_for_data_amount() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.didChangeMinusStepperValue(value: value, type: .data)
        // (3) Then
        XCTAssertEqual(appViewModel.dataMinusStepperValue, 0.1)
    }
    
    // MARK: - Edit Data Limit
    func test_did_tap_limit_plan() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapLimit()
        // (3) Then
        XCTAssertTrue(appViewModel.isBlurShown)
        XCTAssertTrue(appViewModel.isDataLimitEditing)
    }
    
    func test_did_tap_limit_plan_then_save() throws {
        // (1) Given
        let dataPlanLimit = "18.0"
        // (2) When
        appViewModel.didTapLimit()
        appViewModel.dataLimitValue = "\(dataPlanLimit)"
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataLimitEditing)
        XCTAssertEqual(appViewModel.dataLimit, 18.0)
    }
    
    func test_did_tap_limit_daily() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapLimitPerDay()
        // (3) Then
        XCTAssertTrue(appViewModel.isBlurShown)
        XCTAssertTrue(appViewModel.isDataLimitPerDayEditing)
    }
    
    func test_did_tap_limit_daily_then_save() throws {
        // (1) Given
        let dataDailyLimit = "0.5"
        // (2) When
        appViewModel.didTapLimitPerDay()
        appViewModel.dataLimitPerDayValue = "\(dataDailyLimit)"
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataLimitPerDayEditing)
        XCTAssertEqual(appViewModel.dataLimitPerDay, 0.5)
    }
        
    func test_did_tap_plus_for_daily_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.didChangePlusStepperValue(value: value, type: .dailyLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitPerDayPlusStepperValue, 0.1)
    }
    
    func test_did_tap_minus_for_daily_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.didChangeMinusStepperValue(value: value, type: .dailyLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitPerDayMinusStepperValue, 0.1)
    }
    
    func test_did_tap_plus_for_total_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.didChangePlusStepperValue(value: value, type: .planLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitPlusStepperValue, 0.1)
    }
    
    func test_did_tap_minus_for_total_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.didChangeMinusStepperValue(value: value, type: .planLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitMinusStepperValue, 0.1)
    }
    
    // MARK: - History
    func test_tap_history_daily_selected() throws {
        // (1) Given
        appViewModel.usageType = .daily
        // (2) When
        appViewModel.didTapOpenHistory()
        // (3) Then
        XCTAssertTrue(appViewModel.isBlurShown)
        XCTAssertTrue(appViewModel.isHistoryShown)
    }
    
    func test_tap_history_plan_selected() throws {
        // (1) Given
        appViewModel.usageType = .plan
        // (2) When
        appViewModel.didTapOpenHistory()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isHistoryShown)
    }
    
    func test_close_history() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapCloseHistory()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isHistoryShown)
    }
    
    // MARK: Data Error
    func test_date_error() throws {
        // (1) Given
        let error = DatabaseError.loadingContainer()
        // (2) When
        appViewModel.observeDataErrors()
        appViewModel.dataError = error
        // (3) Then
        XCTAssertEqual(appViewModel.dataError, .loadingContainer())
    }
}


