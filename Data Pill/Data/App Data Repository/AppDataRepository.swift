//
//  AppDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import SwiftUI

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
    
    /// [9] Settings
    
    /// [9.1A] Dark Mode
    var isDarkMode: Bool { get set }
    var isDarkModePublisher: Published<Bool>.Publisher { get }
    
    func setIsDarkMode(_ enabled: Bool) -> Void
    
    /// [9.1B]
    var fillUsageType: FillUsage { get set }
    var fillUsageTypePublisher: Published<FillUsage>.Publisher { get }
    
    func setFillUsageType(_ type: FillUsage) -> Void
    
    /// [9.1C]
    var hasLabelsInDaily: Bool { get set }
    var hasLabelsInDailyPublisher: Published<Bool>.Publisher { get }
    
    func setHasLabelsInDaily(_ enabled: Bool) -> Void
    
    /// [9.1D]
    var hasLabelsInWeekly: Bool { get set }
    var hasLabelsInWeeklyPublisher: Published<Bool>.Publisher { get }
    
    func setHasLabelsInWeekly(_ enabled: Bool) -> Void
    
    /// [9.1F]
    var dayColors: [Day: Color] { get set }
    var dayColorsPublisher: Published<[Day: Color]>.Publisher { get }
    
    func setDayColors(_ dayColors: [Day: Color]) -> Void
    
    /// [9.2] Notification
    var hasDailyNotification: Bool { get set }
    var hasDailyNotificationPublisher: Published<Bool>.Publisher { get }
    
    var hasPlanNotification: Bool { get set }
    var hasPlanNotificationPublisher: Published<Bool>.Publisher { get }
    
    var todaysLastNotificationDate: Date? { get set }
    var todaysLastNotificationDatePublisher: Published<Date?>.Publisher { get }
    
    var planLastNotificationDate: Date? { get set }
    var planLastNotificationDatePublisher: Published<Date?>.Publisher { get }
    
    func setHasDailyNotification(_ enabled: Bool) -> Void
    func setHasPlanNotification(_ enabled: Bool) -> Void
    func setTodaysLastNotificationDate(_ date: Date) -> Void
    func setPlanLastNotificationDate(_ date: Date) -> Void
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
    
    /// [9.1A]
    @Published var isDarkMode: Bool = false
    var isDarkModePublisher: Published<Bool>.Publisher { $isDarkMode }
    
    /// [9.1B]
    @Published var fillUsageType: FillUsage = .accumulate
    var fillUsageTypePublisher: Published<FillUsage>.Publisher { $fillUsageType }
    
    /// [9.1C]
    @Published var hasLabelsInDaily: Bool = true
    var hasLabelsInDailyPublisher: Published<Bool>.Publisher { $hasLabelsInDaily }
    
    /// [9.1D]
    @Published var hasLabelsInWeekly: Bool = true
    var hasLabelsInWeeklyPublisher: Published<Bool>.Publisher { $hasLabelsInWeekly }
    
    /// [9.1F]
    @Published var dayColors: [Day: Color] = defaultDayColors
    var dayColorsPublisher: Published<[Day: Color]>.Publisher { $dayColors }
    
    /// [9.2]
    @Published var hasDailyNotification: Bool = false
    var hasDailyNotificationPublisher: Published<Bool>.Publisher { $hasDailyNotification }
    
    @Published var hasPlanNotification: Bool = false
    var hasPlanNotificationPublisher: Published<Bool>.Publisher { $hasPlanNotification }
    
    @Published var todaysLastNotificationDate: Date?
    var todaysLastNotificationDatePublisher: Published<Date?>.Publisher { $todaysLastNotificationDate }
    
    @Published var planLastNotificationDate: Date?
    var planLastNotificationDatePublisher: Published<Date?>.Publisher { $planLastNotificationDate }
    
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
        
        getIsDarkMode()
        
        getFillUsageType()
        getHasLabelsInDaily()
        getHasLabelsInWeekly()
        getDayColors()
        
        getHasDailyNotification()
        getHasPlanNotification()
        getTodaysLastNotificationDate()
        getPlanLastNotificationDate()
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
    
    /// [9.1A]
    func getIsDarkMode() {
        isDarkMode = LocalStorage.getBoolItem(forKey: .isDarkMode)
    }
    
    func setIsDarkMode(_ enabled: Bool) {
        LocalStorage.setItem(enabled, forKey: .isDarkMode)
        getIsDarkMode()
    }
    
    /// [9.1B]
    func getFillUsageType() {
        let fillUsageTypeIndex = LocalStorage.getIntegerItem(forKey: .fillUsageType)
        fillUsageType = FillUsage(rawValue: fillUsageTypeIndex) ?? .accumulate
    }
    
    func setFillUsageType(_ type: FillUsage) {
        LocalStorage.setItem(type.rawValue, forKey: .fillUsageType)
        getFillUsageType()
    }
    
    /// [9.1C]
    func getHasLabelsInDaily() {
        hasLabelsInDaily = LocalStorage.getBoolItem(forKey: .hasLabelInDaily)
    }
    
    func setHasLabelsInDaily(_ enabled: Bool) {
        LocalStorage.setItem(enabled, forKey: .hasLabelInDaily)
        getHasLabelsInDaily()
    }
    
    /// [9.1D]
    func getHasLabelsInWeekly() {
        hasLabelsInWeekly = LocalStorage.getBoolItem(forKey: .hasLabelInWeekly)
    }
    
    func setHasLabelsInWeekly(_ enabled: Bool) {
        LocalStorage.setItem(enabled, forKey: .hasLabelInWeekly)
        getHasLabelsInWeekly()
    }
    
    /// [9.1E]
    func getDayColors() {
        let dayColorValues = LocalStorage.getAnyItem(forKey: .dayColors) as? [String: String]
        guard let dayColorValues else {
            return
        }
        var dayColors: [Day: Color] = [:]
        dayColorValues.forEach { (dayValue, colorValue) in
            if let day = Day(rawValue: dayValue), let color = Color(rawValue: colorValue) {
                dayColors[day] = color
            }
        }
        self.dayColors = dayColors
    }
    
    func setDayColors(_ dayColors: [Day: Color]) {
        var dayColorValues: [String: String] = [:]
        dayColors.forEach { (day, color) in
            dayColorValues[day.rawValue] = color.rawValue
        }
        LocalStorage.setItem(dayColorValues, forKey: .dayColors)
        getDayColors()
    }
    
    /// [9.2]
    func getHasDailyNotification() {
        hasDailyNotification = LocalStorage.getBoolItem(forKey: .hasDailyNotification)
    }
    
    func setHasDailyNotification(_ enabled: Bool) {
        LocalStorage.setItem(enabled, forKey: .hasDailyNotification)
        getHasDailyNotification()
    }
    
    func getHasPlanNotification() {
        hasPlanNotification = LocalStorage.getBoolItem(forKey: .hasPlanNotification)
    }
    
    func setHasPlanNotification(_ enabled: Bool) {
        LocalStorage.setItem(enabled, forKey: .hasPlanNotification)
        getHasPlanNotification()
    }
    
    func getTodaysLastNotificationDate() {
        todaysLastNotificationDate = LocalStorage.getDateItem(forKey: .todaysLastNotificationDate)
    }

    func setTodaysLastNotificationDate(_ date: Date) {
        LocalStorage.setItem(date, forKey: .todaysLastNotificationDate)
        getTodaysLastNotificationDate()
    }
    
    func getPlanLastNotificationDate() {
        planLastNotificationDate = LocalStorage.getDateItem(forKey: .planLastNotificationDate)
    }

    func setPlanLastNotificationDate(_ date: Date) {
        LocalStorage.setItem(date, forKey: .planLastNotificationDate)
        getPlanLastNotificationDate()
    }
}
