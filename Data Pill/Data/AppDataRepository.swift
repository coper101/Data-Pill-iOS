//
//  AppDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

enum Keys: String {
    case usageType = "Usage_Type"
    case notification = "Notification"
    case startDatePlan = "Start_Data_Plan"
    case endDatePlan = "End_Data_Plan"
    case dataAmount = "Data_Amount"
    case dailyDataLimit = "Daily_Data_Limit"
    case totalDataLimit = "Total_Data_Limit"
}

class AppDataRepository: ObservableObject {
    
    @Published var usageType: ToggleItem = .daily
    @Published var isNotifOn = false
    
    @Published var startDate = "2022-09-12T10:44:00+0000".toDate()
    @Published var endDate = "2022-10-12T10:44:00+0000".toDate()
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    @Published var unit: Unit = .gb
    
    init() {
        loadAllData()
    }
    
    func loadAllData() {
        /// - Usage Type
        let usageTypeValue = LocalStorage.getItem(forKey: .usageType) ?? ToggleItem.daily.rawValue
        usageType = ToggleItem(rawValue: usageTypeValue) ?? .daily
        
        /// - Notification
        isNotifOn = LocalStorage.getBoolItem(forKey: .notification) ?? false
        
        /// - Data Plan
        dataAmount = LocalStorage.getDoubleItem(forKey: .dataAmount) ?? 0
        startDate = LocalStorage.getDateItem(forKey: .startDatePlan) ?? Date()
        endDate = LocalStorage.getDateItem(forKey: .endDatePlan) ?? Date()
        dataLimit = LocalStorage.getDoubleItem(forKey: .totalDataLimit) ?? 0
        dataLimitPerDay = LocalStorage.getDoubleItem(forKey: .dailyDataLimit) ?? 0
    }
    
    func setUsageType(_ type: String) {
        LocalStorage.setItem(type, forKey: .usageType)
    }
    
    func setIsNotification(_ isOn: Bool) {
        LocalStorage.setItem(isOn, forKey: .notification)
    }
    
    func setDataAmount(_ amount: Double) {
        LocalStorage.setItem(amount, forKey: .dataAmount)
    }
    
    func setStartDate(_ date: Date) {
        LocalStorage.setItem(date, forKey: .startDatePlan)
    }
    
    func setEndDate(_ date: Date) {
        LocalStorage.setItem(date, forKey: .endDatePlan)
    }
    
    func setDataLimit(_ amount: Double) {
        LocalStorage.setItem(amount, forKey: .totalDataLimit)
    }
    
    func setDataLimitPerDay(_ amount: Double) {
        LocalStorage.setItem(amount, forKey: .dailyDataLimit)
    }

}
