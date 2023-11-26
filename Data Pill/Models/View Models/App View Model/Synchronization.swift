//
//  Synchronization.swift
//  Data Pill
//
//  Created by Wind Versi on 24/6/23.
//

import Combine
import OSLog

extension AppViewModel {
    
    // MARK: - Re-Synchronization
    /// When Internet Connection is Republished, there is a delay, thus it will likely to fail at the beginning.
    /// Re-synchronize for those which failed.
    func reSynchronize() {
        if isSyncPlanCancelled {
            Logger.appModel.info("- SYNC PLAN: 🔁 Re-syncing Plan")
            syncPlan()
            isSyncPlanCancelled = false
        }
        if isSyncTodaysDataCancelled {
            Logger.appModel.debug("- SYNC TODAY'S DATA: 🔁 Re-syncing Today's Data ")
            syncTodaysData()
            isSyncTodaysDataCancelled = false
        }
        if isSyncOldDataCancelled {
            Logger.appModel.debug("- SYNC OLD DATA: 🔁 Re-syncing Old Data")
            syncOldThenRemoteData()
            isSyncOldDataCancelled = false
        }
    }
    
    // MARK: - Sync Plan
    func syncPlan() {
        /// 1A. Prevent Duplicate Calls
        guard !isSyncingPlan else {
            Logger.appModel.debug("- SYNC PLAN: 😭 Cancelled As It's Already In Progress")
            return
        }
        
        isSyncingPlan = true
        
        /// 1B. Check Internet Connection
        guard hasInternetConnection else {
            Logger.appModel.debug("- SYNC PLAN: 😭 No Internet Connection")
            isSyncingPlan = false
            isSyncPlanCancelled = true
            return
        }
        
        /// 2A-1. Download Existing `Plan` from `RemoteDatabase` and Update `Plan` in `Database`
        /// - when guide is shown, this means that user has intalled the app for the first time
        /// - check the user has an existing plan from remote
        guard wasGuideShown else {
            Logger.appModel.debug("- SYNC PLAN: ⬇️ Downloading Plan From Remote")
            syncLocalPlanFromRemote(updateToLatestPlanAfterwards: false)
            return
        }
        
        /// 2A-2.
        /// - when guide was dismissed and plan is using default values, the user might have logged in to an iCloud account for the first time
        /// - check the user has an existing `Plan` from `RemoteDatabase` and Update `Plan` in `Database`
        let isFreshPlan = (
            startDate == Calendar.current.startOfDay(for: .init()) &&
            endDate == Calendar.current.startOfDay(for: .init()) &&
            dataAmount == 0 &&
            dataLimit == 0 &&
            dataLimitPerDay == 0
        )
        
        guard !isFreshPlan else {
            Logger.appModel.debug("- SYNC PLAN: ⬇️ Downloading Plan From Remote")
            syncLocalPlanFromRemote(updateToLatestPlanAfterwards: true)
            return
        }
                
        Logger.appModel.debug("- SYNC PLAN: ⬆️ Uploading Local Plan To Remote")

        /// 2B. Upload Local `Plan` to `RemoteDatabase`
        /// - this happens regularly when user make changes to the plan
        syncLocalPlanToRemote()
    }
    
