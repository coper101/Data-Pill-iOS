//
//  Data_Usage_Repository_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 19/10/22.
//

@testable import Data_Pill
import XCTest
import CoreData

final class Data_Usage_Repository_Tests: XCTestCase {
    
    private var repository: DataUsageRepositoryProtocol!
    private var mockErrorRepository: DataUsageRepositoryProtocol!

    override func setUpWithError() throws {
        continueAfterFailure = false
        let database = InMemoryLocalDatabase(
            container: .dataUsage,
            appGroup: nil
        )
        repository = DataUsageRepository(database: database)
        mockErrorRepository = MockErrorDataUsageRepository(database: database)
    }

    override func tearDownWithError() throws {
        repository = nil
        mockErrorRepository = nil
    }
        
    // MARK: - Data
    func test_add_data_yesterday() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let date = TestData.createDate(offset: -1, from: todaysDate)
        let totalUsedData = 0.0
        let dailyUsedData = 0.0
        let hasLastTotal = false
        let isSyncedToRemote = false
        let lastSyncedDateToRemote: Date? = nil
        
        // (2) When
        repository.addData(
            date: date,
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: hasLastTotal,
            isSyncedToRemote: isSyncedToRemote,
            lastSyncedToRemoteDate: lastSyncedDateToRemote
        )
        
        // (3) Then
        let allData = repository.getAllData()
        XCTAssertEqual(allData.count, 2)
        
