//
//  AppDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

// MARK: - Protocol
protocol AppDataRepositoryProtocol {

    /// [1] Was Guide Shown
    var wasGuideShown: Bool { get set }
    var wasGuideShownPublisher: Published<Bool>.Publisher { get }
    
    func setWasGuideShown(_ wasShown: Bool) -> Void
    
    /// [2] Is Plan Active
    var isPlanActive: Bool { get set }
    var isPlanActivePublisher: Published<Bool>.Publisher { get }
    
    func setIsPlanActive(_ isActive: Bool) -> Void

    /// [3] Usage Type
    var usageType: ToggleItem { get set }
    var usageTypePublisher: Published<ToggleItem>.Publisher { get }
    
    func setUsageType(_ type: String) -> Void
    
    /// [4] Is Period Automatic
    var isPeriodAuto: Bool { get set }
    var isPeriodAutoPublisher: Published<Bool>.Publisher { get }
    
    func setIsPeriodAuto(_ isOn: Bool) -> Void
    
    /// [5] Unit
    var unit: Unit { get set }
    var unitPublisher: Published<Unit>.Publisher { get }
    
    /// [6] Data Plus Stepper Value
    var dataPlusStepperValue: Double { get set }
    var dataPlusStepperValuePublisher: Published<Double>.Publisher { get }
    
    func setPlusStepperValue(_ amount: Double, type: StepperValueType)

    /// [7] Data Minus Stepper Value
    var dataMinusStepperValue: Double { get set }
    var dataMinusStepperValuePublisher: Published<Double>.Publisher { get }
    
    func setMinusStepperValue(_ amount: Double, type: StepperValueType)
    
    var dataLimitPerDayPlusStepperValue: Double { get set }
    var dataLimitPerDayPlusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitPerDayMinusStepperValue: Double { get set }
    var dataLimitPerDayMinusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitPlusStepperValue: Double { get set }
    var dataLimitPlusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitMinusStepperValue: Double { get set }
    var dataLimitMinusStepperValuePublisher: Published<Double>.Publisher { get }
    
    /// [8] Last Synced to Remote Date
    var lastSyncedToRemoteDate: Date? { get set }
    var lastSyncedToRemoteDatePublisher: Published<Date?>.Publisher { get }
    
    func setLastSyncedToRemoteDate(_ date: Date)
    
    func loadAllData(unit: Unit?, usageType: ToggleItem?) -> Void
}



