//
//  Mock_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import CloudKit

final class MockCloudDatabase: RemoteDatabase {
    
    let dataRecords: NSMutableArray = []
    let planRecords: NSMutableArray = []
    let isLoggedIn: Bool = true
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(isLoggedIn)
            .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        switch recordType {
        case .plan:
            return Just(planRecords.filtered(using: predicate) as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .data:
            return Just(dataRecords.filtered(using: predicate) as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        let predicate = NSPredicate(value: true)
        
        if !recursively {
            return fetch(with: predicate, of: recordType)
        }
        
        switch recordType {
        case .plan:
            return Just(planRecords as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .data:
            return Just(dataRecords as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        let recordType = RecordType(rawValue: record.recordType)
        
        switch recordType {
        case .plan:
            /// update if it exists
            if let planRecord = planRecords.first(where: { element in
                if let element = element as? CKRecord {
                    return element.recordID == record.recordID
                }
                return false
            }) {
                let index = planRecords.index(of: planRecord)
                planRecords[index] = record
            }
            /// insert if it doesn't exist
            else {
                planRecords.insert(record, at: 0)
                
            }
        case .data:
            /// update if it exists
            if let dataRecord = dataRecords.first(where: { element in
                if let element = element as? CKRecord {
                    return element.recordID == record.recordID
                }
                return false
            }) {
                let index = dataRecords.index(of: dataRecord)
                dataRecords[index] = record
            }
            /// insert if it doesn't exist
            else {
                dataRecords.insert(record, at: 0)
            }
        case .none:
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        var hasFailed = false
        
        records.forEach { record in
            let recordType = RecordType(rawValue: record.recordType)
            
            
            switch recordType {
            case .plan:
                /// update if it exists
                if let planRecord = planRecords.first(where: { element in
                    if let element = element as? CKRecord {
                        return element.recordID == record.recordID
                    }
                    return false
                }) {
                    let index = planRecords.index(of: planRecord)
                    planRecords[index] = record
                    return
                }
                /// insert if it doesn't exist
                planRecords.insert(record, at: 0)
                
            case .data:
                /// update if it exists
                if let dataRecord = dataRecords.first(where: { element in
                    if let element = element as? CKRecord {
                        return element.recordID == record.recordID
                    }
                    return false
                }) {
                    let index = dataRecords.index(of: dataRecord)
                    dataRecords[index] = record
                    return
                }
                /// insert if it doesn't exist
                dataRecords.insert(record, at: 0)
            case .none:
                hasFailed = true
            }
        }
        
        if hasFailed {
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createOnUpdateRecordSubscription(of recordType: RecordType, id subscriptionID: String) -> AnyPublisher<Bool, Never> {
        Just(false)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
}
