//
//  RemoteDataOperation.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

extension DataUsageRemoteRepository {
    
    // MARK: - Read
    /// Publishes whether a ``RemoteData`` record exists on the specified `date` or not from ``RemoteDatabase``.
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .map {  $0.count > 0 }
            .eraseToAnyPublisher()
    }
    
    /// Publishes the existing ``RemoteData`` record from ``RemoteDatabase``.
    func getData(on date: Date) -> AnyPublisher<RemoteData?, Error> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)

        return remoteDatabase.fetch(with: predicate, of: .data)
            .map(\.first)
            .map { dataRecord in
                guard
                    let dataRecord,
                    let remoteData = RemoteData.toRemoteData(dataRecord)
                else {
                    return nil
                }
                return remoteData
            }
            .eraseToAnyPublisher()
    }
    
    /// Publishes all the existing ``RemoteData``records from ``RemoteDatabase``.
    func getAllData(excluding date: Date) -> AnyPublisher<[RemoteData], Error> {
        remoteDatabase.fetchAll(of: .data, recursively: true)
            .map { dataRecords in
                dataRecords
                    .compactMap { dataRecord in
                        RemoteData.toRemoteData(dataRecord)
                    }
                    .filter { $0.date != date }
            }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Add
    /// Saves a new ``RemoteData`` record into ``RemoteDatabase``
    /// and publisher whether it was successful or not.
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Error> {
        let record = CKRecord(recordType: RecordType.data.rawValue)
        record.setValuesForKeys(data.toDictionary())

        return remoteDatabase.save(record: record)
            .eraseToAnyPublisher()
    }
    
    /// Saves multiple ``RemoteData`` record into ``RemoteDatabase``
    /// and publisher whether it was successful or not.
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Error> {
        let records = bulkData.map { data in
            let record = CKRecord(recordType: RecordType.data.rawValue)
            record.setValuesForKeys(data.toDictionary())
            return record
        }
        
        return remoteDatabase.save(records: records)
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Update
    /// Saves the existing ``RemoteData``record with updated value  into ``RemoteDatabase``
    /// and publisher whether it was successful or not.
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .map(\.first)
            .flatMap {
                guard let dataRecord: CKRecord = $0 else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                /// compare then update if any real changes (more than the saved remote usage)
                var hasHigherUsageChange = false
                
                if
                    let dataDailyUsedData = dataRecord.value(forKey: "dailyUsedData") as? Double,
                    dailyUsedData > dataDailyUsedData
                {
                    dataRecord.setValue(dailyUsedData, forKey: "dailyUsedData")
                    hasHigherUsageChange = true
                }
                
                                
                guard hasHigherUsageChange else {
                    Logger.dataUsageRemoteRepository.debug("- REMOTE DATA OPERATION: 🌐 Update Data | 😭 Updating Item Cancelled as No Change Detected")
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                Logger.dataUsageRemoteRepository.debug("- REMOTE DATA OPERATION: 🌐 Update Data | Updating Item...")

                return self.remoteDatabase.save(record: dataRecord)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Saves multiple existing ``RemoteData`` record with updated values into ``RemoteDatabase``
    /// and publisher whether it was successful or not.
    func updateData(_ data: [RemoteData]) -> AnyPublisher<Bool, Error> {
        guard !data.isEmpty else {
            Logger.dataUsageRemoteRepository.debug("- REMOTE DATA OPERATION: 🌐 Update Multiple Data | 😭 No Items to Updated")
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let predicate = NSPredicate(format: "ANY %@ = date", data.map(\.date))
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .flatMap { (dataRecords: [CKRecord]) in
                Logger.dataUsageRemoteRepository.debug("- REMOTE DATA OPERATION: 🌐 Update Multiple Data | Fetching Latest \(dataRecords.count) Items")
                
                let recordsToUpdate = zip(dataRecords, data)
                    .compactMap { (remoteData: CKRecord, localData: RemoteData) -> (record: CKRecord, data: RemoteData)? in
                        let localDailyUsedData = localData.dailyUsedData
                        let remoteDailyUsedData = remoteData.value(forKey: "dailyUsedData") as? Double
                        guard let remoteDailyUsedData else {
                            return nil
                        }
                        guard localDailyUsedData > remoteDailyUsedData else {
                            return nil
                        }
                        let newRemoteData = remoteData
                        newRemoteData.setValue(localDailyUsedData, forKey: "dailyUsedData")
                        return (newRemoteData, localData)
                    }
                    .map { $0.record }
                
                Logger.dataUsageRemoteRepository.debug("- REMOTE DATA OPERATION: 🌐 Update Multiple Data | Updating \(recordsToUpdate.count) Items")
                
                guard !recordsToUpdate.isEmpty else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.remoteDatabase.save(records: recordsToUpdate)
            }
            .eraseToAnyPublisher()
    }
}
