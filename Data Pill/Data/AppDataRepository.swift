//
//  AppDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

// MARK: - Protocol
protocol AppDataRepositoryProtocol {
    /// UI
    var usageType: ToggleItem { get set }
    var usageTypePublisher: Published<ToggleItem>.Publisher { get }
    
    var isPeriodAuto: Bool { get set }
    var isPeriodAutoPublisher: Published<Bool>.Publisher { get }
    
    /// Plan
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
    
    /// Stepper Values
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
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dataLimit: Double?,
        dataLimitPerDay: Double?,
        unit: Unit?,
        usageType: ToggleItem?
    ) -> Void
    
    /// Setters
    func setUsageType(_ type: String) -> Void
    func setIsPeriodAuto(_ isOn: Bool) -> Void
    func setDataAmount(_ amount: Double) -> Void
    func setStartDate(_ date: Date) -> Void
    func setEndDate(_ date: Date) -> Void
    func setDataLimit(_ amount: Double) -> Void
    func setDataLimitPerDay(_ amount: Double) -> Void
    
    func setPlusStepperValue(_ amount: Double, type: StepperValueType)
    func setMinusStepperValue(_ amount: Double, type: StepperValueType)
}

// MARK: - Implementation
enum Keys: String {
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
    
    /// UI
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isPeriodAuto = false
    var isPeriodAutoPublisher: Published<Bool>.Publisher { $isPeriodAuto }
    
    /// Plan
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
    
    /// Stepper Values
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
        startDate: Date? = nil,
        endDate: Date? = nil,
        dataAmount: Double? = nil,
        dataLimit: Double? = nil,
        dataLimitPerDay: Double? = nil,
        unit: Unit? = nil,
        usageType: ToggleItem? = nil
    ) {
        if startDate != nil || endDate != nil || dataAmount != nil || dataLimit != nil ||
            dataLimitPerDay != nil || unit != nil || usageType != nil {
            return
        }
        /// UI
        let usageTypeValue = LocalStorage.getItem(forKey: .usageType) ?? ToggleItem.daily.rawValue
        self.usageType = ToggleItem(rawValue: usageTypeValue) ?? .daily
        isPeriodAuto = LocalStorage.getBoolItem(forKey: .autoPeriod)
        
        /// Plan
        self.dataAmount = LocalStorage.getDoubleItem(forKey: .dataAmount)
        self.startDate = LocalStorage.getDateItem(forKey: .startDatePlan) ?? Date()
        self.endDate = LocalStorage.getDateItem(forKey: .endDatePlan) ?? Date()
        self.dataLimit = LocalStorage.getDoubleItem(forKey: .totalDataLimit)
        self.dataLimitPerDay = LocalStorage.getDoubleItem(forKey: .dailyDataLimit)
        
        /// Stepper Values
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
    func setUsageType(_ type: String) {
        LocalStorage.setItem(type, forKey: .usageType)
    }
    
    func setIsPeriodAuto(_ isOn: Bool) {
        LocalStorage.setItem(isOn, forKey: .autoPeriod)
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
    
    /// UI
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isPeriodAuto = false
    var isPeriodAutoPublisher: Published<Bool>.Publisher { $isPeriodAuto }
    
    /// Plan
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
    
    /// Stepper Values
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
        startDate: Date = Date(),
        endDate: Date = Date(),
        dataAmount: Double = 0.0,
        dataLimit: Double = 0.0,
        dataLimitPerDay: Double = 0.0,
        unit: Unit = .gb,
        dataPlusStepperValue: Double = 1.0,
        dataMinusStepperValue: Double = 1.0,
        dataLimitPerDayPlusStepperValue: Double = 1.0,
        dataLimitPerDayMinusStepperValue: Double = 1.0,
        dataLimitPlusStepperValue: Double = 1.0,
        dataLimitMinusStepperValue: Double = 1.0
    ) {
        /// UI
        self.usageType = usageType
        self.isPeriodAuto = isNotifOn
        /// Plan
        self.startDate = startDate
        self.endDate = endDate
        self.dataAmount = dataAmount
        self.dataLimit = dataLimit
        self.dataLimitPerDay = dataLimitPerDay
        self.unit = unit
        /// Stepper Values
        self.dataPlusStepperValue = dataPlusStepperValue
        self.dataMinusStepperValue = dataMinusStepperValue
        self.dataLimitPerDayPlusStepperValue = dataLimitPerDayPlusStepperValue
        self.dataLimitPerDayMinusStepperValue = dataLimitPerDayMinusStepperValue
        self.dataLimitPlusStepperValue = dataLimitPlusStepperValue
        self.dataLimitMinusStepperValue = dataLimitMinusStepperValue
    }
    
    func loadAllData(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dataLimit: Double?,
        dataLimitPerDay: Double?,
        unit: Unit?,
        usageType: ToggleItem?
    ) {
        self.startDate = startDate ?? Date()
        self.endDate = endDate ?? Date()
        self.dataAmount = dataAmount ?? 0.0
        self.dataLimit = dataLimit ?? 0.0
        self.dataLimitPerDay = dataLimitPerDay ?? 0.0
        self.unit = unit ?? .gb
        self.usageType = usageType ?? .daily
    }
    
    /// Setters
    func setUsageType(_ type: String) {
        usageType = ToggleItem(rawValue: type) ?? .daily
    }
    
    func setIsPeriodAuto(_ isOn: Bool) {
        self.isPeriodAuto = isOn
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

