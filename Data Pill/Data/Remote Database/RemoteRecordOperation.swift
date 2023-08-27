//
//  RemoteRecordOperation.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

extension CloudDatabase {
    
    // MARK: - Read
    /// Publishes a list of ``CKRecord`` that satisifies the specified `predicate` and `recordType` from iCloud Database.
    func fetch(with predicate: NSPredicate, of recordType: RecordType) -> AnyPublisher<[CKRecord], Error> {
        let query = CKQuery(recordType: recordType.rawValue, predicate: predicate)
        
        return Future { promise in
            if #available(iOS 15.0, *) {
                
                /// `iOS 15.0`
                self.database.fetch(withQuery: query) { completion in
                    
                    switch completion {
                    /// 1. Success
                    /// 1A. Fetch Response
                    case .success(let response):
                        
                        /// 1B. Fetch Result
                        let results: [Result<CKRecord, Error>] = response.matchResults.compactMap { $0.1 }
                        
                        let records: [CKRecord] = results.compactMap { result in
                            switch result {
                            case .success(let record):
                                return record
                            case .failure(_):
                                return nil
                            }
                        }
                        
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch Records | ✅ \(records.count) Items")
                        promise(.success(records))
                        
                    /// 2. Fail
                    case .failure(let error):
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch Records | 😭 ERROR: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription)))
                    } //: switch-case
                    
                } //: fetch
                
            } else {
                
                /// `< iOS 14.0`
                self.database.perform(query, inZoneWith: nil) { records, error in
                    
                    /// 2. Fail
                    if let error {
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch Records | 😭 ERROR: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription)))
                        return
                    }
                    
                    guard let records else {
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch Records | 😭 ERROR: Records is Nil)")
                        promise(.failure(RemoteDatabaseError.fetchError("records is nil")))
                        return
                    }
                    
                    /// 1. Success
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch Records | ✅ \(records.count) Items")
                    promise(.success(records))
                    
                } //: fetch
                
            } //: if-else
        } //: Future
        .eraseToAnyPublisher()
    }
    
    /// Publishes all ``CKRecord`` that exists in iCloud Database.
    ///
    /// - Parameter recursively: Fetches all records if True, fetches the first number of records if False.
    ///
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        let predicate = NSPredicate(value: true)
                
        if !recursively {
            return fetch(with: predicate, of: recordType)
        }
        
        return Future { promise in
          
            let query = CKQuery(recordType: recordType.rawValue, predicate: predicate)

            var records = [CKRecord]()
            var reccurrentOperationCounter = 0
                      
            /// 1B. Cursor Query to Keep on Fetching Records
            func recurrentOperation(
                _ cursor: CKQueryOperation.Cursor,
                successBlock: @escaping ([CKRecord]) -> Void,
                failureBlock: @escaping (Error) -> Void
            ) {
                var operation = CKQueryOperation(cursor: cursor)
                self.executeQueryOperation(&operation) { record in
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | Reccurent Operation Record ID: \(record.recordID)")
                    reccurrentOperationCounter += 1
                    records.append(record)
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | Reccurent Operation Count: \(reccurrentOperationCounter)")
                    
                } recordFailureBlock: { error in
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | Reccurent Operation Record - ERROR: \(error.localizedDescription)")
                    
                } resultSuccessBlock: { cursor in
                    guard let cursor else {
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | Reccurent Operation Record - ERROR: Cursor is Nil")
                        successBlock(records)
                        return
                    }
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | ✅ Reccurent Operation Record")
                    recurrentOperation(cursor, successBlock: successBlock, failureBlock: failureBlock)
                    
                } resultFailureBlock: { error in
                    failureBlock(error)
                }
                self.database.add(operation)
            }
            
            /// 1A. Initial Query
            var queryOperation = CKQueryOperation(query: query)

            self.executeQueryOperation(&queryOperation) { record in
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | Fetching Initial Records...")
                records.append(record)
                
            } recordFailureBlock: { error in
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | 😭 Fetch Initial Records - ERROR: \(error.localizedDescription)")
                
            } resultSuccessBlock: { cursor in
                guard let cursor else {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | ✅ Fetched Initial Records - ERROR: Cursor is Nil")
                    promise(.success(records)) // A
                    return
                }
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | ✅ Fetched Initial Records")

                recurrentOperation(
                    cursor,
                    successBlock: { promise(.success($0)) },
                    failureBlock: { promise(.failure($0)) }
                )
                
            } resultFailureBlock: { error in
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Records | 😭 Fetch Initial Records - ERROR: \(error.localizedDescription)")
                promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription))) // B
                
            }
           
            /// 2. Execute Operation
            self.database.add(queryOperation)
        }
        .eraseToAnyPublisher()
    }
    
    func executeQueryOperation(
        _ operation: inout CKQueryOperation,
        recordSuccessBlock: @escaping (CKRecord) -> Void,
        recordFailureBlock: @escaping (Error) -> Void,
        resultSuccessBlock: @escaping (CKQueryOperation.Cursor?) -> Void,
        resultFailureBlock: @escaping (Error) -> Void
    ) {
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = { recordID, completion in
                switch completion {
                case .success(let record):
                    recordSuccessBlock(record)
                case .failure(let error):
                    recordFailureBlock(error)
                    break
                }
            }
        } else {
            operation.recordFetchedBlock = { record in
                recordSuccessBlock(record)
            }
        } //: record block
        
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = { completion in
                switch completion {
                case .success(let cursor):
                    resultSuccessBlock(cursor)
                case .failure(let error):
                    resultFailureBlock(error)
                }
            }
        } else {
            operation.queryCompletionBlock = { cursor, error in
                
                if let error {
                    resultFailureBlock(error)
                    return
                }
                resultSuccessBlock(cursor)
            }
        } // completion block
    }
        
    
    // MARK: - Update / Add
    /// Saves the specified ``CKRecord`` into iCloud Database
    /// and publishes whether it was successful or not.
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.database.save(record) { newRecord, error in
                
                /// 2. Fail
                if let error {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Record | 😭 ERROR: \(error.localizedDescription)")
                    promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                    return
                }
                
                guard newRecord != nil else {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Record | 😭 ERROR: New Record is Nil")
                    promise(.failure(RemoteDatabaseError.saveError("new record is nil")))
                    return
                }
                
                /// 1. Success
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Record | ✅ Saved")
                promise(.success(true))
                
            } //: save
        } //: Future
        .eraseToAnyPublisher()
    }
    
    /// Saves the specified `records` list of ``CKRecord`` into iCloud Database
    /// and publishes whether it was successful or not.
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Logger.remoteDatabase.debug("save - records: \(records)")

        return Future { promise in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            
            if #available(iOS 15.0, *) {
                
                /// `iOS 15.0`
                operation.modifyRecordsResultBlock = { completion in
                    switch completion {
                        
                    /// 1. Success
                    case .success(_):
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Bulk Records | ✅ Saved")
                        promise(.success(true))
                        return
                        
                    /// 2. Fail
                    case .failure(let error):
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Bulk Records | 😭 ERROR: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                        return
                    }
                }
                
            } else {
                
                /// `< iOS 14.0`
                operation.modifyRecordsCompletionBlock = { _, _, error in
                    
                    /// 2. Fail
                    if let error {
                        Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Bulk Records | 😭 ERROR: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                        return
                    }
                    
                    /// 1. Success
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Save Bulk Records | ✅ Saved")
                    promise(.success(true))
                }
                
            } //: if-else
            
            /// 3. Execute Operation
            self.database.add(operation)
            
        } //: Future
        .eraseToAnyPublisher()
    }    
}
