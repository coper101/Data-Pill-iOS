//
//  AppDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

// MARK: - Protocol
protocol AppDataRepositoryProtocol {

    var wasGuideShown: Bool { get set }
    var wasGuideShownPublisher: Published<Bool>.Publisher { get }
    
    var isPlanActive: Bool { get set }
    var isPlanActivePublisher: Published<Bool>.Publisher { get }
    
    var usageType: ToggleItem { get set }
    var usageTypePublisher: Published<ToggleItem>.Publisher { get }
    
    var isPeriodAuto: Bool { get set }
    var isPeriodAutoPublisher: Published<Bool>.Publisher { get }
    
    var unit: Unit { get set }
    var unitPublisher: Published<Unit>.Publisher { get }
    
    var dataPlusStepperValue: Double { get set }
    var dataPlusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataMinusStepperValue: Double { get set }
    var dataMinusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitPerDayPlusStepperValue: Double { get set }
    var dataLimitPerDayPlusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitPerDayMinusStepperValue: Double { get set }
    var dataLimitPerDayMinusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitPlusStepperValue: Double { get set }
    var dataLimitPlusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var dataLimitMinusStepperValue: Double { get set }
    var dataLimitMinusStepperValuePublisher: Published<Double>.Publisher { get }
    
    var lastSyncedToRemoteDate: Date? { get set }
    var lastSyncedToRemoteDatePublisher: Published<Date?>.Publisher { get }
    
    func loadAllData(
        unit: Unit?,
        usageType: ToggleItem?
    ) -> Void
    
    /// Setters
    func setWasGuideShown(_ wasShown: Bool) -> Void
    func setIsPlanActive(_ isActive: Bool) -> Void
    func setUsageType(_ type: String) -> Void
    func setIsPeriodAuto(_ isOn: Bool) -> Void
    func setPlusStepperValue(_ amount: Double, type: StepperValueType)
    func setMinusStepperValue(_ amount: Double, type: StepperValueType)
    func setLastSyncedToRemoteDate(_ date: Date)
}



// MARK: - App Implementation
enum Keys: String {
    
    case wasGuideShown = "Was_Guide_Shown"
    case isPlanActive = "Is_Plan_Active"
    
    case usageType = "Usage_Type"
    case autoPeriod = "Auto_Period"
    case startDatePlan = "Start_Data_Plan"
    case endDatePlan = "End_Data_Plan"
    case dataAmount = "Data_Amount"
    case dailyDataLimit = "Daily_Data_Limit"
    case totalDataLimit = "Total_Data_Limit"
    
    case dataPlusStepperValue = "Data_Plus_Stepper_Value"
    case dataMinusStepperValue = "Data_Minus_Stepper_Value"
    
    case dataLimitPerDayPlusStepperValue = "Data_Plus_Daily_Limit_Stepper_Value"
    case dataLimitPerDayMinusStepperValue = "Data_Minus_Daily_Limit_Stepper_Value"
    
    case dataLimitPlusStepperValue = "Data_Plus_Total_Limit_Stepper_Value"
    case dataLimitMinusStepperValue = "Data_Minus_Total_Limit_Stepper_Value"
    
    case lastSyncToRemoteDate = "Last_Synced_To_Remote_Date"
}

final class AppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var wasGuideShown = false
    var wasGuideShownPublisher: Published<Bool>.Publisher { $wasGuideShown }
    
    @Published var isPlanActive = false
    var isPlanActivePublisher: Published<Bool>.Publisher { $isPlanActive }
    
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isPeriodAuto = false
    var isPeriodAutoPublisher: Published<Bool>.Publisher { $isPeriodAuto }

    @Published var unit: Unit = .gb
    var unitPublisher: Published<Unit>.Publisher { $unit }
    
    @Published var dataPlusStepperValue = 1.0
    var dataPlusStepperValuePublisher: Published<Double>.Publisher { $dataPlusStepperValue }
    
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
    
    @Published var lastSyncedToRemoteDate: Date?
    var lastSyncedToRemoteDatePublisher: Published<Date?>.Publisher { $lastSyncedToRemoteDate }
    
    init() {
        loadAllData()
    }
    
    func loadAllData(
        unit: Unit? = nil,
        usageType: ToggleItem? = nil
    ) {
        /// for testing
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
    
    /// Getters
    func getWasGuideShown() {
        wasGuideShown = LocalStorage.getBoolItem(forKey: .wasGuideShown)
    }
    
    func getIsPlanActive() {
        isPlanActive = LocalStorage.getBoolItem(forKey: .isPlanActive)
    }
    
    func getUsageType() {
        let usageTypeValue = LocalStorage.getItem(forKey: .usageType) ?? ToggleItem.daily.rawValue
        usageType = ToggleItem(rawValue: usageTypeValue) ?? .daily
    }
    
    func getIsPeriodAuto() {
        isPeriodAuto = LocalStorage.getBoolItem(forKey: .autoPeriod)
    }
    
    func getDataPlusStepperValue() {
        dataPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataPlusStepperValue)
    }
    
    func getDataMinusStepperValue() {
        dataMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataMinusStepperValue)
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
    
    func getLastSyncedToRemote() {
        lastSyncedToRemoteDate = LocalStorage.getDateItem(forKey: .lastSyncToRemoteDate)
    }
    
    /// Setters
    func setWasGuideShown(_ wasShown: Bool) {
        LocalStorage.setItem(wasShown, forKey: .wasGuideShown)
        getWasGuideShown()
    }
    
    func setIsPlanActive(_ isActive: Bool) {
        LocalStorage.setItem(isActive, forKey: .isPlanActive)
        getIsPlanActive()
    }

    func setUsageType(_ type: String) {
        LocalStorage.setItem(type, forKey: .usageType)
        getUsageType()
    }
    
    func setIsPeriodAuto(_ isOn: Bool) {
        LocalStorage.setItem(isOn, forKey: .autoPeriod)
        getIsPeriodAuto()
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
    
    func setLastSyncedToRemoteDate(_ date: Date) {
        LocalStorage.setItem(date, forKey: .lastSyncToRemoteDate)
        getLastSyncedToRemote()
    }
}



