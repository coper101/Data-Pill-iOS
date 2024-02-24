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
        continueAfterFailure = false
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

    // MARK: - Old Local Data
    func test_sync_old_local_data_but_has_no_access_to_remote_database() throws {
        // (1) Given
        try load_local_database()
        
        remoteDatabase = MockFailCloudDatabase()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedDate = todaysDate
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = false
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = TestData.createDate(offset: -1, from: todaysDate)
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100
        yesterdaysData.hasLastTotal = true
        yesterdaysData.isSyncedToRemote = false
        
        let yesterdaysData2 = Data(context: localDatabase.context)
        yesterdaysData2.date = TestData.createDate(offset: -2, from: todaysDate)
        yesterdaysData2.totalUsedData = 1500
        yesterdaysData2.dailyUsedData = 100
        yesterdaysData2.hasLastTotal = true
        yesterdaysData2.isSyncedToRemote = false
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let localData = [todaysData, yesterdaysData, yesterdaysData2]
        
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

    func test_sync_old_local_data_that_were_not_synced_to_remote() throws {
        // (1) Given
        try load_local_database()
        
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedDate = todaysDate
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = false
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = TestData.createDate(offset: -1, from: todaysDate)
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100
        yesterdaysData.hasLastTotal = true
        yesterdaysData.isSyncedToRemote = false
        
        let yesterdaysData2 = Data(context: localDatabase.context)
        yesterdaysData2.date = TestData.createDate(offset: -2, from: todaysDate)
        yesterdaysData2.totalUsedData = 1500
        yesterdaysData2.dailyUsedData = 100
        yesterdaysData2.hasLastTotal = true
        yesterdaysData2.isSyncedToRemote = false
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let localData = [todaysData, yesterdaysData, yesterdaysData2]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then
            XCTAssertTrue(areOldDataAdded)
            XCTAssertEqual(addedRemoteData.count, 2)
        }
    }
    
    func test_sync_old_local_data_that_were_synced_remote() throws {
        // (1) Given
        try load_local_database()
        
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedDate = todaysDate
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = TestData.createDate(offset: -1, from: todaysDate)
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100
        yesterdaysData.hasLastTotal = true
        yesterdaysData.isSyncedToRemote = true
        
        let yesterdaysData2 = Data(context: localDatabase.context)
        yesterdaysData2.date = TestData.createDate(offset: -2, from: todaysDate)
        yesterdaysData2.totalUsedData = 1500
        yesterdaysData2.dailyUsedData = 100
        yesterdaysData2.hasLastTotal = true
        yesterdaysData2.isSyncedToRemote = true

        let _ = try? localDatabase.context.saveIfNeeded()

        let localData = [todaysData, yesterdaysData, yesterdaysData2]
        
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
    
    func test_sync_empty_old_local_data() throws {
        // (1) Given
        try load_local_database()

        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedDate = todaysDate
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
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
    
    func test_sync_old_local_data_that_were_synced_to_remote_but_outdated_with_daily_used_data_higher_than_remotes() throws {
        // (1) Given
        try load_local_database()

        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesterdaysDate = TestData.createDate(offset: -1, from: todaysDate)
        let lastSyncedDate = yesterdaysDate
        
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = yesterdaysDate
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 200 /// > 100 (Remote)
        yesterdaysData.hasLastTotal = true
        yesterdaysData.lastSyncedToRemoteDate = TestData.createDate(offset: -1, secondsOffset: 1, from: todaysDate)
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
    
    func test_sync_old_local_data_that_were_synced_to_remote_but_outdated_with_daily_used_data_same_to_remotes() throws {
        // (1) Given
        try load_local_database()

        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesterdaysDate = TestData.createDate(offset: -1, from: todaysDate)
        let lastSyncedDate = yesterdaysDate

        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true

        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = yesterdaysDate
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100 /// = 100 (Remote)
        yesterdaysData.hasLastTotal = true
        yesterdaysData.lastSyncedToRemoteDate = TestData.createDate(offset: -1, secondsOffset: 1, from: todaysDate)
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
    
    func test_sync_old_local_data_that_were_synced_to_remote_but_outdated_with_daily_used_data_lower_than_remotes() throws {
        // (1) Given
        try load_local_database()

        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesterdaysDate = TestData.createDate(offset: -1, from: todaysDate)
        let lastSyncedDate = yesterdaysDate
        
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true

        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = yesterdaysDate
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 50 /// < 100 (Remote)
        yesterdaysData.hasLastTotal = true
        yesterdaysData.lastSyncedToRemoteDate = TestData.createDate(offset: -1, secondsOffset: 1, from: todaysDate)
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
    
    // MARK: - Old Remote Data
//    func test_sync_all_remote_data_but_has_error_getting_all_remote_data() throws {
//        // (1) Given
//        try load_local_database()
//
//        remoteDatabase = MockFailToFetchAllDataRemoteDatabase()
//        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
//
//        let excludingTodaysDate = Calendar.current.startOfDay(for: .init())
//
//        let todaysData = Data(context: localDatabase.context)
//        todaysData.date = Calendar.current.startOfDay(for: .init())
//        todaysData.totalUsedData = 1500
//        todaysData.dailyUsedData = 100
//        todaysData.hasLastTotal = true
//        todaysData.isSyncedToRemote = true
//
//        let _ = try? localDatabase.context.saveIfNeeded()
//
//        let allLocalData = [todaysData]
//
//        // (2) When
//        createExpectation(
//            publisher: repository.syncOldRemoteData(allLocalData, excluding: excludingTodaysDate),
//            description: "Sync Old Remote Data"
//        ) { error in
//
//            // (3) Then
//            XCTAssertEqual(error as? RemoteDatabaseError, .fetchError("Fetch Error"))
//
//        } onSuccess: { _ in }
//    }
    
    func test_sync_all_remote_data_but_has_no_access_to_remote_database() throws {
        // (1) Given
        try load_local_database()
        
        remoteDatabase = MockFailCloudDatabase()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        
        let excludingTodaysDate = Calendar.current.startOfDay(for: .init())
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let allLocalData = [todaysData]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldRemoteData(allLocalData, excluding: excludingTodaysDate),
            description: "Sync Old Remote Data"
        ) { oldRemoteData in
            
            // (3) Then
            XCTAssertTrue(oldRemoteData.isEmpty)
        }
    }
    
    func test_sync_all_remote_data_as_old_local_data_is_empty() throws {
        // (1) Given
        try load_local_database()
        
        remoteDatabase = MockTwoExistingDataRemoteDatabase()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        
        let excludingTodaysDate = Calendar.current.startOfDay(for: .init())
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = Calendar.current.startOfDay(for: .init())
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let allLocalData = [todaysData]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldRemoteData(allLocalData, excluding: excludingTodaysDate),
            description: "Sync Old Remote Data"
        ) { oldRemoteData in
            
            // (3) Then
            XCTAssertEqual(oldRemoteData.count, 2)
        }
    }
    
    func test_sync_one_remote_data_that_does_not_exist_in_local() throws {
        // (1) Given
        try load_local_database()
        
        remoteDatabase = MockTwoExistingDataRemoteDatabase()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let excludingTodaysDate = todaysDate
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = Calendar.current.date(byAdding: .day, value: -1, to: todaysDate)
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100
        yesterdaysData.hasLastTotal = true
        yesterdaysData.isSyncedToRemote = true
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let allLocalData = [todaysData, yesterdaysData]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldRemoteData(allLocalData, excluding: excludingTodaysDate),
            description: "Sync Old Remote Data"
        ) { oldRemoteData in
            
            // (3) Then
            XCTAssertEqual(oldRemoteData.count, 1)
        }
    }
    
    func test_sync_zero_remote_data_as_all_exists_in_local() throws {
        // (1) Given
        try load_local_database()
        
        remoteDatabase = MockTwoExistingDataRemoteDatabase()
        repository = DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let excludingTodaysDate = todaysDate
         
        let todaysData = Data(context: localDatabase.context)
        todaysData.date = todaysDate
        todaysData.totalUsedData = 1500
        todaysData.dailyUsedData = 100
        todaysData.hasLastTotal = true
        todaysData.isSyncedToRemote = true
        
        let yesterdaysData = Data(context: localDatabase.context)
        yesterdaysData.date = Calendar.current.date(byAdding: .day, value: -1, to: todaysDate)
        yesterdaysData.totalUsedData = 1500
        yesterdaysData.dailyUsedData = 100
        yesterdaysData.hasLastTotal = true
        yesterdaysData.isSyncedToRemote = true
        
        let yesterdaysData2 = Data(context: localDatabase.context)
        yesterdaysData2.date = Calendar.current.date(byAdding: .day, value: -2, to: todaysDate)
        yesterdaysData2.totalUsedData = 1500
        yesterdaysData2.dailyUsedData = 200
        yesterdaysData2.hasLastTotal = true
        yesterdaysData2.isSyncedToRemote = true
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let allLocalData = [todaysData, yesterdaysData, yesterdaysData2]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldRemoteData(allLocalData, excluding: excludingTodaysDate),
            description: "Sync Old Remote Data"
        ) { oldRemoteData in
            
            // (3) Then
            XCTAssertTrue(oldRemoteData.isEmpty)
        }
    }
    
    // MARK: - Today's Data
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

    // MARK: - Plan
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
