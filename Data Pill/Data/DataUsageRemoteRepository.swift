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
    func isPlanAdded() -> AnyPublisher<Bool, Error>
    func getPlan() -> AnyPublisher<RemotePlan?, Error>
    func addPlan(_ plan: RemotePlan) ->  AnyPublisher<Bool, Error>
    func updatePlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error>
    
    /// [B] Data
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Error>
    func getData(on date: Date) -> AnyPublisher<RemoteData?, Error>
    func getAllExistingDataDates() -> AnyPublisher<[Date], Never>
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Error>
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Error>
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Error>
    
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
    func isPlanAdded() -> AnyPublisher<Bool, Error> {
        remoteDatabase.fetchAll(of: .plan)
            .map { $0.count > 0 }
            .eraseToAnyPublisher()
    }
    
    func getPlan() -> AnyPublisher<RemotePlan?, Error> {
        remoteDatabase.fetchAll(of: .plan)
            .map(\.first)
            .map { planRecord in
                guard
                    let planRecord,
                    let remotePlan = RemotePlan.toRemotePlan(planRecord)
                else {
                    return nil
                }
                return remotePlan
            }
            .eraseToAnyPublisher()
    }
    
    func addPlan(_ plan: RemotePlan) -> AnyPublisher<Bool, Error> {
        let record = CKRecord(recordType: RecordType.plan.rawValue)
        record.setValuesForKeys(plan.toDictionary())
                
        return remoteDatabase.save(record: record)
            .flatMap { isSaved in
                Just(isSaved)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updatePlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error> {
        remoteDatabase.fetchAll(of: .plan)
            .map(\.first)
            .flatMap { (planRecord: CKRecord?) in
                guard let planRecord else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
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
                
                Logger.dataUsageRemoteRepository.debug("updatePlan - changes count \(changeCount)")
                
                guard changeCount > 0 else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.remoteDatabase.save(record: planRecord)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// [B]
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .map { $0.count > 0 }
            .eraseToAnyPublisher()
    }
    
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
    
    func getAllExistingDataDates() -> AnyPublisher<[Date], Never> {
        remoteDatabase.fetchAll(of: .data)
            .replaceError(with: [])
            .map { records in
                records.compactMap { $0.value(forKey: "date") as? Date }
            }
            .eraseToAnyPublisher()
    }
    
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Error> {
        let records = bulkData.map { data in
            let record = CKRecord(recordType: RecordType.data.rawValue)
            record.setValuesForKeys(data.toDictionary())
            return record
        }
        
        return remoteDatabase.save(records: records)
            .eraseToAnyPublisher()
    }
    
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Error> {
        let record = CKRecord(recordType: RecordType.data.rawValue)
        record.setValuesForKeys(data.toDictionary())

        return remoteDatabase.save(record: record)
            .eraseToAnyPublisher()
    }
    
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Error> {
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .eraseToAnyPublisher()
            .map(\.first)
            .flatMap {
                guard let dataRecord: CKRecord = $0 else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                /// compare then update if any real changes
                var changeCount = 0
                
                let dataDailyUsedData = dataRecord.value(forKey: "dailyUsedData") as? Double
                
                if dataDailyUsedData != dailyUsedData {
                    dataRecord.setValue(dailyUsedData, forKey: "dailyUsedData")
                    changeCount += 1
                }
                
                Logger.dataUsageRemoteRepository.debug("updateData - changes count \(changeCount)")

                guard changeCount > 0 else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.remoteDatabase.save(record: dataRecord)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// [C]
    func isLoggedInUser() -> AnyPublisher<Bool, Never> {
        remoteDatabase.checkLoginStatus()
    }
}