        let data = try XCTUnwrap(allData.first { $0.date == date })
        XCTAssertEqual(data.date, date)
        XCTAssertEqual(data.totalUsedData, totalUsedData)
        XCTAssertEqual(data.dailyUsedData, dailyUsedData)
        XCTAssertEqual(data.hasLastTotal, hasLastTotal)
        XCTAssertEqual(data.isSyncedToRemote, isSyncedToRemote)
        XCTAssertEqual(data.lastSyncedToRemoteDate, lastSyncedDateToRemote)
    }
    
    func test_update_todays_data() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let totalUsedData = 50.0
        let dailyUsedData = 2.0
        let hasLastTotal = true
        let isSyncedToRemote = true
        let lastSyncedDateToRemote: Date? = todaysDate
        
        // (2) When
        repository.updateTodaysData(
            date: todaysDate,
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: hasLastTotal,
            isSyncedToRemote: isSyncedToRemote,
            lastSyncedToRemoteDate: lastSyncedDateToRemote
        )
        
        // (3)
        let todaysData = try XCTUnwrap(repository.getTodaysData())
        
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertEqual(todaysData.totalUsedData, totalUsedData)
        XCTAssertEqual(todaysData.dailyUsedData, dailyUsedData)
        XCTAssertEqual(todaysData.hasLastTotal, hasLastTotal)
        XCTAssertEqual(todaysData.isSyncedToRemote, isSyncedToRemote)
        XCTAssertEqual(todaysData.lastSyncedToRemoteDate, lastSyncedDateToRemote)
    }
    
    func test_get_all_data_empty_excluding_todays_data() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())

        // (2) When
        let allData = repository.getAllData()
            .filter { $0.date != todaysDate }
        
        // (3) Then
        XCTAssertTrue(allData.isEmpty)
    }
    
    func test_get_todays_data_exists() throws {
        // (1) Given
        // (2) When
        let todaysData = repository.getTodaysData()
        
        // (3) Then
        XCTAssertNotNil(todaysData)
    }
    
    func test_data_with_has_total() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: false,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let dataWithHasTotal = try XCTUnwrap(repository.getDataWithHasTotal())

        // (3) Then
        XCTAssertEqual(dataWithHasTotal.date, "2022-10-02T00:00:00+00:00".toDate())
        XCTAssertEqual(dataWithHasTotal.totalUsedData, 100)
        XCTAssertEqual(dataWithHasTotal.dailyUsedData, 100)
        XCTAssertEqual(dataWithHasTotal.hasLastTotal, true)
        XCTAssertEqual(dataWithHasTotal.isSyncedToRemote, false)
        XCTAssertEqual(dataWithHasTotal.lastSyncedToRemoteDate, nil)
    }
    
    func test_data_with_has_total_empty() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: false,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let dataWithHasTotal = repository.getDataWithHasTotal()

        // (3) Then
        XCTAssertNil(dataWithHasTotal)
    }
    
    func test_this_weeks_data_empty() throws {
        // (1) Given
        /// Saturday
        repository.addData(
            date: "2022-10-01T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let thisWeeksData = repository.getThisWeeksData(
            from: createFakeData(
                date: "2022-10-31T00:00:00+00:00".toDate()
            )
        )
        
        // (3) Then
        XCTAssertEqual(thisWeeksData.count, 0)
    }
    
    func test_this_weeks_data_from_saturday() throws {
        // (1) Given
        /// Saturday
        repository.addData(
            date: "2022-10-01T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let thisWeeksData = repository.getThisWeeksData(
            from: createFakeData(
                date: "2022-10-01T00:00:00+00:00".toDate()
            )
        )
        
        // (3) Then
        XCTAssertEqual(thisWeeksData.count, 1)
    }
    
    func test_this_weeks_data_from_sunday() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let thisWeeksData = repository.getThisWeeksData(
            from: createFakeData(
                date: "2022-10-02T00:00:00+00:00".toDate()
            )
        )

        // (3) Then
        XCTAssertEqual(thisWeeksData.count, 1)
    }
    
    func test_this_weeks_data_from_sunday_to_saturday() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Wednesday
        repository.addData(
            date: "2022-10-05T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Thursday
        repository.addData(
            date: "2022-10-06T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Friday
        repository.addData(
            date: "2022-10-07T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Saturday
        repository.addData(
            date: "2022-10-08T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let thisWeeksData = repository.getThisWeeksData(
            from: createFakeData(
                date: "2022-10-08T00:00:00+00:00".toDate()
            )
        )

        // (3) Then
        XCTAssertEqual(thisWeeksData.count, 7)
    }
    
    func test_total_used_data() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 300.1,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 400.2,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 200.3,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let totalUsedData = repository.getTotalUsedData(
            from: "2022-10-02T00:00:00+00:00".toDate(),
            to: "2022-10-04T00:00:00+00:00".toDate()
        )
        
        // (3) Then
        XCTAssertEqual(totalUsedData, 900.6, accuracy: 0.1)
    }
    
    func test_total_used_data_zero() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (2) When
        let totalUsedData = repository.getTotalUsedData(
            from: "2022-10-02T00:00:00+00:00".toDate(),
            to: "2022-10-04T00:00:00+00:00".toDate()
        )
        
        // (3) Then
        XCTAssertEqual(totalUsedData, 0)
    }
    
    // MARK: - Plan
    func test_get_plan_exists() throws {
        // (1) Given
        // (2) When
        let plan = try XCTUnwrap(repository.getPlan())

        // (3) Then
        XCTAssertEqual(plan.startDate, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(plan.endDate, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(plan.dataAmount, 0.0)
        XCTAssertEqual(plan.dailyLimit, 0.0)
        XCTAssertEqual(plan.planLimit, 0.0)
    }
    
    func test_update_plan() throws {
        // (1) Given
        let dataAmount = 10.0
        let dailyLimit = 1.0
        let planLimit = 9.0
        
        // (2) When
        repository.updatePlan(
            startDate: nil,
            endDate: nil,
            dataAmount: dataAmount,
            dailyLimit: dailyLimit,
            planLimit: planLimit,
            updateToLatestPlanAfterwards: true
        )
        
        // (3) Then
        let thePlan = repository.getPlan()
        XCTAssertNotNil(thePlan)
        XCTAssertEqual(thePlan!.startDate, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(thePlan!.endDate, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(thePlan!.dataAmount, 10.0)
        XCTAssertEqual(thePlan!.dailyLimit, 1.0)
        XCTAssertEqual(thePlan!.planLimit, 9.0)
    }
            
    // MARK: - Data Error
    func test_add_data_has_error() throws {
        // (1) Given
        let date = Date()
        let totalUsedData = 0.0
        let dailUsedData = 0.0
        let hasLastTotal = false
        
        // (2) When
        mockErrorRepository.addData(
            date: date,
            totalUsedData: totalUsedData,
            dailyUsedData: dailUsedData,
            hasLastTotal: hasLastTotal,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.adding("Adding Data Error")
        )
        try test_data_error_is_empty()
    }
    
    func test_update_today_data_has_error() throws {
        // (1) Given
        let date = Date()
        let totalUsedData = 0.0
        let dailUsedData = 0.0
        let hasLastTotal = false
        
        // (2) When
        mockErrorRepository.updateTodaysData(
            date: date,
            totalUsedData: totalUsedData,
            dailyUsedData: dailUsedData,
            hasLastTotal: hasLastTotal,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.updatingData("Updating Today's Data Error")
        )
        try test_data_error_is_empty()
    }
    
    func test_get_all_data_has_error() throws {
        // (1) Given
        // (2) When
        let allData = mockErrorRepository.getAllData()
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.gettingAll("Getting All Data Error")
        )
        XCTAssertEqual(allData, [])
        try test_data_error_is_empty()
    }
    
    func test_get_todays_data_has_error() throws {
        // (1) Given
        // (2) When
        let data = mockErrorRepository.getTodaysData()
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.gettingTodaysData("Get Today's Date Error")
        )
        XCTAssertNil(data)
        try test_data_error_is_empty()
    }
    
    func test_get_data_with_has_total_has_error() throws {
        // (1) Given
        // (2) When
        let data = mockErrorRepository.getDataWithHasTotal()
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.filteringData("Filtering Data Error")
        )
        XCTAssertNil(data)
        try test_data_error_is_empty()
    }
    
    func test_get_total_used_data_has_error() throws {
        // (1) Given
        // (2) When
        let totalUsedData = mockErrorRepository.getTotalUsedData(from: .init(), to: .init())
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.filteringData("Filtering Data Error")
        )
        XCTAssertEqual(totalUsedData, 0)
        try test_data_error_is_empty()
    }
    
    func test_get_this_weeks_data_has_error() throws {
        // (1) Given
        // (2) When
        let data = mockErrorRepository.getThisWeeksData(from: .init())
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.filteringData("Filtering Data Error")
        )
        XCTAssertEqual(data, [])
        try test_data_error_is_empty()
    }
    
    // MARK: - Plan Error
    func test_get_plan_has_error() throws {
        // (1) Given
        // (2) When
        let plan = mockErrorRepository.getPlan()
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.gettingPlan("Getting Plan Error")
        )
        XCTAssertNil(plan)
        try test_data_error_is_empty()
    }
    
    func test_add_plan_has_error() throws {
        // (1) Given
        // (2) When
        mockErrorRepository.addPlan(
            startDate: .init(),
            endDate: .init(),
            dataAmount: 0,
            dailyLimit: 0,
            planLimit: 0
        )
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.addingPlan("Adding Plan Error")
        )
        try test_data_error_is_empty()
    }
    
    func test_update_plan_has_error() throws {
        // (1) Given
        // (2) When
        mockErrorRepository.updatePlan(
            startDate: .init(),
            endDate: .init(),
            dataAmount: 0,
            dailyLimit: 0,
            planLimit: 0,
            updateToLatestPlanAfterwards: true
        )
        
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.updatingPlan("Updating Plan Error")
        )
        try test_data_error_is_empty()
    }
    
    // MARK: - Error
    func test_data_error_is_empty() throws {
        mockErrorRepository.clearDataError()
        XCTAssertNil(mockErrorRepository.dataError)
    }
}
