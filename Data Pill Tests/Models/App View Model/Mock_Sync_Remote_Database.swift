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
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
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
    
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        if recordType == .data {
            let todaysDate = Calendar.current.startOfDay(for: .init())
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
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
