//
//  DataUsageRemoteRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 4/2/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

// MARK: Protocol
protocol DataUsageRemoteRepositoryProtocol {
    
    /// [A] Plan
    func isPlanAdded() -> AnyPublisher<Bool, Never>
    func addPlan(_ plan: RemotePlan) ->  AnyPublisher<Bool, Never>
    func updatePlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Never>
    
    /// [B] Data
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Never>
    func getAllExistingDataDates() -> AnyPublisher<[Date], Never>
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Never>
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Never>
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Never>
    
    /// [C] User
    func isLoggedInUser() -> AnyPublisher<Bool, Never>
}


// MARK: App Implementation
class DataUsageRemoteRepository: ObservableObject, DataUsageRemoteRepositoryProtocol {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    let remoteDatabase: RemoteDatabase
    
    @Published var isLoggedIn = false
    @Published var plan: RemotePlan?
    
    init(remoteDatabase: RemoteDatabase) {
        self.remoteDatabase = remoteDatabase
    }
    
    /// [A]
    func isPlanAdded() -> AnyPublisher<Bool, Never> {
        remoteDatabase.fetchAll(of: .plan)
            .map { $0.count > 0 }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func addPlan(_ plan: RemotePlan) -> AnyPublisher<Bool, Never> {
        let record = CKRecord(recordType: RecordType.plan.rawValue)
        record.setValuesForKeys(plan.toDictionary())
                
        return remoteDatabase.save(record: record)
            .flatMap { isSaved in
                Just(isSaved)
                    .eraseToAnyPublisher()
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func updatePlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Never> {
        remoteDatabase.fetchAll(of: .plan)
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .map(\.first)
            .flatMap {
                guard let planRecord: CKRecord = $0 else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                /// compare then update if any real changes
                var changeCount = 0
                
                let planStartDate = planRecord.value(forKey: "startDate") as? Date
                if planStartDate != startDate {
                    planRecord.setValue(startDate, forKey: "startDate")
                    changeCount += 1
                }
                
                let planEndDate = planRecord.value(forKey: "endDate") as? Date
                if planEndDate != endDate {
                    planRecord.setValue(endDate, forKey: "endDate")
                    changeCount += 1
                }

                let planDataAmount = planRecord.value(forKey: "dataAmount") as? Double
                if planDataAmount != dataAmount {
                    planRecord.setValue(dataAmount, forKey: "dataAmount")
                    changeCount += 1
                }

                let planDailyLimit = planRecord.value(forKey: "dailyLimit") as? Double
                if planDailyLimit != dailyLimit {
                    planRecord.setValue(dailyLimit, forKey: "dailyLimit")
                    changeCount += 1
                }

                let planPlanLimit = planRecord.value(forKey: "planLimit") as? Double
                if planPlanLimit != planLimit {
                    planRecord.setValue(planLimit, forKey: "planLimit")
                    changeCount += 1
                }
                
                print("change count: \(changeCount)")
                
                guard changeCount > 0 else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                return self.remoteDatabase.save(record: planRecord)
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// [B]
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Never> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .map { $0.count > 0 }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func getAllExistingDataDates() -> AnyPublisher<[Date], Never> {
        remoteDatabase.fetchAll(of: .data)
            .replaceError(with: [])
            .map { records in
                records.compactMap { $0.value(forKey: "date") as? Date }
            }
            .eraseToAnyPublisher()
    }
    
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Never> {
        let records = bulkData.map { data in
            let record = CKRecord(recordType: RecordType.data.rawValue)
            record.setValuesForKeys(data.toDictionary())
            return record
        }
        
        return remoteDatabase.save(records: records)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Never> {
        let record = CKRecord(recordType: RecordType.data.rawValue)
        record.setValuesForKeys(data.toDictionary())

        return remoteDatabase.save(record: record)
            .flatMap { isSaved in
                Just(isSaved)
                    .eraseToAnyPublisher()
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Never> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .map(\.first)
            .flatMap {
                guard let dataRecord: CKRecord = $0 else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                /// compare then update if any real changes
                var changeCount = 0
                
                let dataDailyUsedData = dataRecord.value(forKey: "dailyUsedData") as? Double
                
                if dataDailyUsedData != dailyUsedData {
                    dataRecord.setValue(dailyUsedData, forKey: "dailyUsedData")
                    changeCount += 1
                }
                
                print("change count: \(changeCount)")
                
                guard changeCount > 0 else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                return self.remoteDatabase.save(record: dataRecord)
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// [C]
    func isLoggedInUser() -> AnyPublisher<Bool, Never> {
        remoteDatabase.checkLoginStatus()
    }
}
