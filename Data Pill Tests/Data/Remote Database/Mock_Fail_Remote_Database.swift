//
//  Mock_Fail_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockFailCloudDatabase: RemoteDatabase {
    
    // MARK: - Account
    func isAvailable() -> AnyPublisher<Bool, Error> {
        Fail(error: RemoteDatabaseError.accountError(.noAccount))
            .eraseToAnyPublisher()
    }
    
    // MARK: - Records
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Fail(error: RemoteDatabaseError.saveError("Save Error"))
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Fail(error: RemoteDatabaseError.saveError("Save Error"))
            .eraseToAnyPublisher()
    }
    
    // MARK: - Subscription
    func createOnUpdateRecordSubscription(of recordType: RecordType, id subscriptionID: String) -> AnyPublisher<Bool, Never> {
        Just(false)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
}
