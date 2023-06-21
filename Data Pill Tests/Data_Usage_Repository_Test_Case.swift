//
//  Data_Usage_Repository_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 19/10/22.
//

import XCTest
@testable import Data_Pill
import CoreData

final class Data_Usage_Repository_Test_Case: XCTestCase {
    
    var repository: DataUsageRepositoryProtocol!
    var mockErrorRepository: DataUsageRepositoryProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
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
    
    // MARK: - Operations
    
    // MARK: [1] Data
    func test_add_data() throws {
        // (1) Given
        let date = "2022-10-01T00:00:00+00:00".toDate()
        let totalUsedData = 0.0
        let dailyUsedData = 0.0
        let hasLastTotal = false
        // (2) When
        repository.addData(
            date: date,
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: hasLastTotal
        )
        // (3) Then
        let allData = repository.getAllData()
        let theData = allData.first
        XCTAssertNotNil(theData)
        XCTAssertEqual(theData!.date, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(theData!.totalUsedData, 0)
        XCTAssertEqual(theData!.dailyUsedData, 0)
        XCTAssertEqual(theData!.hasLastTotal, false)
    }
    
    func test_update_data() throws {
        // (1) Given
        let date = "2022-10-02T00:00:00+00:00".toDate()
        let totalUsedData = 50.0
        let dailyUsedData = 2.0
        let hasLastTotal = true
        
        repository.addData(
            date: "2022-10-01T00:00:00+00:00".toDate(),
            totalUsedData: 0.0,
            dailyUsedData: 0.0,
            hasLastTotal: false
        )
        let data = repository.getAllData().first
        XCTAssertNotNil(data)
        data!.date = date
        data!.totalUsedData = totalUsedData
        data!.dailyUsedData = dailyUsedData
        data!.hasLastTotal = hasLastTotal
        
        // (2) When
        repository.updateData(data!)
        
        // (3) Then
        let updatedData = repository.getAllData().first
        XCTAssertNotNil(updatedData)
        XCTAssertEqual(updatedData!.date, "2022-10-02T00:00:00+00:00".toDate())
        XCTAssertEqual(updatedData!.totalUsedData, 50)
        XCTAssertEqual(updatedData!.dailyUsedData, 2)
        XCTAssertEqual(updatedData!.hasLastTotal, true)
    }
    
    func test_update_bulk_data_are_synced_and_synced_data() throws {
        // (1) Given
        let date1 = "2022-10-01T00:00:00+00:00".toDate()
        let date2 = "2022-10-02T00:00:00+00:00".toDate()
        
        repository.addData(
            date: date1,
            totalUsedData: 1_000,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        repository.addData(
            date: date2,
            totalUsedData: 1_000,
            dailyUsedData: 100,
            hasLastTotal: true
        )
                
        let remoteData1 = RemoteData(date: date1, dailyUsedData: 100)
        let remoteData2 = RemoteData(date: date2, dailyUsedData: 100)
        
        // (2) When
        let _ = repository.updateData([remoteData1, remoteData2])
        
        // (3) Then
        let allData = repository.getAllData()
        
        XCTAssertEqual(allData.count, 2)
        
        let data1 = try XCTUnwrap(allData[0])
        let data2 = try XCTUnwrap(allData[1])
        
        XCTAssertTrue(data1.isSyncedToRemote)
        XCTAssertTrue(data2.isSyncedToRemote)
    }
    
    func test_get_all_data_with_data() throws {
        // (1) Given
        repository.addData(
            date:  "2022-10-01T00:00:00+00:00".toDate(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false
        )
        // (2) When
        let allData = repository.getAllData()
        let data = allData.first
        // (3) Then
        XCTAssertNotEqual(allData, [])
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.date, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(data!.totalUsedData, 0)
        XCTAssertEqual(data!.dailyUsedData, 0)
        XCTAssertEqual(data!.hasLastTotal, false)
    }
    
    func test_get_all_data_empty() throws {
        // (1) Given
        // (2) When
        let allData = repository.getAllData()
        // (3) Then
        XCTAssertEqual(allData, [])
    }
    
    func test_get_todays_data_exists() throws {
        // (1) Given
        repository.addData(
            date: Calendar.current.startOfDay(for: .init()),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false
        )
        // (2) When
        let todaysData = repository.getTodaysData()
        // (3) Then
        XCTAssertNotNil(todaysData)
        XCTAssertEqual(todaysData!.date, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(todaysData!.totalUsedData, 0)
        XCTAssertEqual(todaysData!.dailyUsedData, 0)
        XCTAssertEqual(todaysData!.hasLastTotal, false)
    }
    
    func test_get_todays_data_empty() throws {
        // (1) Given
        // (2) When
        let todaysData = repository.getTodaysData()
        // (3) Then
        XCTAssertNil(todaysData)
    }
    
    func test_data_with_has_total() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: false
        )
        
        // (2) When
        let dataWithHasTotal = repository.getDataWithHasTotal()

        // (3) Then
        XCTAssertNotNil(dataWithHasTotal)
        XCTAssertEqual(dataWithHasTotal!.date, "2022-10-02T00:00:00+00:00".toDate())
        XCTAssertEqual(dataWithHasTotal!.totalUsedData, 100)
        XCTAssertEqual(dataWithHasTotal!.dailyUsedData, 100)
        XCTAssertEqual(dataWithHasTotal!.hasLastTotal, true)
    }
    
    func test_data_with_has_total_empty() throws {
        // (1) Given
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: false
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
            hasLastTotal: true
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
            hasLastTotal: true
        )
        /// Sunday
        repository.addData(
            date: "2022-10-02T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
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
            hasLastTotal: true
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
            hasLastTotal: true
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Wednesday
        repository.addData(
            date: "2022-10-05T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Thursday
        repository.addData(
            date: "2022-10-06T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Friday
        repository.addData(
            date: "2022-10-07T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
        )
        /// Saturday
        repository.addData(
            date: "2022-10-08T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 100,
            hasLastTotal: true
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
            hasLastTotal: true
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 400.2,
            hasLastTotal: true
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 100,
            dailyUsedData: 200.3,
            hasLastTotal: true
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
            hasLastTotal: true
        )
        /// Monday
        repository.addData(
            date: "2022-10-03T00:00:00+00:00".toDate(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true
        )
        /// Tuesday
        repository.addData(
            date: "2022-10-04T00:00:00+00:00".toDate(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true
        )
        
        // (2) When
        let totalUsedData = repository.getTotalUsedData(
            from: "2022-10-02T00:00:00+00:00".toDate(),
            to: "2022-10-04T00:00:00+00:00".toDate()
        )
        
        // (3) Then
        XCTAssertEqual(totalUsedData, 0)
    }
    
    // MARK: [2] Plan
    func test_get_plan() throws {
        // (1) Given
        // (2) When
        let plan = repository.getPlan()
        // (3) Then
        XCTAssertNotNil(plan)
        XCTAssertEqual(plan!.startDate, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(plan!.endDate, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(plan!.dataAmount, 0.0)
        XCTAssertEqual(plan!.dailyLimit, 0.0)
        XCTAssertEqual(plan!.planLimit, 0.0)
    }
    
    func test_add_plan() throws {
        // (1) Given
        let plan = createFakePlan(
            startDate: "2022-10-02T00:00:00+00:00".toDate(),
            endDate: "2022-10-02T00:00:00+00:00".toDate(),
            dataAmount: 10,
            dailyLimit: 1,
            planLimit: 9
        )
        // (2) When
        repository.addPlan(
            startDate: plan.startDate!,
            endDate: plan.endDate!,
            dataAmount: plan.dataAmount,
            dailyLimit: plan.dailyLimit,
            planLimit: plan.planLimit
        )
        // (3) Then
        let thePlan = repository.getPlan()
        XCTAssertNotNil(thePlan)
        XCTAssertEqual(thePlan!.startDate, "2022-10-02T00:00:00+00:00".toDate())
        XCTAssertEqual(thePlan!.endDate, "2022-10-02T00:00:00+00:00".toDate())
        XCTAssertEqual(thePlan!.dataAmount, 10.0)
        XCTAssertEqual(thePlan!.dailyLimit, 1.0)
        XCTAssertEqual(thePlan!.planLimit, 9.0)
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
        
    // MARK: - Operation Errors
    
    // MARK: [1] Data
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
            hasLastTotal: hasLastTotal
        )
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.adding("Adding Data Error")
        )
        try test_data_error_is_empty()
    }
    
    func test_get_update_data_has_error() throws {
        // (1) Given
        // (2) When
        mockErrorRepository.updateData(
            Data(context: mockErrorRepository.database.context)
        )
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.updatingData("Updating Data Error")
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
    
    // MARK: [2] Plan
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
    
    // MARK: [3] Error
    func test_data_error_is_empty() throws {
        mockErrorRepository.clearDataError()
        XCTAssertNil(mockErrorRepository.dataError)
    }
}
