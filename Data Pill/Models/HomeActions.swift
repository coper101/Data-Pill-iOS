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
    
    init(
        appState: AppState
    ) {
        self.appState = appState
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
                
//        // get total used data from our repository
//        let totalUsedData = networkDataRepository.totalUsedData
//        
//        // edit todays data
//        guard let todaysDataIndex = dataModelRepository.data.firstIndex(
//            where: {
//                guard let date = $0.date else {
//                    return false
//                }
//                return date.isToday()
//            }
//        ) else {
//            return
//        }
//                
//        let todaysData = appState.data[todaysDataIndex]; print("todaysData: ", todaysData)
//        let currentTotalUsedData = todaysData.totalUsedData
//        let isTotalValid = totalUsedData > currentTotalUsedData
//        
//        if todaysData.hasLastTotal, isTotalValid {
//            let newDataAmount = totalUsedData - currentTotalUsedData
//            todaysData.dailyUsedData += newDataAmount
//        }
//        
//        todaysData.totalUsedData = totalUsedData
//        todaysData.hasLastTotal = true
//        
//        print("todaysData edited: ", todaysData)
        
    }
    
    // MARK: - Data Changes
    func observeUsageType() {
        appState.$usageType
            .sink { LocalStorage.setItem($0.rawValue, forKey: .usageType) }
            .store(in: &appState.cancellables)
    }
    
    func observeNotification() {
        appState.$isNotifOn
            .sink { LocalStorage.setItem($0, forKey: .notification) }
            .store(in: &appState.cancellables)
    }
    
    func observeStartDate() {
        appState.$startDate
            .sink { LocalStorage.setItem($0, forKey: .startDatePlan) }
            .store(in: &appState.cancellables)
    }
    
    func observeEndDate() {
        appState.$endDate
            .sink { LocalStorage.setItem($0, forKey: .endDatePlan) }
            .store(in: &appState.cancellables)
    }
    
    func observeDataAmount() {
        appState.$dataAmount
            .sink { LocalStorage.setItem($0, forKey: .dataAmount) }
            .store(in: &appState.cancellables)
    }
    
    func observeDailyDataLimit() {
        appState.$dataLimitPerDay
            .sink { LocalStorage.setItem($0, forKey: .dailyDataLimit) }
            .store(in: &appState.cancellables)
    }
    
    func observeTotalDataLimit() {
        appState.$dataLimit
            .sink { LocalStorage.setItem($0, forKey: .totalDataLimit) }
            .store(in: &appState.cancellables)
    }
    
}
