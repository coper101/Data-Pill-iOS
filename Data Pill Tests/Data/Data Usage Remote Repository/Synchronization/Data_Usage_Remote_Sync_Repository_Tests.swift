//
//  Data_Usage_Remote_Sync_Repository_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 26/3/23.
//

@testable import Data_Pill
import XCTest
import Combine
import CloudKit

final class Data_Usage_Remote_Sync_Repository_Tests: XCTestCase {
    
    private var localDatabase: Database!
    private var remoteDatabase: RemoteDatabase!
    private var repository: DataUsageRemoteRepository!

    override func setUpWithError() throws {
        remoteDatabase = MockRemoteDatabase()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
    }

    override func tearDownWithError() throws {
        localDatabase = nil
        remoteDatabase = nil
        repository = nil
    }
    
    func load_local_database() throws {
        localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)

        let loadContainer = self.expectation(description: "Load Container")
        
        localDatabase.loadContainer { _ in
        } onSuccess: {
            loadContainer.fulfill()
        }
        
        wait(for: [loadContainer], timeout: 2.0)
    }

    // MARK: Old Local Data
    func test_sync_more_than_one_old_local() throws {
        // (1) Given
        try load_local_database()
        
        let lastSyncedDate = Date()
         
        let data1 = Data(context: localDatabase.context)
        data1.date = Calendar.current.startOfDay(for: .init())
        data1.totalUsedData = 1500
        data1.dailyUsedData = 100
        data1.hasLastTotal = true
        data1.isSyncedToRemote = false
        
        let data2 = Data(context: localDatabase.context)
        data2.date = createDate(offset: -1)
        data2.totalUsedData = 1500
        data2.dailyUsedData = 100
        data2.hasLastTotal = true
        data1.isSyncedToRemote = false
        
        let data3 = Data(context: localDatabase.context)
        data3.date = createDate(offset: -2)
        data3.totalUsedData = 1500
        data3.dailyUsedData = 100
        data3.hasLastTotal = true
        data1.isSyncedToRemote = false
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let localData = [
            data1,
            data2,
            data3
        ]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then - excludes today's data
            XCTAssertTrue(areOldDataAdded)
            XCTAssertEqual(addedRemoteData.count, 2)
        }
    }
    
    func test_sync_zero_old_local_data_has_uploaded() throws {
        // (1) Given
        try load_local_database()
        
        let lastSyncedDate = Date()
         
        let data1 = Data(context: localDatabase.context)
        data1.date = Calendar.current.startOfDay(for: .init())
        data1.totalUsedData = 1500
        data1.dailyUsedData = 100
        data1.hasLastTotal = true
        data1.isSyncedToRemote = true
        
        let data2 = Data(context: localDatabase.context)
        data2.date = createDate(offset: -1)
        data2.totalUsedData = 1500
        data2.dailyUsedData = 100
        data2.hasLastTotal = true
        data2.isSyncedToRemote = true
        
        let data3 = Data(context: localDatabase.context)
        data3.date = createDate(offset: -2)
        data3.totalUsedData = 1500
        data3.dailyUsedData = 100
        data3.hasLastTotal = true
        data3.isSyncedToRemote = true
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let localData = [
            data1,
            data2,
            data3
        ]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then - excludes today's data
            XCTAssertFalse(areOldDataAdded)
            XCTAssertTrue(addedRemoteData.isEmpty)
        }
    }
    
    func test_sync_zero_old_local_data() throws {
        // (1) Given
        try load_local_database()

        let lastSyncedDate = Date()
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true

        let localData = [todaysData]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then
            XCTAssertFalse(areOldDataAdded)
            XCTAssertTrue(addedRemoteData.isEmpty)
        }
    }
    
    func test_sync_one_old_local_data_to_update_higher_than_remotes() throws {
        // (1) Given
        try load_local_database()

        let lastSyncedDate = "2023-06-20T00:00:00+00:00".toDate()
        
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = "2023-06-20T00:00:00+00:00".toDate()
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 200
        yesterdaysData.hasLastTotal = true
        yesterdaysData.lastSyncedToRemoteDate = "2023-06-20T00:00:01+00:00".toDate()
        yesterdaysData.isSyncedToRemote = true

        let localData = [todaysData, yesterdaysData]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then
            XCTAssertFalse(areOldDataAdded)
            XCTAssertTrue(areOldDataUpdated)
            XCTAssertEqual(addedRemoteData.count, 1)
        }
    }
    
    func test_sync_one_old_local_data_to_update_equal_to_remotes() throws {
        // (1) Given
        try load_local_database()

        let lastSyncedDate = "2023-06-20T00:00:00+00:00".toDate()

        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true

        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = "2023-06-20T00:00:00+00:00".toDate()
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100
        yesterdaysData.hasLastTotal = true
        yesterdaysData.lastSyncedToRemoteDate = "2023-06-20T00:00:00+00:00".toDate()
        yesterdaysData.isSyncedToRemote = true

        let localData = [todaysData, yesterdaysData]

        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in

            // (3) Then
            XCTAssertFalse(areOldDataAdded)
            XCTAssertFalse(areOldDataUpdated)
            XCTAssertTrue(addedRemoteData.isEmpty)
        }
    }
    
    func test_sync_one_old_local_data_to_update_is_lower_than_remotes() throws {
        // (1) Given
        try load_local_database()

        let lastSyncedDate = "2023-06-20T00:00:00+00:00".toDate()

        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true

        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = "2023-06-20T00:00:00+00:00".toDate()
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 50
        yesterdaysData.hasLastTotal = true
        yesterdaysData.lastSyncedToRemoteDate = "2023-06-20T00:00:00+00:00".toDate()
        yesterdaysData.isSyncedToRemote = true

        let localData = [todaysData, yesterdaysData]

        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in

            // (3) Then
            XCTAssertFalse(areOldDataAdded)
            XCTAssertFalse(areOldDataUpdated)
            XCTAssertTrue(addedRemoteData.isEmpty)
        }
    }
    
    // MARK: Old Remote Data
    
    // MARK: Today's Data
    func test_sync_todays_data_with_non_existent_data_from_remote() throws {
        // (1) Given
        try load_local_database()

        let isSyncedToRemote = false
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = false
    
        let _ = try? localDatabase.context.saveIfNeeded()
        
        // (2) When
        createExpectation(
            publisher: repository.syncTodaysData(todaysData, isSyncedToRemote: isSyncedToRemote),
            description: "Sync Today's Data"
        ) { isUploaded in
            
            // (3) Then
            XCTAssertTrue(isUploaded)
        }
    }
    
    func test_sync_todays_data_with_existing_data_from_remote_has_change_in_usage() throws {
        // (1) Given
        try load_local_database()
        
        remoteDatabase = MockRemoteDatabaseTodaysData()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)

        let isSyncedToRemote = true
        let todaysData = Data(context: localDatabase.context)
        
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = false
    
        let _ = try? localDatabase.context.saveIfNeeded()
        
        // (2) When
        createExpectation(
            publisher: repository.syncTodaysData(todaysData, isSyncedToRemote: isSyncedToRemote),
            description: "Sync Today's Data"
        ) { isUploaded in
            
            // (3) Then
            XCTAssertTrue(isUploaded)
        }
    }

    func test_sync_todays_data_with_existing_data_from_remote_has_no_change_in_usage() throws {
        // (1) Given
        try load_local_database()

        let isSyncedToRemote = true
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 0
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = false
    
        let _ = try? localDatabase.context.saveIfNeeded()
        
        // (2) When
        createExpectation(
            publisher: repository.syncTodaysData(todaysData, isSyncedToRemote: isSyncedToRemote),
            description: "Sync Today's Data"
        ) { isUploaded in
            
            // (3) Then
            XCTAssertFalse(isUploaded)
        }
    }

    // MARK: Plan
    func test_sync_plan_with_non_existent_plan_from_remote() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.syncPlan(
                startDate: .init(),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: .init())!,
                dataAmount: 17,
                dailyLimit: 0.5,
                planLimit: 16.7
            ),
            description: "Sync Plan"
        ) { isUploaded in
            
            // (3) Then
            XCTAssertTrue(isUploaded)
        }
    }
    
    func test_sync_plan_with_existing_plan_from_remote_has_changes() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.syncPlan(
                startDate: .init(),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: .init())!,
                dataAmount: 17,
                dailyLimit: 0.7,
                planLimit: 16.7
            ),
            description: "Sync Plan"
        ) { isUploaded in
            
            // (3) Then
            XCTAssertTrue(isUploaded)
        }
    }
    
    func test_sync_plan_with_existing_plan_from_remote_has_no_changes() throws {
        // (1) Given
        remoteDatabase = MockRemoteDatabasePlan()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        
        // (2) When
        let startDate = Calendar.current.startOfDay(for: .init())
                                                    
        createExpectation(
            publisher: repository.syncPlan(
                startDate: startDate,
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: startDate)!,
                dataAmount: 17,
                dailyLimit: 0.5,
                planLimit: 16.7
            ),
            description: "Sync Plan"
        ) { isUploaded in
            
            // (3) Then
            XCTAssertFalse(isUploaded)
        }
    }
}

internal func createDate(offset: Int) -> Date {
    let date = Calendar.current.date(byAdding: .day, value: offset, to: .init())!
    return Calendar.current.startOfDay(for: date)
}
