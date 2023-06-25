//
//  Mock_Plan_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockRemoteDatabasePlan: RemoteDatabase {
    
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