// MARK: - Test Implementation
class MockAppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var wasGuideShown = false
    var wasGuideShownPublisher: Published<Bool>.Publisher { $wasGuideShown }
    
    @Published var isPlanActive = false
    var isPlanActivePublisher: Published<Bool>.Publisher { $isPlanActive }
    
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isPeriodAuto = false
    var isPeriodAutoPublisher: Published<Bool>.Publisher { $isPeriodAuto }

    @Published var unit: Unit = .gb
    var unitPublisher: Published<Unit>.Publisher { $unit }
    
    @Published var dataPlusStepperValue = 1.0
    var dataPlusStepperValuePublisher: Published<Double>.Publisher { $dataPlusStepperValue }
    
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
    
    @Published var lastSyncedToRemoteDate: Date?
    var lastSyncedToRemoteDatePublisher: Published<Date?>.Publisher { $lastSyncedToRemoteDate }
    
    init(
        usageType: ToggleItem = .daily,
        isNotifOn: Bool = false,
        unit: Unit = .gb,
        dataPlusStepperValue: Double = 1.0,
        dataMinusStepperValue: Double = 1.0,
        dataLimitPerDayPlusStepperValue: Double = 1.0,
        dataLimitPerDayMinusStepperValue: Double = 1.0,
        dataLimitPlusStepperValue: Double = 1.0,
        dataLimitMinusStepperValue: Double = 1.0,
        lastSyncedToRemote: Date? = nil
    ) {
        self.usageType = usageType
        self.isPeriodAuto = isNotifOn
        self.unit = unit
        self.dataPlusStepperValue = dataPlusStepperValue
        self.dataMinusStepperValue = dataMinusStepperValue
        self.dataLimitPerDayPlusStepperValue = dataLimitPerDayPlusStepperValue
        self.dataLimitPerDayMinusStepperValue = dataLimitPerDayMinusStepperValue
        self.dataLimitPlusStepperValue = dataLimitPlusStepperValue
        self.dataLimitMinusStepperValue = dataLimitMinusStepperValue
        self.lastSyncedToRemoteDate = lastSyncedToRemote
    }
    
    func loadAllData(
        unit: Unit?,
        usageType: ToggleItem?
    ) {
        self.unit = unit ?? .gb
        self.usageType = usageType ?? .daily
    }
    
    /// Setters
    func setWasGuideShown(_ wasShown: Bool) {
        wasGuideShown = wasShown
    }
    
    func setIsPlanActive(_ isActive: Bool) {
        isPlanActive = isActive
    }
    
    func setUsageType(_ type: String) {
        usageType = ToggleItem(rawValue: type) ?? .daily
    }
    
    func setIsPeriodAuto(_ isOn: Bool) {
        self.isPeriodAuto = isOn
    }
    
    func setPlusStepperValue(_ amount: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            dataLimitPlusStepperValue = amount
        case .dailyLimit:
            dataLimitPerDayPlusStepperValue = amount
        case .data:
            dataPlusStepperValue = amount
        }
    }
    
    func setMinusStepperValue(_ amount: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            dataLimitMinusStepperValue = amount
        case .dailyLimit:
            dataLimitPerDayMinusStepperValue = amount
        case .data:
            dataMinusStepperValue = amount
        }
    }
    
    func setLastSyncedToRemoteDate(_ date: Date) {
        self.lastSyncedToRemoteDate = date
    }
}

