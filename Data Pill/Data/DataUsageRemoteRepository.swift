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
    
    /// [D] Synchronization
    func syncPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error>
    func syncTodaysData(_ todaysData: Data) -> AnyPublisher<Bool, Error>
    func syncOldLocalData(_ localData: [Data]) -> AnyPublisher<Bool, Error>
    func syncOldRemoteData(_ localData: [Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error>
    
    /// [E] Remote Notification
    func subscribeToRemotePlanChanges() -> AnyPublisher<Bool, Never>
    func subscribeToRemoteTodaysDataChanges() -> AnyPublisher<Bool, Never>
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
    
    func getAllData(excluding date: Date) -> AnyPublisher<[RemoteData], Never> {
        let predicate = NSPredicate(format: "date != %@", date as NSDate)

        return remoteDatabase.fetch(with: predicate, of: .data)
            .replaceError(with: [])
            .map { records in
                return records.compactMap { dataRecord in
                    return RemoteData.toRemoteData(dataRecord)
                }
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
                
                /// compare then update if any real changes (more than the saved remote usage)
                var hasHigherUsageChange = false
                
                if
                    let dataDailyUsedData = dataRecord.value(forKey: "dailyUsedData") as? Double,
                    dailyUsedData > dataDailyUsedData
                {
                    dataRecord.setValue(dailyUsedData, forKey: "dailyUsedData")
                    hasHigherUsageChange = true
                }
                                
                Logger.dataUsageRemoteRepository.debug("updateData - has higher usage change: \(hasHigherUsageChange)")

                guard hasHigherUsageChange else {
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

/// [D]
extension DataUsageRemoteRepository {
    
    func syncPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error> {
        self.isLoggedInUser()
            .flatMap { isLoggedIn in
                /// 1. not logged in
                guard isLoggedIn else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1. logged in
                return self.isPlanAdded()
                    .eraseToAnyPublisher()
            }
            .flatMap { isPlanAdded in
                /// 2. update existing plan
                guard !isPlanAdded else {
                    return self.updatePlan(
                        startDate: startDate,
                        endDate: endDate,
                        dataAmount: dataAmount,
                        dailyLimit: dailyLimit,
                        planLimit: planLimit
                    )
                    .eraseToAnyPublisher()
                }
                /// 2. add new plan
                return self
                    .addPlan(
                        .init(startDate: startDate,
                            endDate: endDate,
                            dataAmount: dataAmount,
                            dailyLimit: dailyLimit,
                            planLimit: planLimit
                        )
                    )
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncTodaysData(_ todaysData: Data) -> AnyPublisher<Bool, Error> {
        guard let todaysDate = todaysData.date else {
            return Fail(error: RemoteDatabaseError.nilProp("Today's Date is nil"))
                .eraseToAnyPublisher()
        }
        let date = Calendar.current.startOfDay(for: todaysDate)
        let dailyUsedData = todaysData.dailyUsedData
        
        return self.isLoggedInUser()
            .flatMap { isLoggedIn  in
                /// 1. not logged in
                guard isLoggedIn else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1. logged in
                return self
                    .isDataAdded(on: date)
                    .eraseToAnyPublisher()
            }
            .flatMap { isDataAdded in
                /// 2. update existing data
                guard !isDataAdded else {
                    return self
                        .updateData(date: date, dailyUsedData: dailyUsedData)
                        .eraseToAnyPublisher()
                }
                /// 2. add new data
                return self
                    .addData(.init(date: date, dailyUsedData: dailyUsedData))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncOldLocalData(_ localData: [Data]) -> AnyPublisher<Bool, Error> {
        var allLocalData = localData
        
        /// exclude todays data
        allLocalData.removeAll(where: { $0.date == Calendar.current.startOfDay(for: .init()) })
        
        guard !allLocalData.isEmpty else {
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
                
        Logger.dataUsageRemoteRepository.debug("syncOldData - data from local count: \(allLocalData.count)")
        
        return self.isLoggedInUser()
            .flatMap { isLoggedIn in
                /// 1. logged in
                if isLoggedIn {
                    return self.getAllExistingDataDates()
                        .eraseToAnyPublisher()
                }
                /// 1. not logged in
                return Just([Date]()).eraseToAnyPublisher()
            }
            .map { dataDatesFromRemote in
                /// data to update not added to cloud
                var dataToUpdate = [Data]()
                
                allLocalData.forEach { data in
                    guard let date = data.date else {
                        return
                    }
                    guard dataDatesFromRemote.first(where: { $0 == date }) == nil else {
                        return
                    }
                    dataToUpdate.append(data)
                }
                
                /// limit data to update
                let limit = 100
                if dataToUpdate.count >= limit {
                    dataToUpdate = Array(dataToUpdate[..<limit])
                }
                
                Logger.dataUsageRemoteRepository.debug("syncOldData - data to update count: \(dataToUpdate.count)")
                
                return dataToUpdate
            }
            .map { (dataToUpdate: [Data]) in
                /// convert all to cloud data type
                let remoteData: [RemoteData] = dataToUpdate.compactMap { data in
                    guard let date = data.date else {
                        return nil
                    }
                    return RemoteData(date: date, dailyUsedData: data.dailyUsedData)
                }
                return remoteData
            }
            .flatMap {
                /// save all old data
                self.addData($0)
            }
            .eraseToAnyPublisher()
    }
    
    func syncOldRemoteData(_ localData: [Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error> {
        var allLocalData = localData
        
        /// exclude todays data
        allLocalData.removeAll(where: { $0.date == Calendar.current.startOfDay(for: .init()) })
        
        Logger.dataUsageRemoteRepository.debug("syncOldRemoteData - data from local count: \(allLocalData.count)")

        // get all local data
        return self.isLoggedInUser()
            .flatMap { isLoggedIn in
                /// 1. logged in
                if isLoggedIn {
                    return self.getAllData(excluding: date)
                        .eraseToAnyPublisher()
                }
                /// 1. not logged in
                return Just([RemoteData]()).eraseToAnyPublisher()
            }
            .flatMap { oldRemoteData in
                
                var dataToAdd = [RemoteData]()
                
                oldRemoteData.forEach { (remoteData: RemoteData) in
                    
                    // remote data exists in local, dates saved starts at 00:00
                    if let _ = allLocalData.first(where: { $0.date == remoteData.date }) {
                        return
                    }
                    
                    // doesn't exist, need to be added
                    dataToAdd.append(remoteData)
                }
                
                Logger.dataUsageRemoteRepository.debug("syncOldRemoteData - data to add count: \(dataToAdd.count)")
                
                return Just(dataToAdd)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// [E]
    func subscribeToRemotePlanChanges() -> AnyPublisher<Bool, Never> {
        let planSubscriptionID = RemoteSubscription.plan.id
        
        return remoteDatabase.fetchAllSubscriptions()
            .flatMap { subscriptionIDs in
                guard subscriptionIDs.first(where: { $0 == planSubscriptionID }) == nil else {
                    return Just(true).eraseToAnyPublisher()
                }
                return self.remoteDatabase
                    .createOnUpdateRecordSubscription(of: .plan, id: planSubscriptionID)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func subscribeToRemoteTodaysDataChanges() -> AnyPublisher<Bool, Never> {
        let todaysDataSubscriptionID = RemoteSubscription.todaysData.id
        
        return remoteDatabase.fetchAllSubscriptions()
            .flatMap { subscriptionIDs in
                guard subscriptionIDs.first(where: { $0 == todaysDataSubscriptionID }) == nil else {
                    return Just(true).eraseToAnyPublisher()
                }
                return self.remoteDatabase
                    .createOnUpdateRecordSubscription(of: .data, id: todaysDataSubscriptionID)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
