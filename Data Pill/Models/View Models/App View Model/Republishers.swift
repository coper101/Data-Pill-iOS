//
//  Republishers.swift
//  Data Pill
//
//  Created by Wind Versi on 24/6/23.
//

import OSLog

extension AppViewModel {
    
    func republishAppData() {
        appDataRepository.wasGuideShownPublisher
            .sink { [weak self] in self?.wasGuideShown = $0 }
            .store(in: &cancellables)
        
        appDataRepository.isPlanActivePublisher
            .sink { [weak self] in self?.isPlanActive = $0 }
            .store(in: &cancellables)
        
        appDataRepository.usageTypePublisher
            .sink { [weak self] in self?.usageType = $0 }
            .store(in: &cancellables)
        
        appDataRepository.isPeriodAutoPublisher
            .sink { [weak self] in self?.isPeriodAuto = $0 }
            .store(in: &cancellables)
        
        appDataRepository.unitPublisher
            .sink { [weak self] in self?.unit = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataPlusStepperValuePublisher
            .sink { [weak self] in self?.dataPlusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataMinusStepperValuePublisher
            .sink { [weak self] in self?.dataMinusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPlusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitPlusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitMinusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitMinusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPerDayPlusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitPerDayPlusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPerDayMinusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitPerDayMinusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.lastSyncedToRemoteDatePublisher
            .sink { [weak self] in self?.lastSyncedToRemoteDate = $0 }
            .store(in: &cancellables)
        
        appDataRepository.isDarkModePublisher
            .sink { [weak self] in self?.isDarkMode = $0 }
            .store(in: &cancellables)
        
        appDataRepository.hasNotificationPublisher
            .sink { [weak self] in self?.hasNotification = $0 }
            .store(in: &cancellables)
    }
    
    func republishDataUsage() {
        dataUsageRepository.planPublisher
            .sink { [weak self] plan in
                guard let plan, let self else {
                    return
                }
                self.startDate = plan.startDate ?? .init()
                self.endDate = plan.endDate ?? .init()
                self.dataAmount = plan.dataAmount
                self.dataLimit = plan.planLimit
                self.dataLimitPerDay = plan.dailyLimit
                                
                self.syncPlan()
            }
            .store(in: &cancellables)
        
        dataUsageRepository.todaysDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let todaysData = $0 {
                    self?.todaysData = todaysData
                }
            }
            .store(in: &cancellables)
        
        dataUsageRepository.thisWeeksDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                self.thisWeeksData = $0
                self.totalUsedDataPlan = self.dataUsageRepository
                    .getTotalUsedData(from: self.startDate, to: self.endDate)
            }
            .store(in: &cancellables)
        
        dataUsageRepository.dataErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dataError = $0 }
            .store(in: &cancellables)
    }
    
    func republishDataUsageRemote() {
        
        dataUsageRemoteRepository.uploadOldDataCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.syncOldDataProgress?.updateSynced(count: $0) }
            .store(in: &cancellables)
        
        dataUsageRemoteRepository.uploadOldDataTotalCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.syncOldDataProgress?.updateTotal(count: $0) }
            .store(in: &cancellables)
        
        dataUsageRemoteRepository.downloadOldDataTotalCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.syncOldDataProgress?.updateTotal(count: $0) }
            .store(in: &cancellables)
    }
    
    func republishNetworkData() {
        networkDataRepository.totalUsedDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.totalUsedData = $0 }
            .store(in: &cancellables)
    }
    
    func republishNetworkConnection() {
        networkConnectionRepository.hasInternetConnectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasInternetConnection in
                guard let self = self else {
                    return
                }
                self.hasInternetConnection = hasInternetConnection
                Logger.networkRepository.debug("- NETWORK CONNECTION: 🛜 \(self.hasInternetConnection ? "Online" : "Offline")")

                guard self.hasInternetConnection else {
                    return
                }
                self.reSynchronize()
            }
            .store(in: &cancellables)
    }
    
    func republishToast() {
        toastTimer.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.toastMessage = $0 }
            .store(in: &cancellables)
    }
}
