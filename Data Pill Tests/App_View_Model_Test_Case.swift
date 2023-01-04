//
//  App_View_Model_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 6/11/22.
//

import XCTest
@testable import Data_Pill
import CoreData

final class App_View_Model_Test_Case: XCTestCase {
    
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
            database: InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        )
        return .init(
            appDataRepository: appDataRepository ?? MockAppDataRepository(),
            dataUsageRepository: dataUsageRepository ?? defaultDataUsageRepository,
            networkDataRepository: networkDataRepository ?? MockNetworkDataRepository(),
            setupValues: setupValues
        )
    }
    
    // MARK: - Mobile Data
    func test_refresh_used_data_today_with_empty_total_used_data() throws {
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
        XCTAssertEqual(totalUsedDataToday, 100)
    }
    
    func test_refresh_used_data_today_with_has_total_used_data() throws {
        // (1) Given
        let newTotalUsedData = 200.0
        let totalUsedData = 100.0
        
        let todaysData = appViewModel.todaysData
        todaysData.totalUsedData = totalUsedData
        todaysData.hasLastTotal = true
        // (2) When
        appViewModel.dataUsageRepository.updateData(todaysData)
        appViewModel.refreshUsedDataToday(newTotalUsedData)
        // (3) Then
        let dateToday = appViewModel.todaysData.date
        let dailyUsedDataToday = appViewModel.todaysData.dailyUsedData
        let totalUsedDataToday = appViewModel.todaysData.totalUsedData
        XCTAssertNotNil(dateToday)
        XCTAssertTrue(dateToday!.isToday())
        XCTAssertEqual(dailyUsedDataToday, 100)
        XCTAssertEqual(totalUsedDataToday, 200)
    }
    
    func test_refresh_used_data_today_with_has_total_used_data_same() throws {
        // (1) Given
        let newTotalUsedData = 100.0
        let totalUsedData = 100.0

        let todaysData = appViewModel.todaysData
        todaysData.totalUsedData = totalUsedData
        todaysData.hasLastTotal = true
        // (2) When
        appViewModel.dataUsageRepository.updateData(todaysData)
        appViewModel.refreshUsedDataToday(newTotalUsedData)
        // (3) Then
        let dateToday = appViewModel.todaysData.date
        let dailyUsedDataToday = appViewModel.todaysData.dailyUsedData
        let totalUsedDataToday = appViewModel.todaysData.totalUsedData
        XCTAssertNotNil(dateToday)
        XCTAssertTrue(dateToday!.isToday())
        XCTAssertEqual(dailyUsedDataToday, 0)
        XCTAssertEqual(totalUsedDataToday, 100)
    }
    
    // MARK: - Data Plan
    func test_did_tap_start_plan() throws {
        // (1) Given
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didTapStartPlan()
        // (3) Then
        XCTAssertTrue(appViewModel.isPlanActive)
        XCTAssertFalse(appViewModel.isGuideShown)
        XCTAssertTrue(appViewModel.wasGuideShown)
    }
    
    func test_did_tap_start_non_plan() throws {
        // (1) Given
        // (2) When
        appViewModel.republishAppData()
        appViewModel.observePlanSettings()
        appViewModel.didTapStartNonPlan()
        // (3) Then
        XCTAssertFalse(appViewModel.isPlanActive)
        XCTAssertFalse(appViewModel.isGuideShown)
        XCTAssertTrue(appViewModel.wasGuideShown)
        XCTAssertEqual(appViewModel.usageType, .daily)
        XCTAssertFalse(appViewModel.isPeriodAuto)
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
    
    func test_did_tap_start_period() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapStartPeriod()
        // (3) Then
        XCTAssertFalse(appViewModel.isEndDatePickerShown)
        XCTAssertTrue(appViewModel.isStartDatePickerShown)
        XCTAssertEqual(appViewModel.buttonType, .done)
    }
    
    func test_did_tap_end_period() throws {
        // (1) Given
        // (2) When
        appViewModel.didTapEndPeriod()
        // (3) Then
        XCTAssertFalse(appViewModel.isStartDatePickerShown)
        XCTAssertTrue(appViewModel.isEndDatePickerShown)
        XCTAssertEqual(appViewModel.buttonType, .done)
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
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertEqual(appViewModel.buttonType, .save)
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
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertEqual(appViewModel.buttonType, .save)
        XCTAssertEqual(appViewModel.endDateValue, "2022-10-30T00:00:00+00:00".toDate())
    }
    
    func test_did_tap_save_plan_period_is_tappable() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.startDateValue = startDate
        appViewModel.endDateValue = endDate
        // (3) Then
        XCTAssertEqual(appViewModel.startDateValue, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(appViewModel.endDateValue, "2022-10-30T00:00:00+00:00".toDate())
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertEqual(appViewModel.buttonType, .save)
        XCTAssertFalse(appViewModel.buttonDisabled)
    }
    
    func test_did_tap_save_plan_period_is_disabled() throws {
        // (1) Given
        let startDate = "2022-10-30T00:00:00+00:00".toDate()
        let endDate = "2022-10-01T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.startDateValue = startDate
        appViewModel.endDateValue = endDate
        // (3) Then
        XCTAssertEqual(appViewModel.startDateValue, "2022-10-30T00:00:00+00:00".toDate())
        XCTAssertEqual(appViewModel.endDateValue, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertEqual(appViewModel.buttonType, .save)
        XCTAssertTrue(appViewModel.buttonDisabled)
    }
    
    func test_did_tap_period_then_save() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.didTapPeriod()
        appViewModel.startDateValue = startDate
        appViewModel.endDateValue = endDate
        appViewModel.republishDataUsage()
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .dataPlan)
        XCTAssertEqual(appViewModel.startDate, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(appViewModel.endDate, "2022-10-30T00:00:00+00:00".toDate())
    }
    
    func test_update_plan_period() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        // (2) When
        appViewModel.republishDataUsage()
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
        let dataAmount = 20.0
        // (2) When
        appViewModel.republishDataUsage()
        appViewModel.observeEditPlan()
        appViewModel.didTapAmount()
        appViewModel.dataValue = "\(dataAmount)"
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .data)
        XCTAssertEqual(appViewModel.dataAmount, 20)
    }
    
    func test_did_tap_amount_then_save_expects_adjusted_limits() throws {
        // (1) Given
        let initialDataAmount = 20.0
        let dataAmount = 0.5
        let dailyLimit = 1.0
        let planLimit = 19
        
        // (2) When
        appViewModel.republishDataUsage()
        appViewModel.observeEditPlan()
        
        appViewModel.didTapAmount()
        appViewModel.dataValue = "\(initialDataAmount)"
        appViewModel.didTapSave()
        
        appViewModel.didTapLimitPerDay()
        appViewModel.dataLimitPerDayValue = "\(dailyLimit)"
        appViewModel.didTapSave()

        appViewModel.didTapLimit()
        appViewModel.dataLimitValue = "\(planLimit)"
        appViewModel.didTapSave()
        
        appViewModel.didTapAmount()
        appViewModel.dataValue = "\(dataAmount)"
        appViewModel.didTapSave()
        
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataPlanEditing)
        XCTAssertFalse(appViewModel.isDataLimitPerDayEditing)
        XCTAssertFalse(appViewModel.isDataLimitPerDayEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .data)
        XCTAssertEqual(appViewModel.dataAmount, 0.5)
        XCTAssertEqual(appViewModel.dataValue, "0.5")
        XCTAssertEqual(appViewModel.dataLimitPerDay, 0.5)
        XCTAssertEqual(appViewModel.dataLimitPerDayValue, "0.5")
        XCTAssertEqual(appViewModel.dataLimit, 0.5)
        XCTAssertEqual(appViewModel.dataLimitValue, "0.5")
    }
    
    func test_did_tap_plus_for_data_amount() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didChangePlusStepperValue(value: value, type: .data)
        // (3) Then
        XCTAssertEqual(appViewModel.dataPlusStepperValue, 0.1)
    }
    
    func test_did_tap_minus_for_data_amount() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.republishAppData()
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
        let dataPlanLimit = 18.0
        // (2) When
        appViewModel.didTapLimit()
        appViewModel.dataLimitValue = "\(dataPlanLimit)"
        appViewModel.republishDataUsage()
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataLimitEditing)
        XCTAssertEqual(appViewModel.dataLimit, 18)
    }
    
    func test_did_tap_limit_plan_exceeds_will_disable_save() throws {
        // (1) Given
        let dataAmount = 5.0
        let dataPlanLimit = 5.1
        // (2) When: user edits the value from the Text Field
        appViewModel.dataAmount = dataAmount
        appViewModel.didTapLimit()
        appViewModel.dataLimitValue = "\(dataPlanLimit)"
        // (3) Then
        XCTAssertEqual(appViewModel.dataAmount, 5.0)
        XCTAssertEqual(appViewModel.dataLimitValue, "5.1")
        XCTAssertTrue(appViewModel.buttonDisabledPlanLimit)
    }
    
    func test_did_tap_limit_plan_below_min_will_disable_save() throws {
        // (1) Given
        let dataAmount = 5.0
        let dataPlanLimit = -0.1
        // (2) When: user edits the value from the Text Field (no option to tap negative)
        appViewModel.dataAmount = dataAmount
        appViewModel.didTapLimit()
        appViewModel.dataLimitValue = "\(dataPlanLimit)"
        // (3) Then
        XCTAssertEqual(appViewModel.dataAmount, 5.0)
        XCTAssertEqual(appViewModel.dataLimitValue, "-0.1")
        XCTAssertTrue(appViewModel.buttonDisabledPlanLimit)
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
        let dataDailyLimit = 0.5
        // (2) When
        appViewModel.didTapLimitPerDay()
        appViewModel.dataLimitPerDayValue = "\(dataDailyLimit)"
        appViewModel.republishDataUsage()
        appViewModel.observeEditPlan()
        appViewModel.didTapSave()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataLimitPerDayEditing)
        XCTAssertEqual(appViewModel.dataLimitPerDay, 0.5)
    }
    
    func test_did_tap_limit_daily_exceeds_will_disable_save() throws {
        // (1) Given
        let dataAmount = 5.0
        let dataDailyLimit = 5.1
        // (2) When: user edits the value from the Text Field (no option to tap negative)
        appViewModel.dataAmount = dataAmount
        appViewModel.didTapLimitPerDay()
        appViewModel.dataLimitPerDayValue = "\(dataDailyLimit)"
        // (3) Then
        XCTAssertEqual(appViewModel.dataAmount, 5.0)
        XCTAssertEqual(appViewModel.dataLimitPerDayValue, "5.1")
        XCTAssertTrue(appViewModel.buttonDisabledDailyLimit)
    }
    
    func test_did_tap_limit_daily_below_min_will_disable_save() throws {
        // (1) Given
        let dataAmount = 5.0
        let dataDailyLimit = -0.1
        // (2) When: user edits the value from the Text Field
        appViewModel.dataAmount = dataAmount
        appViewModel.didTapLimitPerDay()
        appViewModel.dataLimitPerDayValue = "\(dataDailyLimit)"
        // (3) Then
        XCTAssertEqual(appViewModel.dataAmount, 5.0)
        XCTAssertEqual(appViewModel.dataLimitPerDayValue, "-0.1")
        XCTAssertTrue(appViewModel.buttonDisabledDailyLimit)
    }
        
    func test_did_tap_plus_for_daily_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didChangePlusStepperValue(value: value, type: .dailyLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitPerDayPlusStepperValue, 0.1)
    }
    
    func test_did_tap_minus_for_daily_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didChangeMinusStepperValue(value: value, type: .dailyLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitPerDayMinusStepperValue, 0.1)
    }
    
    func test_did_tap_plus_for_total_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didChangePlusStepperValue(value: value, type: .planLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitPlusStepperValue, 0.1)
    }
    
    func test_did_tap_minus_for_total_limit() throws {
        // (1) Given
        let value = 0.1
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didChangeMinusStepperValue(value: value, type: .planLimit)
        // (3) Then
        XCTAssertEqual(appViewModel.dataLimitMinusStepperValue, 0.1)
    }
    
    // MARK: - Operations
    func test_did_tap_outside_on_edit_data_amount() throws {
        // (1) Given
        let dataAmount = 20.0
        // (2) When
        appViewModel.observeEditPlan()
        appViewModel.didTapAmount()
        appViewModel.dataValue = "\(dataAmount)"
        appViewModel.didTapOutside()
        // (3) Then
        XCTAssertFalse(appViewModel.isBlurShown)
        XCTAssertFalse(appViewModel.isDataPlanEditing)
        XCTAssertEqual(appViewModel.editDataPlanType, .data)
        XCTAssertEqual(appViewModel.dataAmount, 0)
        XCTAssertEqual(appViewModel.isTappedOutside, false)
    }
    
    func test_did_long_pressed_outside() throws {
        // (1) Given
        // (2) When
        appViewModel.didLongPressedOutside()
        // (3) Then
        XCTAssertEqual(appViewModel.isLongPressedOutside, true)
    }
    
    func test_did_released_long_pressed() throws {
        // (1) Given
        // (2) When
        appViewModel.didReleasedLongPressed()
        // (3) Then
        XCTAssertEqual(appViewModel.isLongPressedOutside, false)
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
    
    // MARK: - Deep Link
    func test_did_open_daily_url() throws {
        // (1) Given
        let url = URL(string: "datapill:///daily")!
        // (2) When
        appViewModel.didOpenURL(url: url)
        // (3) Then
        XCTAssertEqual(appViewModel.usageType, ToggleItem.daily)
    }
    
    func test_did_open_plan_url() throws {
        // (1) Given
        let url = URL(string: "datapill:///plan")!
        // (2) When
        appViewModel.republishAppData()
        appViewModel.didOpenURL(url: url)
        // (3) Then
        XCTAssertEqual(appViewModel.usageType, ToggleItem.plan)
    }
}


