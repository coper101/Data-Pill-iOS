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

// MARK: - Protocol
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
    func updateData(_ data: [RemoteData]) -> AnyPublisher<Bool, Error>
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
    func syncTodaysData(_ todaysData: Data, isSyncedToRemote: Bool) -> AnyPublisher<Bool, Error>
    func syncOldLocalData(_ localData: [Data], lastSyncedDate: Date?) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error>
    func syncOldRemoteData(_ localData: [Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error>
    
    /// [E] Remote Notification
    func subscribeToRemotePlanChanges() -> AnyPublisher<Bool, Never>
    func subscribeToRemoteTodaysDataChanges() -> AnyPublisher<Bool, Never>
}



// MARK: - App Implementation
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
        remoteDatabase.fetchAll(of: .plan, recursively: false)
            .map { $0.count > 0 }
            .eraseToAnyPublisher()
    }
    
    func getPlan() -> AnyPublisher<RemotePlan?, Error> {
        remoteDatabase.fetchAll(of: .plan, recursively: false)
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
        remoteDatabase.fetchAll(of: .plan, recursively: false)
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
            .map {
                Logger.dataUsageRemoteRepository.debug("count - \($0.count)")
                return $0.count > 0
                
            }
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
        remoteDatabase.fetchAll(of: .data, recursively: true)
            .replaceError(with: [])
            .map { records in
                records.compactMap { $0.value(forKey: "date") as? Date }
            }
            .eraseToAnyPublisher()
    }
    
    func getAllData(excluding date: Date) -> AnyPublisher<[RemoteData], Never> {
        remoteDatabase.fetchAll(of: .data, recursively: true)
            .replaceError(with: [])
            .map { dataRecords in
                dataRecords
                    .compactMap { dataRecord in
                        RemoteData.toRemoteData(dataRecord)
                    }
                    .filter { $0.date != date }
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
    
    func updateData(_ data: [RemoteData]) -> AnyPublisher<Bool, Error> {
        guard !data.isEmpty else {
            Logger.dataUsageRemoteRepository.debug("updateMultipleData - nothing to update")
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let predicate = NSPredicate(format: "ANY %@ = date", data.map(\.date))
        
        return remoteDatabase.fetch(with: predicate, of: .data)
            .flatMap { (dataRecords: [CKRecord]) in
                
                Logger.dataUsageRemoteRepository.debug("updateMultipleData - data records count: \(dataRecords.count)")
                Logger.dataUsageRemoteRepository.debug("updateMultipleData - data records: \(dataRecords)")
                
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
                
                Logger.dataUsageRemoteRepository.debug("updateMultipleData - data to update records: \(recordsToUpdate)")
                
                guard !recordsToUpdate.isEmpty else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.remoteDatabase.save(records: recordsToUpdate)
            }
            .eraseToAnyPublisher()
    }
    
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
    
    func syncTodaysData(_ todaysData: Data, isSyncedToRemote: Bool) -> AnyPublisher<Bool, Error> {
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
                /// 2A. add new data
                if !isSyncedToRemote && !isDataAdded {
                    return self
                        .addData(.init(date: date, dailyUsedData: dailyUsedData))
                        .eraseToAnyPublisher()
                }
                /// 2B. update existing data
                if isSyncedToRemote && isDataAdded {
                    return self
                        .updateData(date: date, dailyUsedData: dailyUsedData)
                        .eraseToAnyPublisher()
                }
                /// 2C. data added but not yet reflected in remote
                return Just(false)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncOldLocalData(_ localData: [Data], lastSyncedDate: Date?) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error> {
        var allLocalData = localData
        
        Logger.dataUsageRemoteRepository.debug("syncOldLocalData - last synced date: \(String(describing: lastSyncedDate))")

        // Logger.dataUsageRemoteRepository.debug("syncOldLocalData - data from local: \(allLocalData)")
        
        /// exclude todays data
        let todaysDate = Calendar.current.startOfDay(for: .init())
        allLocalData.removeAll(where: { $0.date == todaysDate })
        
        Logger.dataUsageRemoteRepository.debug("syncOldLocalData - data from local count excluding today's data: \(allLocalData.count)")
        
        guard !allLocalData.isEmpty else {
            return Just((false, false, []))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return self.isLoggedInUser()
            .flatMap { isLoggedIn -> AnyPublisher<([Data], [Data]), Never> in
                
                /// A.
                var dataToAdd = allLocalData.filter { !$0.isSyncedToRemote }
                let limit = 100
                if dataToAdd.count >= limit {
                    dataToAdd = Array(dataToAdd[..<limit])
                }
                Logger.dataUsageRemoteRepository.debug("syncOldLocalData - data to add to remote count: \(dataToAdd.count)")
                
                /// B.
                var dataToUpdate = [Data]()
                if let lastSyncedDate {
                    dataToUpdate = allLocalData.filter { data in
                        guard let date = data.date else {
                            Logger.dataUsageRemoteRepository.debug("syncOldLocalData - false date")
                            return false
                        }
                        Logger.dataUsageRemoteRepository.debug("syncOldLocalData - in range: \(date.isDateInRange(from: lastSyncedDate, to: todaysDate))")
                        return data.isSyncedToRemote && date.isDateInRange(from: lastSyncedDate, to: todaysDate)
                    }
                }
                Logger.dataUsageRemoteRepository.debug("syncOldLocalData - data to update to remote count: \(dataToUpdate.count)")
                                
                return Just((dataToAdd, dataToUpdate)).eraseToAnyPublisher()
            }
            .map { (dataToAdd: [Data], dataToUpdate: [Data]) in
                /// convert all to remote data types
                let transform: (Data) -> RemoteData? = { data in
                    guard let date = data.date else {
                        return nil
                    }
                    return RemoteData(date: date, dailyUsedData: data.dailyUsedData)
                }
                
                let remoteDataToAdd: [RemoteData] = dataToAdd.compactMap(transform)
                let remoteDataToUpdate: [RemoteData] = dataToUpdate.compactMap(transform)

                return (remoteDataToAdd, remoteDataToUpdate)
            }
            .flatMap { (remoteDataToAdd: [RemoteData], remoteDataToUpdate: [RemoteData]) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error> in
                guard !remoteDataToAdd.isEmpty else {
                    /// 2. Update
                    return self.updateData(remoteDataToUpdate)
                        .flatMap { isUpdated in
                            let updatedRemoteData = isUpdated ? remoteDataToUpdate : []
                            return Just((false, isUpdated, updatedRemoteData))
                        }
                        .eraseToAnyPublisher()
                }
                /// 1. Add
                return self.addData(remoteDataToAdd)
                    .flatMap { isAdded in
                        /// 2. Update
                        self.updateData(remoteDataToUpdate)
                            .flatMap { isUpdated in
                                let updatedRemoteData = isUpdated ? remoteDataToUpdate : []
                                return Just((isAdded, isUpdated, updatedRemoteData + remoteDataToAdd))
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncOldRemoteData(_ localData: [Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error> {
        var allLocalData = localData
        
        /// 1. Exclude `Data` with Date (Today's Date)
        allLocalData.removeAll(where: { $0.date == Calendar.current.startOfDay(for: .init()) })
        Logger.dataUsageRemoteRepository.debug("syncOldRemoteData - data from local count excluding today: \(allLocalData.count)")

        /// 2. Has Access to iCloud?
        return self.isLoggedInUser()
            .flatMap { isLoggedIn in
                /// 2A. Yep: Get All Existing `RemoteData` from `RemoteDatabase
                if isLoggedIn {
                    return self.getAllData(excluding: date)
                        .eraseToAnyPublisher()
                }
                /// 2B. Nope: Empty
                return Just([RemoteData]()).eraseToAnyPublisher()
            }
            .flatMap { oldRemoteData in
                
                Logger.dataUsageRemoteRepository.debug("syncOldRemoteData - data from remote count: \(oldRemoteData.count)")
                
                /// 3. Get All `RemoteData` that Doesn't Exist in `LocalDatabase`
                var dataToAdd = [RemoteData]()
                
                oldRemoteData.forEach { (remoteData: RemoteData) in
                    /// remote data exists in local, dates saved starts at 00:00 time
                    if let _ = allLocalData.first(where: { $0.date == remoteData.date }) {
                        return
                    }
                    /// doesn't exist, need to be added
                    dataToAdd.append(remoteData)
                }
                
                Logger.dataUsageRemoteRepository.debug("syncOldRemoteData - data to add to local count: \(dataToAdd.count)")
                
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
