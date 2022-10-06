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
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - Actions
    func refreshUsedDataToday() {
        
        // total data used from network data source
        let totalUsedData = 1.0 // appState.totalUsedData
        
        // calculate new amount used data
        var amountUsed = 0.0
        if let recentDataWithHasTotal = appState.dataUsageRepository.getDataWithHasTotal() {
            amountUsed = totalUsedData - recentDataWithHasTotal.totalUsedData
        }
        
        // new amount can't be calculated since device was restarted
        if amountUsed < 0 {
            amountUsed = 0
        }
        
        let todaysData = appState.todaysData
        todaysData.dailyUsedData += amountUsed
        todaysData.totalUsedData = totalUsedData
        todaysData.hasLastTotal = true
        
        appState.dataUsageRepository.updateData(item: todaysData)

        print("todaysData edited: ", todaysData)
    }
    
}
