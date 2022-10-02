//
//  HomeActions.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation

class HomeActions {
    
    // MARK: - Data Source
    let appState: AppState
    let networkDataRepo: NetworkDataRepository
    let dataModelRepo: DataModelRepository
    
    init(
        appState: AppState,
        networkDataRepo: NetworkDataRepository,
        dataModelRepo: DataModelRepository
    ) {
        self.appState = appState
        self.networkDataRepo = networkDataRepo
        self.dataModelRepo = dataModelRepo
    }
    
    // MARK: - Actions
    func observeForDataChanges() {
        observeUsageType()
        observeNotification()
        observeStartDate()
        observeEndDate()
        observeDataAmount()
        observeDailyDataLimit()
        observeTotalDataLimit()
    }
    
    func refreshUsedDataToday() {
        networkDataRepo.publishedUsedData()
                
        // get total used data from our repository
        let totalUsedData = networkDataRepo.totalUsedData
        
        // edit todays data
        guard let todaysDataIndex = appState.data.firstIndex(
            where: {
                guard let date = $0.date else {
                    return false
                }
                return date.isToday()
            }
        ) else {
            return
        }
                
        let todaysData = appState.data[todaysDataIndex]; print("todaysData: ", todaysData)
        let currentTotalUsedData = todaysData.totalUsedData
        let isTotalValid = totalUsedData > currentTotalUsedData
        
        if todaysData.hasLastTotal, isTotalValid {
            let newDataAmount = totalUsedData - currentTotalUsedData
            todaysData.dailyUsedData += newDataAmount
        }
        
        todaysData.totalUsedData = totalUsedData
        todaysData.hasLastTotal = true
        
        print("todaysData edited: ", todaysData)
        
    }
    
    func loadUserPreferences() {
        /// Data
        /// - Usage Type
        let usageTypeValue = AppStorage.getItem(forKey: .usageType) ?? ToggleItem.daily.rawValue
        appState.usageType = ToggleItem(rawValue: usageTypeValue) ?? .daily
        
        /// - Notification
        let isNotifOn = AppStorage.getBoolItem(forKey: .notification)
        appState.isNotifOn = isNotifOn ?? false
        
        /// - Data Plan
        let dataAmount = AppStorage.getDoubleItem(forKey: .dataAmount) ?? 0
        appState.dataAmount = dataAmount
        
        let startDate = AppStorage.getDateItem(forKey: .startDatePlan) ?? Date()
        appState.startDate = startDate
        
        let endDate = AppStorage.getDateItem(forKey: .endDatePlan) ?? Date()
        appState.endDate = endDate
        
        /// - Data Plan Limit
        let dataLimit = AppStorage.getDoubleItem(forKey: .totalDataLimit) ?? 0
        appState.dataLimit = dataLimit
        
        let dataLimitPerDay = AppStorage.getDoubleItem(forKey: .dailyDataLimit) ?? 0
        appState.dataLimitPerDay = dataLimitPerDay
        
        /// UI
        appState.dataValue = "\(dataAmount.toInt())"
        appState.startDateValue = startDate
        appState.endDateValue = endDate
        
        appState.dataLimitValue = "\(dataLimit.toInt())"
        appState.dataLimitPerDayValue = "\(dataLimitPerDay.toInt())"
    }
    
    // MARK: - Data Changes
    func observeUsageType() {
        appState.$usageType
            .sink { AppStorage.setItem($0.rawValue, forKey: .usageType) }
            .store(in: &appState.cancellables)
    }
    
    func observeNotification() {
        appState.$isNotifOn
            .sink { AppStorage.setItem($0, forKey: .notification) }
            .store(in: &appState.cancellables)
    }
    
    func observeStartDate() {
        appState.$startDate
            .sink { AppStorage.setItem($0, forKey: .startDatePlan) }
            .store(in: &appState.cancellables)
    }
    
    func observeEndDate() {
        appState.$endDate
            .sink { AppStorage.setItem($0, forKey: .endDatePlan) }
            .store(in: &appState.cancellables)
    }
    
    func observeDataAmount() {
        appState.$dataAmount
            .sink { AppStorage.setItem($0, forKey: .dataAmount) }
            .store(in: &appState.cancellables)
    }
    
    func observeDailyDataLimit() {
        appState.$dataLimitPerDay
            .sink { AppStorage.setItem($0, forKey: .dailyDataLimit) }
            .store(in: &appState.cancellables)
    }
    
    func observeTotalDataLimit() {
        appState.$dataLimit
            .sink { AppStorage.setItem($0, forKey: .totalDataLimit) }
            .store(in: &appState.cancellables)
    }
    
}
