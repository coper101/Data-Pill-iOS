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
                        Logger.remoteDatabase.debug("fetch - records count \(records.count)")
                        promise(.success(records))
                        
                    case .failure(let error):
                        Logger.remoteDatabase.debug("fetch - error: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription)))
                        
                    } //: switch-case
                    
                } //: fetch
                
            } else {
                
                self.database.perform(query, inZoneWith: nil) { records, error in
                    
                    if let error {
                        Logger.remoteDatabase.debug("fetch - error: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription)))
                        return
                    }
                    
                    guard let records else {
                        Logger.remoteDatabase.debug("fetch - error: records is nil")
                        promise(.failure(RemoteDatabaseError.fetchError("records is nil")))
                        return
                    }
                    
                    Logger.remoteDatabase.debug("fetch - records count \(records.count)")
                    promise(.success(records))
                    
                } //: fetch
                
            } //: if-else
        } //: Future
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
        
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        let predicate = NSPredicate(value: true)
        
        if !recursively {
            return fetch(with: predicate, of: recordType)
        }
        
        return Future { promise in
          
            let query = CKQuery(recordType: recordType.rawValue, predicate: predicate)

            var records = [CKRecord]()
            var reccurrentOperationCounter = 0
                      
            // Cursor Query
            func recurrentOperation(
                _ cursor: CKQueryOperation.Cursor,
                successBlock: @escaping ([CKRecord]) -> Void,
                failureBlock: @escaping (Error) -> Void
            ) {
                var operation = CKQueryOperation(cursor: cursor)
                self.executeQueryOperation(&operation) { record in
                    Logger.remoteDatabase.debug("fetchAll - recurrentOperation record ID: \(record.recordID)")
                    reccurrentOperationCounter += 1
                    records.append(record)
                    Logger.remoteDatabase.debug("fetchAll - reccurrentOperationCounter count: \(reccurrentOperationCounter)")
                    
                } recordFailureBlock: { error in
                    Logger.remoteDatabase.debug("fetchAll - recurrentOperation record error: \(error.localizedDescription)")
                    
                } resultSuccessBlock: { cursor in
                    guard let cursor else {
                        Logger.remoteDatabase.debug("fetchAll - recurrentOperation cursor is nil")
                        successBlock(records)
                        return
                    }
                    Logger.remoteDatabase.debug("fetchAll - recurrentOperation result success")
                    recurrentOperation(cursor, successBlock: successBlock, failureBlock: failureBlock)
                    
                } resultFailureBlock: { error in
                    failureBlock(error)
                }
                self.database.add(operation)
            }
            
            // Initial Query
            var queryOperation = CKQueryOperation(query: query)

            self.executeQueryOperation(&queryOperation) { record in
                    Logger.remoteDatabase.debug("fetchAll - initial queryOperation record ID: \(record.recordID)")
                    records.append(record)
                    
                } recordFailureBlock: { error in
                    Logger.remoteDatabase.debug("fetchAll - initial queryOperation record error: \(error.localizedDescription)")
                    
                } resultSuccessBlock: { cursor in
                    guard let cursor else {
                        Logger.remoteDatabase.debug("fetchAll - initial queryOperation result cursor is nil")
                        promise(.success(records)) // A
                        return
                    }
                    Logger.remoteDatabase.debug("fetchAll - initial queryOperation result success")
                    recurrentOperation(
                        cursor,
                        successBlock: { promise(.success($0)) },
                        failureBlock: { promise(.failure($0)) }
                    )
                    
                } resultFailureBlock: { error in
                    Logger.remoteDatabase.debug("fetchAll - initial queryOperation result error: \(error.localizedDescription)")
                    promise(.failure(RemoteDatabaseError.fetchError(error.localizedDescription))) // B
                    
                }
           
            self.database.add(queryOperation)
        }
        .eraseToAnyPublisher()
    }
        
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.database.save(record) { newRecord, error in
                if let error {
                    Logger.remoteDatabase.debug("save - error: \(error.localizedDescription)")
                    promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                    return
                }
                guard newRecord != nil else {
                    Logger.remoteDatabase.debug("save - error: new record is nil")
                    promise(.failure(RemoteDatabaseError.saveError("new record is nil")))
                    return
                }
                Logger.remoteDatabase.debug("save - saved")
                promise(.success(true))
            } //: save
        } //: Future
        .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        Logger.remoteDatabase.debug("save - records: \(records)")

        return Future { promise in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            
            if #available(iOS 15.0, *) {
                operation.modifyRecordsResultBlock = { completion in
                    switch completion {
                    case .success(_):
                        Logger.remoteDatabase.debug("save - records saved")
                        promise(.success(true))
                        return
                    case .failure(let error):
                        Logger.remoteDatabase.debug("save - records error: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                        return
                    }
                }
                
            } else {
                operation.modifyRecordsCompletionBlock = { _, _, error in
                    if let error {
                        Logger.remoteDatabase.debug("save - records error: \(error.localizedDescription)")
                        promise(.failure(RemoteDatabaseError.saveError(error.localizedDescription)))
                        return
                    }
                    Logger.remoteDatabase.debug("save - records saved")
                    promise(.success(true))
                }
                
            } //: if-else
            
            self.database.add(operation)
            
        } //: Future
        .eraseToAnyPublisher()
    }    
}
