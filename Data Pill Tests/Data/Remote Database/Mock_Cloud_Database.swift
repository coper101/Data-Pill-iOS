//
//  Mock_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import CloudKit

final class CloudData {
    let dataRecords: NSMutableArray
    let planRecords: NSMutableArray
    
    init(dataRecords: NSMutableArray = [], planRecords: NSMutableArray = []) {
        self.dataRecords = dataRecords
        self.planRecords = planRecords
    }
    
    func clearAll() {
        dataRecords.removeAllObjects()
        planRecords.removeAllObjects()
    }
}

final class MockCloudDatabase: RemoteDatabase {
    
    let data: CloudData
    let hasAccess: Bool
    
    init(hasAccess: Bool = true, data: CloudData) {
        self.hasAccess = hasAccess
        self.data = data
    }
    
    // MARK: - Account
    func isAvailable() -> AnyPublisher<Bool, Error> {
        if hasAccess {
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: RemoteDatabaseError.accountError(.noAccount))
            .eraseToAnyPublisher()
    }
    
    // MARK: - Records
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        guard hasAccess else {
            return Fail(error: RemoteDatabaseError.fetchError("No Access To Cloud"))
                .eraseToAnyPublisher()
        }
        
        switch recordType {
        case .plan:
            return Just(data.planRecords.filtered(using: predicate) as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .data:
            return Just(data.dataRecords.filtered(using: predicate) as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        guard hasAccess else {
            return Fail(error: RemoteDatabaseError.fetchError("No Access To Cloud"))
                .eraseToAnyPublisher()
        }
        
        let predicate = NSPredicate(value: true)
        
        if !recursively {
            return fetch(with: predicate, of: recordType)
        }
        
        switch recordType {
        case .plan:
            return Just(data.planRecords as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .data:
            return Just(data.dataRecords as? [CKRecord] ?? [])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        guard hasAccess else {
            return Fail(error: RemoteDatabaseError.saveError("No Access To Cloud"))
                .eraseToAnyPublisher()
        }
        
        let recordType = RecordType(rawValue: record.recordType)
        
        switch recordType {
        case .plan:
            /// update if it exists
            if let planRecord = data.planRecords.first(where: { element in
                if let element = element as? CKRecord {
                    return element.recordID == record.recordID
                }
                return false
            }) {
                let index = data.planRecords.index(of: planRecord)
                data.planRecords[index] = record
            }
            /// insert if it doesn't exist
            else {
                data.planRecords.insert(record, at: 0)
                
            }
        case .data:
            /// update if it exists
            if let dataRecord = data.dataRecords.first(where: { element in
                if let element = element as? CKRecord {
                    return element.recordID == record.recordID
                }
                return false
            }) {
                let index = data.dataRecords.index(of: dataRecord)
                data.dataRecords[index] = record
            }
            /// insert if it doesn't exist
            else {
                data.dataRecords.insert(record, at: 0)
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
        guard hasAccess else {
            return Fail(error: RemoteDatabaseError.saveError("No Access To Cloud"))
                .eraseToAnyPublisher()
        }
        
        var hasFailed = false
        
        records.forEach { record in
            let recordType = RecordType(rawValue: record.recordType)
            
            
            switch recordType {
            case .plan:
                /// update if it exists
                if let planRecord = data.planRecords.first(where: { element in
                    if let element = element as? CKRecord {
                        return element.recordID == record.recordID
                    }
                    return false
                }) {
                    let index = data.planRecords.index(of: planRecord)
                    data.planRecords[index] = record
                    return
                }
                /// insert if it doesn't exist
                data.planRecords.insert(record, at: 0)
                
            case .data:
                /// update if it exists
                if let dataRecord = data.dataRecords.first(where: { element in
                    if let element = element as? CKRecord {
                        return element.recordID == record.recordID
                    }
                    return false
                }) {
                    let index = data.dataRecords.index(of: dataRecord)
                    data.dataRecords[index] = record
                    return
                }
                /// insert if it doesn't exist
                data.dataRecords.insert(record, at: 0)
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
    
    // MARK: - Subscriptions
    func createOnUpdateRecordSubscription(of recordType: RecordType, id subscriptionID: String) -> AnyPublisher<Bool, Never> {
        Just(false)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
}
