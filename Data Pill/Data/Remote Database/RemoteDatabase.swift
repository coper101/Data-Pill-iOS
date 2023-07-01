//
//  RemoteDatabase.swift
//  Data Pill
//
//  Created by Wind Versi on 3/2/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

// MARK: - Protocol
protocol RemoteDatabase {
  
    // MARK: - Account
    func checkLoginStatus() -> AnyPublisher<Bool, Never>
    
    
    // MARK: - Records
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error>
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error>
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error>
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error>
    
    
    // MARK: - Subscriptions
    func createOnUpdateRecordSubscription(of recordType: RecordType, id subscriptionID: String) -> AnyPublisher<Bool, Never>
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never>
}



// MARK: - App Implementation
final class CloudDatabase: RemoteDatabase {
    
    // MARK: - Dependencies
    let database: CKDatabase
    let container: CKContainer
    
    
    // MARK: - Initializer
    init(container: CloudContainer) {
        self.container = CKContainer(identifier: container.identifier)
        self.database = self.container.privateCloudDatabase
    }
}