    func syncLocalPlanToRemote() {
        
        dataUsageRemoteRepository.syncPlan(
            startDate: self.startDate,
            endDate: self.endDate,
            dataAmount: self.dataAmount,
            dailyLimit: self.dataLimitPerDay,
            planLimit: self.dataLimit
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                let description = (error as? RemoteDatabaseError)?.description ?? ""
                Logger.appModel.debug("- SYNC PLAN: 😭 Failed To Upload Local Plan To Remote, ERROR: \(description)")
                self?.isSyncPlanCancelled = true

            case .finished:
                break
            }
            self?.isSyncingPlan = false
            
        } receiveValue: { isSavedOrUpdated in
            Logger.appModel.debug("- SYNC PLAN: \(isSavedOrUpdated ? "✅ Uploaded" : "😭 Failed to Upload") Local Plan To Remote")
        }
        .store(in: &cancellables)
    }
    
    func syncLocalPlanFromRemote(updateToLatestPlanAfterwards: Bool) {
        
        /// 1. Download Existing `Plan` from `RemoteDatabase`
        dataUsageRemoteRepository.getPlan()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    let description = (error as? RemoteDatabaseError)?.description ?? ""
                    Logger.appModel.debug("- SYNC PLAN: 😭 Failed To Get Existing Plan From Remote, ERROR: \(description)")
                    self?.isSyncPlanCancelled = true
                    
                case .finished:
                    break
                }
                
                self?.isSyncingPlan = false
                
            } receiveValue: { [weak self] remotePlan in
                guard let self else {
                    return
                }
                guard let remotePlan else {
                    Logger.appModel.debug("- SYNC PLAN: ⬆️ Existing Plan From Remote Doesn't Exist, Uploading a New Plan")
                    /// 2A. Upload New Local `Plan` to `RemoteDatabase`
                    self.syncLocalPlanToRemote()
                    return
                }
                Logger.appModel.debug("- SYNC PLAN: ✏️ Plan From Remote Exist, Updating Local Plan")
                
                /// 2B. Update `Plan` in `Database`.  Creates the `Plan` if it doesn't exist
                /// - prevent updating plan after adding to core data
                /// - can cause this ``syncPlan()`` to be fired again
                self.dataUsageRepository.updatePlan(
                    startDate: remotePlan.startDate,
                    endDate: remotePlan.endDate,
                    dataAmount: remotePlan.dataAmount,
                    dailyLimit: remotePlan.dailyLimit,
                    planLimit: remotePlan.planLimit,
                    updateToLatestPlanAfterwards: updateToLatestPlanAfterwards
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sync Today's Data
    func syncTodaysData() {
        /// 1A. Prevent Duplicate Calls
        guard !isSyncingTodaysData else {
            Logger.appModel.debug("- SYNC TODAY'S DATA: 😭 Cancelled As It's Already In Progress")
            return
        }
        
        isSyncingTodaysData = true

        /// 1B. Check Internet Connection
        guard hasInternetConnection else {
            Logger.appModel.debug("- SYNC TODAY'S DATA: 😭 No Internet Connection")
            isSyncingTodaysData = false
            isSyncTodaysDataCancelled = true
            return
        }
        
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            Logger.appModel.debug("- SYNC TODAY'S DATA: 😭 Can't Find Today's Data")
            return
        }
        
        /// 2. Download Latest Today's `Data` from Remote and Update `Data` in `Database`
        Logger.appModel.debug("- SYNC TODAY'S DATA: ⬇️ Downloading Today's Data From Remote")
        syncLocalTodaysDataFromRemote(todaysData)
            .flatMap { [weak self] (isLocalToBeUpdated: Bool, newDailyUsedData: Double) -> AnyPublisher<(Bool, Double, Bool), Error> in
                guard let self else {
                    return Just((isLocalToBeUpdated, newDailyUsedData, false))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                if isLocalToBeUpdated {
                    return Just((isLocalToBeUpdated, newDailyUsedData, false))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 3. Upload Local Today's `Data` to `RemoteDatase`
                Logger.appModel.debug("- SYNC TODAY'S DATA: ⬆️ Uploading Today's Data To Remote")
                return self.dataUsageRemoteRepository.syncTodaysData(todaysData, isSyncedToRemote: todaysData.isSyncedToRemote)
                    .flatMap { isRemoteUpdated in
                        Just((isLocalToBeUpdated, newDailyUsedData, isRemoteUpdated))
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    let description = (error as? RemoteDatabaseError)?.description ?? ""
                    Logger.appModel.debug("- SYNC TODAY'S DATA: 😭 Failed to Download Today's Data From Remote, ERROR: \(description)")
                    self?.isSyncTodaysDataCancelled = true
                    
                case .finished:
                    break
                }
                
                self?.isSyncingTodaysData = false

            } receiveValue: { [weak self] (isLocalToBeUpdated: Bool, newDailyUsedData: Double, isRemoteUpdated: Bool) in
                Logger.appModel.debug("- SYNC TODAY'S DATA: \(isLocalToBeUpdated ? "✅ Downloaded" : "ℹ️ No") Changes From Remote, New Daily Usage of \(newDailyUsedData)")
                Logger.appModel.debug("- SYNC TODAY'S DATA: \(isRemoteUpdated ? "✅ Uploaded" : "ℹ️ No") Changes To Remote")

                guard let self else {
                    return
                }
                
                var dailyUsedData: Double? = nil
                var isSyncedToRemote: Bool? = nil
                var lastSyncedToRemoteDate: Date? = nil
                                
                /// 3A. Update the `lastSyncToRemoteDate`, `isSyncedToRemote`, `dailyUsedData` attributes of the `Data` in `Database`
                /// - when new remote is higher than local's daily usage
                if isLocalToBeUpdated {
                    dailyUsedData = newDailyUsedData
                }
            
                /// - mark synced after syncing with remote
                if (isRemoteUpdated || isLocalToBeUpdated) && !todaysData.isSyncedToRemote {
                    isSyncedToRemote = true
                }

                /// - update last synced to remote date
                if (isRemoteUpdated || isLocalToBeUpdated) {
                    lastSyncedToRemoteDate = .init()
                    Logger.appModel.debug("- SYNC TODAY'S DATA: ✏️ Updating Local Today's Data")
                    self.updateTodaysData(
                        dailyUsedData: dailyUsedData,
                        isSyncedToRemote: isSyncedToRemote,
                        lastSyncedToRemoteDate: lastSyncedToRemoteDate
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    func syncLocalTodaysDataFromRemote(_ todaysData: Data) -> AnyPublisher<(Bool, Double), Error> {
        let date = Calendar.current.startOfDay(for: todaysData.date ?? .init())
        
        /// 1. Download Existing Today's `Data` from `RemoteDatabase`
        return dataUsageRemoteRepository.getData(on: date)
            .flatMap { (remoteData: RemoteData?) in
                guard let remoteData else {
                    Logger.appModel.debug("- SYNC TODAY'S DATA: ℹ️ Existing Today's Data From Remote Doesn't Exist")
                    return Just((false, 0.0))
                }
                
                let remoteDailyUsedData = remoteData.dailyUsedData
                let localDailyUsedData = todaysData.dailyUsedData
                
                Logger.appModel.debug("- SYNC TODAY'S DATA: ℹ️ Remote Daily Usage of \(remoteDailyUsedData)")
                Logger.appModel.debug("- SYNC TODAY'S DATA: ℹ️ Local Daily Usage of \(localDailyUsedData)")

                /// 2. Return the New Daily Used `Data`
                /// - only if remote data is more than local's
                /// - e.g. 10 MB (Remote)  >  5 MB (Local)
                if remoteDailyUsedData > localDailyUsedData {
                    Logger.appModel.debug("- SYNC TODAY'S DATA: ℹ️ Remote Daily Usage > Local Daily Usage, Local Needs To Be Updated")
                    return Just((true, remoteDailyUsedData))
                }
                return Just((false, 0.0))
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sync Old Data
    func syncOldThenRemoteData() {
        /// 1A. Prevent Duplicate Calls
        guard !isSyncingOldData else {
            Logger.appModel.debug("- SYNC OLD DATA: 😭 Cancelled As It's Already In Progress")
            return
        }
        
        isSyncingOldData = true
        
        /// 1B. Check Internet Connection
        guard hasInternetConnection else {
            Logger.appModel.debug("- SYNC OLD DATA: 😭 No Internet Connection")
            isSyncingOldData = false
            isSyncOldDataCancelled = true
            endBackgroundTask()
            return
        }
        
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            Logger.appModel.debug("- SYNC OLD DATA: 😭 Can't Find Today's Data")
            return
        }
        
        var localData = dataUsageRepository.getAllData()
        Logger.appModel.debug("- SYNC OLD DATA: ℹ️ \(localData.count) Items Found in Local")

        /// 2. Upload Old Local `Data`
        Logger.appModel.debug("- SYNC OLD DATA: ⬆️ Uploading Old Local Data")
        self.syncOldDataProgress?.updateOperation(operation: .upload)

        dataUsageRemoteRepository.syncOldLocalData(localData, lastSyncedDate: lastSyncedToRemoteDate)
            .flatMap { (areOldDataAdded: Bool, areOldDataUpdated: Bool, addedRemoteData: [RemoteData]) -> AnyPublisher<(Bool, Bool, [RemoteData], [RemoteData]), Error> in
              
                localData = self.dataUsageRepository.getAllData()
                let date = Calendar.current.startOfDay(for: todaysData.date ?? .init())
                Logger.appModel.debug("- SYNC OLD DATA: ℹ️ \(localData.count) Items Found in Local")

                /// 3. Download Old Remote `Data`
                Logger.appModel.debug("- SYNC OLD DATA: ⬇️ Downloading Old Local Data")
                
                DispatchQueue.main.async {
                    self.syncOldDataProgress?.updateOperation(operation: .download)
                }

                return self.dataUsageRemoteRepository.syncOldRemoteData(localData, excluding: date)
                    .flatMap { oldRemoteData in
                        Just((areOldDataAdded, areOldDataUpdated, addedRemoteData, oldRemoteData))
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    let description = (error as? RemoteDatabaseError)?.description ?? ""
                    Logger.appModel.debug("- SYNC OLD DATA: 😭 Failed to Upload or Download Old Data, ERROR: \(description)")

                    self?.syncOldDataProgress = nil
                    self?.isSyncOldDataCancelled = true
                    self?.isSyncingOldData = false
                    self?.endBackgroundTask()
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (areOldDataAdded: Bool, areOldDataUpdated: Bool, addedRemoteData: [RemoteData], oldRemoteData: [RemoteData]) in
                                
                Logger.appModel.debug("- SYNC OLD DATA: \(areOldDataAdded ? "✅ Uploaded New Old Local Data" : "ℹ️ No New Local Data Uploaded")")
                Logger.appModel.debug("- SYNC OLD DATA: \(areOldDataUpdated ? "✅ Uploaded Existing Old Local Data" : "ℹ️ No Existing Local Data Uploaded")")
                
                guard let self else {
                    return
                }
                
                /// 4A. Uploaded to Remote:
                /// - Update the `lastSyncToRemoteDate` and `isSyncedToRemote` attributes of the `Data` in `Database`
                ///
                /// 4B. Downloaded from Remote:
                /// - Add new `Data` to `RemoteDatabase`

                /// 4C.
                /// - Update `lastSyncDateToRemoteDate` on updated
                /// - Update loading indicator to stop animating on updated
                /// - Stop Background Task on updated
                if !addedRemoteData.isEmpty && (areOldDataAdded || areOldDataUpdated) {
                    Logger.appModel.debug("- SYNC OLD DATA: ✏️ Updating Sync State of Local Data Uploaded")
                    
                    /// 4A.
                    self.dataUsageRepository.updateData(addedRemoteData)
                        .flatMap { areUpdated in
                            
                            Logger.appModel.debug("- SYNC OLD DATA: \(areUpdated ? "✅ Updated" : "😭 Failed to Update") Sync State of Local Data Uploaded, \(addedRemoteData.count) Items")
                            
                            Logger.appModel.debug("- SYNC OLD DATA: ✏️ Adding New Local Data From Remote")
                            
                            guard !oldRemoteData.isEmpty else {
                                return Just(false)
                                    .eraseToAnyPublisher()
                            }
                            /// 4B.
                            return self.dataUsageRepository.addData(oldRemoteData, isSyncedToRemote: true)
                        }
                        .sink { areAdded in
                            
                            Logger.appModel.debug("- SYNC OLD DATA: \(areAdded ? "✅ Added New Local Data" : "ℹ️ Nothing To Add New Local Data"), \(oldRemoteData.count) Items")
                            
                            /// 4C.
                            self.onSyncedOldTheRemoteData()
                        }
                        .store(in: &cancellables)
                    return
                }
                
                if !oldRemoteData.isEmpty {
                    
                    /// 4B.
                    Logger.appModel.debug("- SYNC OLD DATA: ✏️ Adding New Local Data From Remote")
                    self.dataUsageRepository.addData(oldRemoteData, isSyncedToRemote: true)
                        .sink { areAdded in
                            
                            DispatchQueue.main.async {
                                self.syncOldDataProgress?.updateSynced(count: oldRemoteData.count)
                            }
                            Logger.appModel.debug("- SYNC OLD DATA: \(areAdded ? "✅ Added" : "😭 Failed to Add") New Local Data, \(oldRemoteData.count) Items")
                            
                            /// 4C.
                            self.onSyncedOldTheRemoteData()
                        }
                        .store(in: &self.cancellables)
                    return
                }
                
                /// 4C.
                self.onSyncedOldTheRemoteData()
            }
            .store(in: &cancellables)
    }
    
    private func onSyncedOldTheRemoteData() {
        appDataRepository.setLastSyncedToRemoteDate(.init())
        isSyncingOldData = false
        syncOldDataProgress = nil
        endBackgroundTask()
    }
    
    func syncRemoteOnChange() {
        dataUsageRemoteRepository.subscribeToRemotePlanChanges()
            .flatMap { isPlanSubscribed in
                Logger.appModel.debug("syncRemoteOnChange - isPlanSubscribed: \(isPlanSubscribed)")
                return self.dataUsageRemoteRepository.subscribeToRemoteTodaysDataChanges()
            }
            .sink { isTodaysDataSubscribed in
                Logger.appModel.debug("syncRemoteOnChange - isTodaysDataSubscribed: \(isTodaysDataSubscribed)")
            }
            .store(in: &cancellables)
    }
}
