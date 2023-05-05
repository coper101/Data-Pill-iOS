//
//  Data_Usage_Remote_Sync_Repository_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 26/3/23.
//

import XCTest
import Combine
import CloudKit
@testable import Data_Pill

// MARK: Mock Implementation
class MockRemoteDatabase: RemoteDatabase {
    
    func createOnUpdateRecordSubscription(
        of recordType: Data_Pill.RecordType,
        id subscriptionID: String
    ) -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: Data_Pill.RecordType) -> AnyPublisher<[CKRecord], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: Data_Pill.RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        Just([
            TestData.createDataRecord(
                date: createDate(offset: -1),
                dailyUsedData: 100
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Just(records.count == 2)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}

class MockRemoteDatabaseTodaysData: RemoteDatabase {
    
    func createOnUpdateRecordSubscription(
        of recordType: Data_Pill.RecordType,
        id subscriptionID: String
    ) -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: Data_Pill.RecordType) -> AnyPublisher<[CKRecord], Error> {
        let todaysDataRecord = TestData.createDataRecord(
            date: Calendar.current.startOfDay(for: .init()),
            dailyUsedData: 0
        )
                
        return Just([todaysDataRecord])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: Data_Pill.RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class MockRemoteDatabasePlan: RemoteDatabase {
    
    func createOnUpdateRecordSubscription(
        of recordType: Data_Pill.RecordType,
        id subscriptionID: String
    ) -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: Data_Pill.RecordType) -> AnyPublisher<[CKRecord], Error> {
        let startDate = Calendar.current.startOfDay(for: .init())
        let planRecord = TestData.createPlanRecord(
            startDate: startDate,
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: startDate)!,
            dataAmount: 17,
            dailyLimit: 0.5,
            planLimit: 16.7
        )
                
        return Just([planRecord])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: Data_Pill.RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        let predicate = NSPredicate(value: true)
        return fetch(with: predicate, of: .plan)
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}


// MARK: Test
final class Data_Usage_Remote_Sync_Repository_Tests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // MARK: Old Local Data
    func test_sync_more_than_one_old_local() throws {
        // (1) Given
        let lastSyncedDate = Date()
        let database = MockRemoteDatabase()
        let localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
        let expectation = self.expectation(description: "Load Container")
        localDatabase.loadContainer { _ in
        } onSuccess: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
         
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
        let lastSyncedDate = Date()
        let database = MockRemoteDatabase()
        let localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
        let expectation = self.expectation(description: "Load Container")
        localDatabase.loadContainer { _ in
        } onSuccess: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
         
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
        let lastSyncedDate = Date()
        let database = MockRemoteDatabase()
        let localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
        let expectation = self.expectation(description: "Load Container")
        localDatabase.loadContainer { _ in
        } onSuccess: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
         
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
    
    // MARK: Old Remote Data
    
    // MARK: Today's Data
    func test_sync_todays_data_with_non_existent_data_from_remote() throws {
        // (1) Given
        let isSyncedToRemote = false
        let database = MockRemoteDatabase()
        let localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
        let expectation = self.expectation(description: "Load Container")
        localDatabase.loadContainer { _ in
        } onSuccess: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
         
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
        let isSyncedToRemote = true
        let database = MockRemoteDatabaseTodaysData()
        let localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
        let expectation = self.expectation(description: "Load Container")
        localDatabase.loadContainer { _ in
        } onSuccess: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
         
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
        let isSyncedToRemote = true
        let database = MockRemoteDatabaseTodaysData()
        let localDatabase = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
        let expectation = self.expectation(description: "Load Container")
        localDatabase.loadContainer { _ in
        } onSuccess: {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
         
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
        let database = MockRemoteDatabase()
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
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
        let database = MockRemoteDatabasePlan()
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
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
        let database = MockRemoteDatabasePlan()
        let repository = DataUsageRemoteRepository(remoteDatabase: database)
        
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
