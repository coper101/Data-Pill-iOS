//
//  Observers.swift
//  Data Pill
//
//  Created by Wind Versi on 24/6/23.
//

import OSLog

extension AppViewModel {
    
    func observeSynchronization() {
        
        $isSyncingPlan
            .combineLatest($isSyncingTodaysData, $isSyncingOldData)
            .sink { [weak self] in self?.isSyncing = $0 || $1 || $2 }
            .store(in: &cancellables)
    }
    
    func observePlanSettings() {
        /// UI
        $isPlanActive
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in
                self?.didChangeIsPlanActive($0)
                self?.appDataRepository.setIsPlanActive($0)
            }
            .store(in: &cancellables)
        
        $usageType
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in self?.appDataRepository.setUsageType($0.rawValue) }
            .store(in: &cancellables)
        
        $isPeriodAuto
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in self?.appDataRepository.setIsPeriodAuto($0) }
            .store(in: &cancellables)
        
        /// Data Usage
        $totalUsedData
            .removeDuplicates()
            .sink { [weak self] in self?.refreshUsedDataToday($0) }
            .store(in: &cancellables)
        
    }
    
    func observeRemoteData() {
        
        NotificationCenter.default
            .publisher(for: .plan)
            .sink { [weak self] _ in self?.syncLocalPlanFromRemote(updateToLatestPlanAfterwards: true) }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .todaysData)
            .sink { [weak self] _ in self?.syncTodaysData() }
            .store(in: &cancellables)
    }
    
    func observeEditPlan() {
        
        $isDataPlanEditing
            .dropFirst()
            .sink(receiveValue: didChangeIsDataPlanEditing)
            .store(in: &cancellables)
        
        $isDataLimitEditing
            .dropFirst()
            .sink(receiveValue: didChangeIsDataLimitEditing)
            .store(in: &cancellables)
        
        $isDataLimitPerDayEditing
            .dropFirst()
            .sink(receiveValue: didChangeIsDataLimitPerDayEditing)
            .store(in: &cancellables)
    }
    
    func observeDataErrors() {
        
        $dataError
            .sink(receiveValue: didChangeDataError)
            .store(in: &cancellables)
    }
    
    func observeSettings() {
        $isDarkMode
            .removeDuplicates()
            .sink { [weak self] in self?.appDataRepository.setIsDarkMode($0) }
            .store(in: &cancellables)
        
        $hasNotification
            .removeDuplicates()
            .sink { [weak self] in self?.appDataRepository.setHasNotification($0) }
            .store(in: &cancellables)
    }
}
