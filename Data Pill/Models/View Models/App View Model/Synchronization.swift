//
//  Synchronization.swift
//  Data Pill
//
//  Created by Wind Versi on 24/6/23.
//

import Combine
import OSLog

extension AppViewModel {
    
    // MARK: - Sync Plan
    func syncPlan() {
        isSyncingPlan = true
        
        /// 1. Check Internet Connection
        guard hasInternetConnection else {
            Logger.appModel.debug("syncPlan - error: no internet connection")
            isSyncingPlan = false
            return
        }
        
        /// 2A-1. Download Existing `Plan` from `RemoteDatabase` and Update `Plan` in `Database`
        /// - when guide is shown, this means that user has intalled the app for the first time
        /// - check the user has an existing plan from remote
        guard wasGuideShown else {
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
            syncLocalPlanFromRemote(updateToLatestPlanAfterwards: true)
            return
        }
                
        /// 2B. Upload Local `Plan` to `RemoteDatabase`
        /// - this happens regularly when user make changes to the plan
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
                Logger.appModel.debug("syncPlan - is plan saved or updated error: \(error.localizedDescription)")
            case .finished:
                break
            }
            self?.isSyncingPlan = false
            
        } receiveValue: { isSavedOrUpdated in
            Logger.appModel.debug("syncPlan - is plan saved or updated: \(isSavedOrUpdated)")
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
                    Logger.appModel.debug("syncLocalPlanFromRemote - get existing plan error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                self?.isSyncingPlan = false
                
            } receiveValue: { [weak self] remotePlan in
                guard let self else {
                    return
                }
                guard let remotePlan else {
                    Logger.appModel.debug("syncLocalPlanFromRemote - get existing plan doesn't exist")
                    return
                }
                Logger.appModel.debug("syncLocalPlanFromRemote - get existing plan: \(remotePlan.startDate) - \(remotePlan.endDate)")
                
                /// 2. Update `Plan` in `Database`.  Creates the `Plan` if it doesn't exist
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
        isSyncingTodaysData = true

        /// 1. Check Internet Connection
        guard hasInternetConnection else {
            Logger.appModel.debug("syncTodaysData - error: no internet connection")
            isSyncingTodaysData = false
            return
        }
        
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            Logger.appModel.debug("syncTodaysData - error: today's data is nil")
            return
        }
        
        /// 2. Download Latest Today's `Data` from Remote and Update `Data` in `Database`
        syncLocalTodaysDataFromRemote(todaysData)
            .flatMap { [weak self] (isLocalToBeUpdated: Bool, newDailyUsedData: Double) -> AnyPublisher<(Bool, Double, Bool), Never> in
                guard let self else {
                    return Just((isLocalToBeUpdated, newDailyUsedData, false)).eraseToAnyPublisher()
                }
                if isLocalToBeUpdated {
                    return Just((isLocalToBeUpdated, newDailyUsedData, false)).eraseToAnyPublisher()
                }
                /// 3. Upload Local Today's `Data` to `RemoteDatase`
                return self.dataUsageRemoteRepository.syncTodaysData(todaysData, isSyncedToRemote: todaysData.isSyncedToRemote)
                    .replaceError(with: false)
                    .flatMap { isRemoteUpdated in
                        Just((isLocalToBeUpdated, newDailyUsedData, isRemoteUpdated))
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isLocalToBeUpdated: Bool, newDailyUsedData: Double, isRemoteUpdated: Bool) in
                Logger.appModel.debug("syncTodaysData - local today's data to be updated: \(isLocalToBeUpdated)")
                Logger.appModel.debug("syncTodaysData - new daily used data: \(newDailyUsedData)")
                Logger.appModel.debug("syncTodaysData - remote today's data updated: \(isRemoteUpdated)")

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
                    self.updateTodaysData(
                        dailyUsedData: dailyUsedData,
                        isSyncedToRemote: isSyncedToRemote,
                        lastSyncedToRemoteDate: lastSyncedToRemoteDate
                    )
                }

                /// 3B.
                self.isSyncingTodaysData = false
            }
            .store(in: &cancellables)
    }
    
    func syncLocalTodaysDataFromRemote(_ todaysData: Data) -> AnyPublisher<(Bool, Double), Never> {
        let date = Calendar.current.startOfDay(for: todaysData.date ?? .init())
        Logger.appModel.debug("syncLocalTodayDataFromRemote - today's date: \(date)")
                
        /// 1. Download Existing Today's `Data` from `RemoteDatabase`
        return dataUsageRemoteRepository.getData(on: date)
            .replaceError(with: nil)
            .flatMap { (remoteData: RemoteData?) in
                guard let remoteData else {
                    Logger.appModel.debug("syncLocalTodayDataFromRemote - get existing todays data doesn't exist")
                    return Just((false, 0.0))
                }
                
                let remoteDailyUsedData = remoteData.dailyUsedData
                let localDailyUsedData = todaysData.dailyUsedData
                
                Logger.appModel.debug("syncLocalTodayDataFromRemote - get existing todays data from remote: \(remoteDailyUsedData)")
                Logger.appModel.debug("syncLocalTodayDataFromRemote - get existing todays data from local: \(localDailyUsedData)")

                /// 2. Return the New Daily Used `Data`
                /// - only if remote data is more than local's
                /// - e.g. 10 MB (Remote)  >  5 MB (Local)
                if remoteDailyUsedData > localDailyUsedData {
                    Logger.appModel.debug("syncLocalTodayDataFromRemote - remote: \(remoteDailyUsedData) > local \(localDailyUsedData)")
                    return Just((true, remoteDailyUsedData))
                }
                return Just((false, 0.0))
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sync Old Data
    func syncOldThenRemoteData() {
        isSyncingOldData = true
        
        /// 1. Check Internet Connection
        guard hasInternetConnection else {
            Logger.appModel.debug("syncOldThenRemoteData - error: no internet connection")
            isSyncingOldData = false
            endBackgroundTask()
            return
        }
        
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            Logger.appModel.debug("syncOldThenRemoteData - error: today's data is nil")
            return
        }
        
        var localData = dataUsageRepository.getAllData()
        Logger.appModel.debug("syncOldThenRemoteData - all local data dates: \(localData.compactMap(\.date))")

        /// 2. Upload Old Local `Data`
        dataUsageRemoteRepository.syncOldLocalData(localData, lastSyncedDate: lastSyncedToRemoteDate)
            .flatMap { (areOldDataAdded: Bool, areOldDataUpdated: Bool, addedRemoteData: [RemoteData]) -> AnyPublisher<(Bool, Bool, [RemoteData], [RemoteData]), Error> in
              
                localData = self.dataUsageRepository.getAllData()
                let date = Calendar.current.startOfDay(for: todaysData.date ?? .init())

                /// 3. Download Old Remote `Data`
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
                    Logger.appModel.debug("syncOldThenRemoteData - error: \(error.localizedDescription)")
                    
                    self?.isSyncingOldData = false
                    self?.endBackgroundTask()
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (areOldDataAdded: Bool, areOldDataUpdated: Bool, addedRemoteData: [RemoteData], oldRemoteData: [RemoteData]) in
                                
                Logger.appModel.debug("syncOldThenRemoteData - old local data added to remote database: \(areOldDataAdded)")
                Logger.appModel.debug("syncOldThenRemoteData - old local data updated to remote database: \(areOldDataUpdated)")
                
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
                    
                    /// 4A.
                    self.dataUsageRepository.updateData(addedRemoteData)
                        .flatMap { areUpdated in
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data to update count: \(addedRemoteData.count)")
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data updated to local database: \(areUpdated)")
                            
                            /// 4B.
                            return self.dataUsageRepository.addData(oldRemoteData, isSyncedToRemote: true)
                        }
                        .sink { areAdded in
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data to add count: \(oldRemoteData.count)")
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data added to local database: \(areAdded)")
                            
                            /// 4C.
                            self.onSyncedOldTheRemoteData()
                        }
                        .store(in: &cancellables)
                    return
                }
                
                if !oldRemoteData.isEmpty {
                    
                    /// 4B.
                    self.dataUsageRepository.addData(oldRemoteData, isSyncedToRemote: true)
                        .sink { areAdded in
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data to add count: \(oldRemoteData.count)")
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data added to local database: \(areAdded)")
                            
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
