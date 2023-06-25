//
//  Data_Usage_Remote_Sync_Mock.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 21/6/23.
//

import Foundation
import Combine
import CloudKit
@testable import Data_Pill

// MARK: - Common Mock
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
        if
            recordType == .data,
            predicate.description == "ANY {2023-06-20 00:00:00 +0000} == date"
        {
            let remoteData = RemoteData(date: "2023-06-20T00:00:00+00:00".toDate(), dailyUsedData: 100)
            let records = [remoteData].map { data in
                let record = CKRecord(recordType: RecordType.data.rawValue)
                record.setValuesForKeys(data.toDictionary())
                return record
            }
            return Just(records)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Just([])
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
        if
            let firstRecord = records.first,
            let date = firstRecord.value(forKey: "date") as? Date,
            date.description == "2023-06-20 00:00:00 +0000",
            let dailyUsedData = firstRecord.value(forKey: "dailyUsedData") as? Double,
            dailyUsedData == 200
        {
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Just(records.count == 2)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Todays Data
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

// MARK: - Plan
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
