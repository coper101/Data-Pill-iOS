//
//  RemoteDatabase.swift
//  Data Pill
//
//  Created by Wind Versi on 3/2/23.
//

import Foundation
import Combine
import CloudKit

// MARK: Types
protocol CK {
    func toDictionary() -> [String: Any]
}

enum RecordType: String {
    case plan = "Plan"
    case data = "Data"
    var type: String {
        self.rawValue
    }
}

enum RemoteDatabaseError: Error {
    case saveError(String)
    case fetchError(String)
}

// MARK: Identifiers
enum CloudContainer: String {
    case dataPill = "iCloud.com.penguinworks.Data-Pill"
    var identifier: String {
        self.rawValue
    }
}

// MARK: Protocol
protocol RemoteDatabase {
    func checkLoginStatus() -> AnyPublisher<Bool, Never>
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error>
    func fetchAll(of recordType: RecordType) -> AnyPublisher<[CKRecord], Error>
    func save(record: CKRecord) -> AnyPublisher<Bool, Error>
}

// MARK: App Implementation
class CloudDatabase: RemoteDatabase {
    
    let database: CKDatabase
    let container: CKContainer
    
    init(container: CloudContainer) {
        self.container = CKContainer(identifier: container.identifier)
        self.database = self.container.privateCloudDatabase
    }
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Future { promise in
            self.container.accountStatus { accountStatus, error in
                guard accountStatus == .available else {
                    print("checkLoginStatus - is not logged in")
                    promise(.success(false))
                    return
                }
                print("checkLoginStatus - is logged in")
                promise(.success(true))
            }
        } //: Future
        .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        let query = CKQuery(recordType: recordType.rawValue, predicate: predicate)
        
        return Future { promise in
            if #available(iOS 15.0, *) {
                
                self.database.fetch(withQuery: query) { completion in
                    
                    // L1. fetch response
                    switch completion {
                    case .success(let response):
                        
                        // L2. fetch results
                        let results: [Result<CKRecord, Error>] = response.matchResults.compactMap { $0.1 }
                        
                        let records: [CKRecord] = results.compactMap { result in
                            switch result {
                            case .success(let record):
                                return record
                            case .failure(_):
                                return nil
                            }
                        }
                        print("fetch - ")
                        promise(.success(records))
                        
                    case .failure(let error):
                        promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription)))
                        
                    } //: switch-case
                    
                } //: fetch
                
            } else {
                
                self.database.perform(query, inZoneWith: nil) { records, error in
                    
                    if let error {
                        promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription)))
                        return
                    }
                    
                    guard let records else {
                        promise(.failure(RemoteDatabaseError.fetchError("records is nil")))
                        return
                    }
                    
                    promise(.success(records))
                    
                } //: fetch
                
            } //: if-else
        } //: Future
        .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        let predicate = NSPredicate(value: true)
        return fetch(with: predicate, of: recordType)
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.database.save(record) { newRecord, error in
                if let error {
                    print("saveItem - error: \(error.localizedDescription)")
                    promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                    return
                }
                guard newRecord != nil else {
                    print("saveItem - error: new record is nil")
                    promise(.failure(RemoteDatabaseError.saveError("new record is nil")))
                    return
                }
                promise(.success(true))
            } //: save
        } //: Future
        .eraseToAnyPublisher()
    }
    
}