// MARK: - App Implementation
final class AppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    // MARK: - Data
    /// [1]
    @Published var wasGuideShown = false
    var wasGuideShownPublisher: Published<Bool>.Publisher { $wasGuideShown }
    
    /// [2]
    @Published var isPlanActive = false
    var isPlanActivePublisher: Published<Bool>.Publisher { $isPlanActive }
    
    /// [3]
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    /// [4]
    @Published var isPeriodAuto = false
    var isPeriodAutoPublisher: Published<Bool>.Publisher { $isPeriodAuto }

    /// [5]
    @Published var unit: Unit = .gb
    var unitPublisher: Published<Unit>.Publisher { $unit }
    
    /// [6]
    @Published var dataPlusStepperValue = 1.0
    var dataPlusStepperValuePublisher: Published<Double>.Publisher { $dataPlusStepperValue }
    
    /// [7]
    @Published var dataMinusStepperValue = 1.0
    var dataMinusStepperValuePublisher: Published<Double>.Publisher { $dataMinusStepperValue }
    
    @Published var dataLimitPerDayPlusStepperValue = 1.0
    var dataLimitPerDayPlusStepperValuePublisher: Published<Double>.Publisher { $dataLimitPerDayPlusStepperValue }
    
    @Published var dataLimitPerDayMinusStepperValue = 1.0
    var dataLimitPerDayMinusStepperValuePublisher: Published<Double>.Publisher { $dataLimitPerDayMinusStepperValue }
    
    @Published var dataLimitPlusStepperValue = 1.0
    var dataLimitPlusStepperValuePublisher: Published<Double>.Publisher { $dataLimitPlusStepperValue }
    
    @Published var dataLimitMinusStepperValue = 1.0
    var dataLimitMinusStepperValuePublisher: Published<Double>.Publisher { $dataLimitMinusStepperValue }
    
    /// [8]
    @Published var lastSyncedToRemoteDate: Date?
    var lastSyncedToRemoteDatePublisher: Published<Date?>.Publisher { $lastSyncedToRemoteDate }
    
    
    // MARK: - Initializer
    init() {
        loadAllData()
    }
    
    
    // MARK: - Events
    func loadAllData(unit: Unit? = nil, usageType: ToggleItem? = nil) {
        /// For Testing
        if unit != nil || usageType != nil {
            return
        }
        
        getWasGuideShown()
        getIsPlanActive()
        
        getUsageType()
        getIsPeriodAuto()
        
        getDataPlusStepperValue()
        getDataMinusStepperValue()
        
        getDataLimitPerDayPlusStepperValue()
        getDataLimitPerDayMinusStepperValue()
        
        getDataLimitPlusStepperValue()
        getDataLimitMinusStepperValue()
        
        getLastSyncedToRemote()
        
        if dataPlusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataPlusStepperValue)
            getDataPlusStepperValue()
        }
        if dataMinusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataMinusStepperValue)
            getDataMinusStepperValue()
        }
        
        if dataLimitPerDayPlusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitPerDayPlusStepperValue)
            getDataLimitPerDayPlusStepperValue()
        }
        if dataLimitPerDayMinusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitPerDayMinusStepperValue)
            getDataLimitPerDayMinusStepperValue()
        }
        
        if dataLimitPlusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitPlusStepperValue)
            getDataLimitPlusStepperValue()
        }
        if dataLimitMinusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitMinusStepperValue)
            getDataLimitMinusStepperValue()
        }
    }
    
    /// [1]
    func getWasGuideShown() {
        wasGuideShown = LocalStorage.getBoolItem(forKey: .wasGuideShown)
    }
    
    func setWasGuideShown(_ wasShown: Bool) {
        LocalStorage.setItem(wasShown, forKey: .wasGuideShown)
        getWasGuideShown()
    }
    
    /// [2]
    func getIsPlanActive() {
        isPlanActive = LocalStorage.getBoolItem(forKey: .isPlanActive)
    }
    
    func setIsPlanActive(_ isActive: Bool) {
        LocalStorage.setItem(isActive, forKey: .isPlanActive)
        getIsPlanActive()
    }
    
    /// [3]
    func getUsageType() {
        let usageTypeValue = LocalStorage.getItem(forKey: .usageType) ?? ToggleItem.daily.rawValue
        usageType = ToggleItem(rawValue: usageTypeValue) ?? .daily
    }
    
    func setUsageType(_ type: String) {
        LocalStorage.setItem(type, forKey: .usageType)
        getUsageType()
    }
    
    /// [4]
    func getIsPeriodAuto() {
        isPeriodAuto = LocalStorage.getBoolItem(forKey: .autoPeriod)
    }
    
    func setIsPeriodAuto(_ isOn: Bool) {
        LocalStorage.setItem(isOn, forKey: .autoPeriod)
        getIsPeriodAuto()
    }
    
    /// [6]
    func getDataPlusStepperValue() {
        dataPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataPlusStepperValue)
    }
    
    func setPlusStepperValue(_ amount: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitPlusStepperValue)
            getDataLimitPlusStepperValue()
        case .dailyLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitPerDayPlusStepperValue)
            getDataLimitPerDayPlusStepperValue()
        case .data:
            LocalStorage.setItem(amount, forKey: .dataPlusStepperValue)
            getDataPlusStepperValue()
        }
    }
    
    /// [7]
    func getDataMinusStepperValue() {
        dataMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataMinusStepperValue)
    }
    
    func setMinusStepperValue(_ amount: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitMinusStepperValue)
            getDataLimitMinusStepperValue()
        case .dailyLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitPerDayMinusStepperValue)
            getDataLimitPerDayMinusStepperValue()
        case .data:
            LocalStorage.setItem(amount, forKey: .dataMinusStepperValue)
            getDataMinusStepperValue()
        }
    }
    
    func getDataLimitPerDayPlusStepperValue() {
        dataLimitPerDayPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPerDayPlusStepperValue)
    }
    
    func getDataLimitPerDayMinusStepperValue() {
        dataLimitPerDayMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPerDayMinusStepperValue)
    }
    
    func getDataLimitPlusStepperValue() {
        dataLimitPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPlusStepperValue)
    }
    
    func getDataLimitMinusStepperValue() {
        dataLimitMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitMinusStepperValue)
    }
    
    /// [8]
    func getLastSyncedToRemote() {
        lastSyncedToRemoteDate = LocalStorage.getDateItem(forKey: .lastSyncToRemoteDate)
    }

    func setLastSyncedToRemoteDate(_ date: Date) {
        LocalStorage.setItem(date, forKey: .lastSyncToRemoteDate)
        getLastSyncedToRemote()
    }
}
