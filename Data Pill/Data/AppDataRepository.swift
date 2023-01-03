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
    
    func loadAllData(
        unit: Unit?,
        usageType: ToggleItem?
    ) -> Void
    
    /// Setters
    func setWasGuideShown(_ wasShown: Bool) -> Void
    func setUsageType(_ type: String) -> Void
    func setIsPeriodAuto(_ isOn: Bool) -> Void
    func setPlusStepperValue(_ amount: Double, type: StepperValueType)
    func setMinusStepperValue(_ amount: Double, type: StepperValueType)
}

// MARK: - Implementation
enum Keys: String {
    
    case wasGuideShown = "Was_Guide_Shown"
    
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
}

final class AppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var wasGuideShown = false
    var wasGuideShownPublisher: Published<Bool>.Publisher { $wasGuideShown }
    
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
        
        wasGuideShown = LocalStorage.getBoolItem(forKey: .wasGuideShown)
        
        let usageTypeValue = LocalStorage.getItem(forKey: .usageType) ?? ToggleItem.daily.rawValue
        self.usageType = ToggleItem(rawValue: usageTypeValue) ?? .daily
        isPeriodAuto = LocalStorage.getBoolItem(forKey: .autoPeriod)
        
        dataPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataPlusStepperValue)
        dataMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataMinusStepperValue)
        
        dataLimitPerDayPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPerDayPlusStepperValue)
        dataLimitPerDayMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPerDayMinusStepperValue)
        
        dataLimitPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPlusStepperValue)
        dataLimitMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitMinusStepperValue)
        
        if dataPlusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataPlusStepperValue)
            dataPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataPlusStepperValue)
        }
        if dataMinusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataMinusStepperValue)
            dataMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataMinusStepperValue)
        }
        
        if dataLimitPerDayPlusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitPerDayPlusStepperValue)
            dataLimitPerDayPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPerDayPlusStepperValue)
        }
        if dataLimitPerDayMinusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitPerDayMinusStepperValue)
            dataLimitPerDayMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPerDayMinusStepperValue)
        }
        
        if dataLimitPlusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitPlusStepperValue)
            dataLimitPlusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitPlusStepperValue)
        }
        if dataLimitMinusStepperValue == 0 {
            LocalStorage.setItem(1.0, forKey: .dataLimitMinusStepperValue)
            dataLimitMinusStepperValue = LocalStorage.getDoubleItem(forKey: .dataLimitMinusStepperValue)
        }
    }
    
    /// Setters
    func setWasGuideShown(_ wasShown: Bool) {
        LocalStorage.setItem(wasShown, forKey: .wasGuideShown)
    }

    func setUsageType(_ type: String) {
        LocalStorage.setItem(type, forKey: .usageType)
    }
    
    func setIsPeriodAuto(_ isOn: Bool) {
        LocalStorage.setItem(isOn, forKey: .autoPeriod)
    }
    
    func setPlusStepperValue(_ amount: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitPlusStepperValue)
        case .dailyLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitPerDayPlusStepperValue)
        case .data:
            LocalStorage.setItem(amount, forKey: .dataPlusStepperValue)
        }
    }
    
    func setMinusStepperValue(_ amount: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitMinusStepperValue)
        case .dailyLimit:
            LocalStorage.setItem(amount, forKey: .dataLimitPerDayMinusStepperValue)
        case .data:
            LocalStorage.setItem(amount, forKey: .dataMinusStepperValue)
        }
    }

}

class MockAppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var wasGuideShown = false
    var wasGuideShownPublisher: Published<Bool>.Publisher { $wasGuideShown }
    
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
    
    init(
        usageType: ToggleItem = .daily,
        isNotifOn: Bool = false,
        unit: Unit = .gb,
        dataPlusStepperValue: Double = 1.0,
        dataMinusStepperValue: Double = 1.0,
        dataLimitPerDayPlusStepperValue: Double = 1.0,
        dataLimitPerDayMinusStepperValue: Double = 1.0,
        dataLimitPlusStepperValue: Double = 1.0,
        dataLimitMinusStepperValue: Double = 1.0
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
}

