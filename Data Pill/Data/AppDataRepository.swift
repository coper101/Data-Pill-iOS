//
//  AppDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

// MARK: - Protocol
protocol AppDataRepositoryProtocol {
    var usageType: ToggleItem { get set }
    var usageTypePublisher: Published<ToggleItem>.Publisher { get }
    
    var isNotifOn: Bool { get set }
    var isNotifOnPublisher: Published<Bool>.Publisher { get }
    
    var startDate: Date { get set }
    var startDatePublisher: Published<Date>.Publisher { get }
    
    var endDate: Date { get set }
    var endDatePublisher: Published<Date>.Publisher { get }
    
    var dataAmount: Double { get set }
    var dataAmountPublisher: Published<Double>.Publisher { get }
    
    var dataLimit: Double { get set }
    var dataLimitPublisher: Published<Double>.Publisher { get }
    
    var dataLimitPerDay: Double { get set }
    var dataLimitPerDayPublisher: Published<Double>.Publisher { get }
    
    var unit: Unit { get set }
    var unitPublisher: Published<Unit>.Publisher { get }
    
    func setUsageType(_ type: String) -> Void
    func setIsNotification(_ isOn: Bool) -> Void
    func setDataAmount(_ amount: Double) -> Void
    func setStartDate(_ date: Date) -> Void
    func setEndDate(_ date: Date) -> Void
    func setDataLimit(_ amount: Double) -> Void
    func setDataLimitPerDay(_ amount: Double) -> Void
}

// MARK: - Implementation
enum Keys: String {
    case usageType = "Usage_Type"
    case notification = "Notification"
    case startDatePlan = "Start_Data_Plan"
    case endDatePlan = "End_Data_Plan"
    case dataAmount = "Data_Amount"
    case dailyDataLimit = "Daily_Data_Limit"
    case totalDataLimit = "Total_Data_Limit"
}

final class AppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isNotifOn = false
    var isNotifOnPublisher: Published<Bool>.Publisher { $isNotifOn }
    
    @Published var startDate = Date()
    var startDatePublisher: Published<Date>.Publisher { $startDate }
    
    @Published var endDate = Date()
    var endDatePublisher: Published<Date>.Publisher { $endDate}

    @Published var dataAmount = 0.0
    var dataAmountPublisher: Published<Double>.Publisher { $dataAmount }
    
    @Published var dataLimit = 0.0
    var dataLimitPublisher: Published<Double>.Publisher { $dataLimit }

    @Published var dataLimitPerDay = 0.0
    var dataLimitPerDayPublisher: Published<Double>.Publisher { $dataLimitPerDay }

    @Published var unit: Unit = .gb
    var unitPublisher: Published<Unit>.Publisher { $unit }
    
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

class MockAppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isNotifOn = false
    var isNotifOnPublisher: Published<Bool>.Publisher { $isNotifOn }
    
    @Published var startDate = Date()
    var startDatePublisher: Published<Date>.Publisher { $startDate }
    
    @Published var endDate = Date()
    var endDatePublisher: Published<Date>.Publisher { $endDate}

    @Published var dataAmount = 0.0
    var dataAmountPublisher: Published<Double>.Publisher { $dataAmount }
    
    @Published var dataLimit = 0.0
    var dataLimitPublisher: Published<Double>.Publisher { $dataLimit }

    @Published var dataLimitPerDay = 0.0
    var dataLimitPerDayPublisher: Published<Double>.Publisher { $dataLimitPerDay }

    @Published var unit: Unit = .gb
    var unitPublisher: Published<Unit>.Publisher { $unit }
    
    init(
        usageType: ToggleItem = .daily,
        isNotifOn: Bool = false,
        startDate: Date = Date(),
        endDate: Date = Date(),
        dataAmount: Double = 0.0,
        dataLimit: Double = 0.0,
        dataLimitPerDay: Double = 0.0,
        unit: Unit = .gb
    ) {
        self.usageType = usageType
        self.isNotifOn = isNotifOn
        self.startDate = startDate
        self.endDate = endDate
        self.dataAmount = dataAmount
        self.dataLimit = dataLimit
        self.dataLimitPerDay = dataLimitPerDay
        self.unit = unit
    }
    
    func setUsageType(_ type: String) {
        usageType = ToggleItem(rawValue: type) ?? .daily
    }
    
    func setIsNotification(_ isOn: Bool) {
        self.isNotifOn = isOn
    }
    
    func setDataAmount(_ amount: Double) {
        dataAmount = amount
    }
    
    func setStartDate(_ date: Date) {
        startDate = date
    }
    
    func setEndDate(_ date: Date) {
        endDate = date
    }
    
    func setDataLimit(_ amount: Double) {
        dataLimit = amount
    }
    
    func setDataLimitPerDay(_ amount: Double) {
        dataLimitPerDay = amount
    }
}

