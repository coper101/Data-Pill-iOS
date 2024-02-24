//
//  RemoteSynchronization.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import OSLog

extension DataUsageRemoteRepository {

    // MARK: - Today's Data
    /// Saves the existing or new ``RemoteData`` with today's date using the values specified `todaysData`
    /// and publishes whether it is successful or not.
    func syncTodaysData(_ todaysData: Data, isSyncedToRemote: Bool) -> AnyPublisher<Bool, Error> {
        guard let todaysDate = todaysData.date else {
            return Fail(error: RemoteDatabaseError.nilProp("Today's Date is nil"))
                .eraseToAnyPublisher()
        }
        
        let date = Calendar.current.startOfDay(for: todaysDate)
        let dailyUsedData = todaysData.dailyUsedData
        
        /// 1. Has Access to iCloud?
        return self.isDatabaseAccessible()
            .flatMap { isAccessible  in
                /// 1A. Nope
                guard isAccessible else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1B. Yep
                return self
                    .isDataAdded(on: date)
                    .eraseToAnyPublisher()
            }
            .flatMap { isDataAdded in
                /// 2A. Add New Data
                if !isSyncedToRemote && !isDataAdded {
                    return self
                        .addData(.init(date: date, dailyUsedData: dailyUsedData))
                        .eraseToAnyPublisher()
                }
                /// 2B. Update Existing Data
                if isSyncedToRemote && isDataAdded {
                    return self
                        .updateData(date: date, dailyUsedData: dailyUsedData)
                        .eraseToAnyPublisher()
                }
                /// 2C. Data Added But Not Yet Reflected In Remote
                /// - prevents the Data from being re-uploaded to RemoteDatabase
                return Just(false)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Plan
    /// Saves the existing or new ``RemotePlan`` using the values specified
    /// and publishes whether it is successful or not.
    func syncPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error> {
        
        /// 1. Has Access to iCloud?
        self.isDatabaseAccessible()
            .flatMap { isAccessible in
                /// 1A. Nope
                guard isAccessible else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1B. Yep
                return self.isPlanAdded()
                    .eraseToAnyPublisher()
            }
            .flatMap { isPlanAdded in
                /// 2A. Update Existing Plan
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
                /// 2B. Add New Plan
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

    
    // MARK: - Old Data
    /// Saves multiple existing or new ``RemoteData`` using the values specified from `localData` and if it's in the range from `lastSyncedDate` to now
    /// and publishes whether the saving was successful or not.
    func syncOldLocalData(_ localData: [Data], lastSyncedDate: Date?) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error> {
        var allLocalData = localData
        
        /// 0. Exclude Today's Data
        let todaysDate = Calendar.current.startOfDay(for: .init())
        allLocalData.removeAll(where: { $0.date == todaysDate })
        
        Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬆️ Syncing Old Local Data | Last Synced Date: \(String(describing: lastSyncedDate))")
        Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬆️ Syncing Old Local Data | \(allLocalData.count) Items (Excluding Today's)")
        
        self.uploadOldDataCount = 0 /// a. Reset Update Count
        self.uploadOldDataTotalCount = 0
        
        guard !allLocalData.isEmpty else {
            return Just((false, false, []))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return self.isDatabaseAccessible()
            .flatMap { isAccessible -> AnyPublisher<([Data], [Data]), Never> in
                
                /// 1. Has Access to iCloud?
                /// 1A. Nope
                guard isAccessible else {
                    return Just(([], [])).eraseToAnyPublisher()
                }
                
                /// 1B. Yep
                /// - Get Data to Add
                var dataToAdd = allLocalData.filter { !$0.isSyncedToRemote }
                let limit = 100
                if dataToAdd.count >= limit {
                    dataToAdd = Array(dataToAdd[..<limit])
                }
                                
                Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬆️ Syncing Old Local Data | \(dataToAdd.count) Items to Upload")
                
                /// - Get Data to Update
                var dataToUpdate = [Data]()
                if let lastSyncedDate {
                    dataToUpdate = allLocalData.filter { data in
                        guard let date = data.date else {
                            return false
                        }
                        return data.isSyncedToRemote && date.isDateInRange(from: lastSyncedDate, to: todaysDate)
                    }
                }
                
                Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬆️ Syncing Old Local Data | \(dataToUpdate.count) Items to Update")
                
                self.uploadOldDataTotalCount = dataToAdd.count + dataToUpdate.count
                                
                return Just((dataToAdd, dataToUpdate)).eraseToAnyPublisher()
            }
            .map { (dataToAdd: [Data], dataToUpdate: [Data]) in
                /// Convert All to RemoteData Type
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
                /// 2A. Update Existing Data Items
                guard !remoteDataToAdd.isEmpty else {
                    return self.updateData(remoteDataToUpdate)
                        .flatMap { isUpdated in
                            let updatedRemoteData = isUpdated ? remoteDataToUpdate : []
                            
                            self.uploadOldDataCount = remoteDataToUpdate.count /// b. Update Upload Count
                            
                            return Just((false, isUpdated, updatedRemoteData))
                        }
                        .eraseToAnyPublisher()
                }
                /// 2B. Add New Data Items
                return self.addData(remoteDataToAdd)
                    .flatMap { isAdded in
                        self.uploadOldDataCount = remoteDataToAdd.count /// b. Update Upload Count

                        /// 2A. Update Existing Data Items
                        return self.updateData(remoteDataToUpdate)
                            .flatMap { isUpdated in
                                self.uploadOldDataCount = remoteDataToAdd.count + remoteDataToUpdate.count /// c. Update Download Count

                                let updatedRemoteData = isUpdated ? remoteDataToUpdate : []
                                return Just((isAdded, isUpdated, updatedRemoteData + remoteDataToAdd))
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Publishes all existing ``RemoteData`` records from ``RemoteDatabase`` that exists in the specified `localData` list.
    func syncOldRemoteData(_ localData: [Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error> {
        var allLocalData = localData
        
        /// 0. Exclude Today's Data
        allLocalData.removeAll(where: { $0.date == Calendar.current.startOfDay(for: .init()) })
        
        Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬇️ Syncing Old Remote Data | \(allLocalData.count) Local Items (Excluding Today's)")
        
        self.downloadOldDataTotalCount = 0 /// a. Update Download Count

        /// 1. Has Access to iCloud?
        return self.isDatabaseAccessible()
            .flatMap { isAccessible in
                /// 1A. Nope - Empty Data
                guard isAccessible else {
                    return Just([RemoteData]())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1B. Yep - Get All Existing Data from Remote
                return self.getAllData(excluding: date)
                    .eraseToAnyPublisher()
            }
            .flatMap { oldRemoteData in
                
                Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬇️ Syncing Old Remote Data | \(oldRemoteData.count) Remote Items")
                
                /// 2. Get All Data that Doesn't Exist from Remote
                var dataToAdd = [RemoteData]()
                
                oldRemoteData.forEach { (remoteData: RemoteData) in
                    /// remote data exists in local, dates saved starts at 00:00 time
                    if let _ = allLocalData.first(where: { $0.date == remoteData.date }) {
                        return
                    }
                    /// doesn't exist, need to be added
                    dataToAdd.append(remoteData)
                }
                
                self.downloadOldDataTotalCount = dataToAdd.count /// b. Update Download Count
                
                Logger.dataUsageRemoteRepository.debug("- SYNC REMOTE: 🌐 ⬇️ Syncing Old Remote Data | \(dataToAdd.count) Items to Add to Local")

                return Just(dataToAdd)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    
    // MARK: - Subscription
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
