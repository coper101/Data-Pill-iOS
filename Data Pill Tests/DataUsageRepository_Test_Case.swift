//
//  DataUsageRepository_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 19/10/22.
//

import XCTest
@testable import Data_Pill
import CoreData

final class DataUsageRepository_Test_Case: XCTestCase {
    
    var repository: DataUsageRepositoryProtocol!
    var mockErrorRepository: DataUsageRepositoryProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let database = InMemoryLocalDatabase(
            container: .dataUsage,
            entity: .data
        )
        repository = DataUsageRepository(database: database)
        mockErrorRepository = MockErrorDataUsageRepository(database: database)
    }

    override func tearDownWithError() throws {
        repository = nil
        mockErrorRepository = nil
    }
    
    // MARK: - todaysData()
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
        XCTAssertEqual(todaysData?.date, Calendar.current.startOfDay(for: .init()))
        XCTAssertEqual(todaysData?.totalUsedData, 0)
        XCTAssertEqual(todaysData?.dailyUsedData, 0)
        XCTAssertEqual(todaysData?.hasLastTotal, false)
    }
    
    // MARK: - getDataWithHasTotal()
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
        XCTAssertEqual(dataWithHasTotal?.hasLastTotal, true)
        XCTAssertEqual(
            dataWithHasTotal?.date,
            "2022-10-02T00:00:00+00:00".toDate()
        )
    }
    
    func test_data_with_has_total_none() throws {
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
    
    // MARK: - getThisWeeksData()
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
    
    // MARK: - getTotalUsedData()
    func test_total_used_date() throws {
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
    
    func test_total_used_date_zero() throws {
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
    
    // MARK: - Operation Errors
    func test_add_data_has_error() throws {
        // (1) Given
        // (2) When
        mockErrorRepository.addData(
            date: .init(),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false
        )
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.adding("Adding Error")
        )
        try test_data_error_is_empty()
    }
    
    func test_get_all_data_has_error() throws {
        // (1) Given
        // (2) When
        let allData = mockErrorRepository.getAllData()
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.gettingAll("Get All Error")
        )
        // (3) Then
        XCTAssertEqual(allData, [])
        try test_data_error_is_empty()
    }
    
    func test_get_update_data_has_error() throws {
        // (1) Given
        // (2) When
        mockErrorRepository.updateData(
            item: Data(context: mockErrorRepository.database.context)
        )
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.updating("Update Error")
        )
        try test_data_error_is_empty()
    }
    
    func test_get_remove_data_has_error() throws {
        // (1) Given
        // (2) When
        mockErrorRepository.removeData(
            item: Data(context: mockErrorRepository.database.context)
        )
        // (3) Then
        XCTAssertEqual(
            mockErrorRepository.dataError,
            DatabaseError.removing("Remove Error")
        )
        try test_data_error_is_empty()
    }

    func test_data_error_is_empty() throws {
        mockErrorRepository.clearDataError()
        XCTAssertNil(mockErrorRepository.dataError)
    }
}
