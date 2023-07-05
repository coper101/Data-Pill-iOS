//
//  Mock_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockSuccessCloudDatabase: RemoteDatabase {
    
    // MARK: - Account
    func isAvailable() -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Records
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        
        let remotePlan = RemotePlan(
            startDate: .init(),
            endDate: .init(),
            dataAmount: 0,
            dailyLimit: 0,
            planLimit: 0
        )
        
        let planRecord = CKRecord(recordType: RecordType.plan.rawValue)
        planRecord.setValuesForKeys(remotePlan.toDictionary())
        
        return Just([planRecord])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        
        let remotePlan = RemotePlan(
            startDate: .init(),
            endDate: .init(),
            dataAmount: 0,
            dailyLimit: 0,
            planLimit: 0
        )
        
        let planRecord = CKRecord(recordType: RecordType.plan.rawValue)
        planRecord.setValuesForKeys(remotePlan.toDictionary())
        
        return Just([planRecord, planRecord])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Subscriptions
    func createOnUpdateRecordSubscription(of recordType: RecordType, id subscriptionID: String) -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just(["Plan", "Data"])
            .eraseToAnyPublisher()
    }
}
