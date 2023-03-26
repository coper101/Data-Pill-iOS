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
        Just(records.count == 1)
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

    func test_sync_old_local_data() throws {
        // (1) Given
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
        
        let data2 = Data(context: localDatabase.context)
        data2.date = createDate(offset: -1)
        data2.totalUsedData = 1500
        data2.dailyUsedData = 100
        data2.hasLastTotal = true
        
        let data3 = Data(context: localDatabase.context)
        data3.date = createDate(offset: -2)
        data3.totalUsedData = 1500
        data3.dailyUsedData = 100
        data3.hasLastTotal = true
    
        let _ = try? localDatabase.context.saveIfNeeded()

        let localData = [
            data1,
            data2,
            data3
        ]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData),
            description: "Sync Old Local Data"
        ) { areUploaded in
            
            // (3) Then
            XCTAssertTrue(areUploaded)
        }
    }
    
    func test_sync_empty_old_local_data() throws {
        // (1) Given
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

        let localData = [
            todaysData
        ]
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData),
            description: "Sync Old Local Data"
        ) { areUploaded in
            
            // (3) Then
            XCTAssertFalse(areUploaded)
        }
    }

}

internal func createDate(offset: Int) -> Date {
    let date = Calendar.current.date(byAdding: .day, value: offset, to: .init())!
    return Calendar.current.startOfDay(for: date)
}
