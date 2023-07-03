//
//  Mock_Sync_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 27/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockSyncRemoteDatabase: RemoteDatabase {
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        if recursively {
            let todaysDate = Calendar.current.startOfDay(for: .init())
            return Just([
                TestData.createDataRecord(
                    date: TestData.createDate(offset: -2, from: todaysDate),
                    dailyUsedData: 1_500 /// lower than 1500
                ),
                TestData.createDataRecord(
                    date: TestData.createDate(offset: -1, from: todaysDate),
                    dailyUsedData: 1_500 /// lower than 1500
                )
            ])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        return fetch(with: .init(value: true), of: recordType)
    }
    
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        /// Data
        if recordType == .data {
            return Just([
                TestData.createDataRecord(
                    date: TestData.createDate(offset: -2, from: todaysDate),
                    dailyUsedData: 1_000 /// lower than 1500
                ),
                TestData.createDataRecord(
                    date: TestData.createDate(offset: -1, from: todaysDate),
                    dailyUsedData: 1_000 /// lower than 1500
                )
            ])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        
        let startDate = todaysDate
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!
        
        /// Plan
        return Just([
            TestData.createPlanRecord(
                startDate: startDate,
                endDate: endDate,
                dataAmount: 10,
                dailyLimit: 0.5,
                planLimit: 9
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}

final class MockSyncTodaysDataRemoteDatabase: RemoteDatabase {
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }

    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        return Just([
            TestData.createDataRecord(
                date: todaysDate,
                dailyUsedData: 1_000 /// lower than 1_500
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        return Just([
            TestData.createDataRecord(
                date: todaysDate,
                dailyUsedData: 1_000 /// lower than 1_500
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
}
