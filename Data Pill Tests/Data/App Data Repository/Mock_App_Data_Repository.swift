//
//  Mock_App_Data_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import SwiftUI
import Combine

final class MockAppDataRepository: ObservableObject, AppDataRepositoryProtocol {
    
    @Published var wasGuideShown = false
    var wasGuideShownPublisher: Published<Bool>.Publisher { $wasGuideShown }
    
    @Published var isPlanActive = false
    var isPlanActivePublisher: Published<Bool>.Publisher { $isPlanActive }
    
    @Published var usageType: ToggleItem = .daily
    var usageTypePublisher: Published<ToggleItem>.Publisher { $usageType }

    @Published var isPeriodAuto = false
    var isPeriodAutoPublisher: Published<Bool>.Publisher { $isPeriodAuto }

    @Published var unit: Data_Pill.Unit = .gb
    var unitPublisher: Published<Data_Pill.Unit>.Publisher { $unit }
    
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
    
    /// [8.1A]
    @Published var isDarkMode: Bool = false
    var isDarkModePublisher: Published<Bool>.Publisher { $isDarkMode }
    
    /// [8.1B]
    @Published var fillUsageType: FillUsage = .accumulate
    var fillUsageTypePublisher: Published<FillUsage>.Publisher { $fillUsageType }
    
    /// [8.1C]
    @Published var hasLabelsInDaily: Bool = true
    var hasLabelsInDailyPublisher: Published<Bool>.Publisher { $hasLabelsInDaily }
    
    /// [8.1D]
    @Published var hasLabelsInWeekly: Bool = true
    var hasLabelsInWeeklyPublisher: Published<Bool>.Publisher { $hasLabelsInWeekly }
    
    /// [8.1F]
    @Published var dayColors: [Day: Color] = defaultDayColors
    var dayColorsPublisher: Published<[Day: Color]>.Publisher { $dayColors }
    
    /// [8.2]
    @Published var hasDailyNotification: Bool = false
    var hasDailyNotificationPublisher: Published<Bool>.Publisher { $hasDailyNotification }
    
    @Published var hasPlanNotification: Bool = false
    var hasPlanNotificationPublisher: Published<Bool>.Publisher { $hasPlanNotification }
    
    @Published var todaysLastNotificationDate: Date?
    var todaysLastNotificationDatePublisher: Published<Date?>.Publisher { $todaysLastNotificationDate }
    
    @Published var planLastNotificationDate: Date?
    var planLastNotificationDatePublisher: Published<Date?>.Publisher { $planLastNotificationDate }
    
    /// [8.3]
    @Published var dataUnit: Data_Pill.Unit = .gb
    var dataUnitPublisher: Published<Data_Pill.Unit>.Publisher { $dataUnit }
    
    init(
        usageType: ToggleItem = .daily,
        isNotifOn: Bool = false,
        unit: Data_Pill.Unit = .gb,
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
        unit: Data_Pill.Unit?,
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
    
    /// [8.1A]
    func getIsDarkMode() {}
    
    func setIsDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
    }
    
    /// [8.1B]
    func getFillUsageType() {}
    
    func setFillUsageType(_ type: FillUsage) {
        fillUsageType = type
    }
    
    /// [8.1C]
    func getHasLabelsInDaily() {}
    
    func setHasLabelsInDaily(_ enabled: Bool) {
        hasLabelsInDaily = enabled
    }
    
    /// [8.1D]
    func getHasLabelsInWeekly() {}
    
    func setHasLabelsInWeekly(_ enabled: Bool) {
        hasLabelsInWeekly = enabled
    }
    
    /// [8.1E]
    func getDayColors() {}
    
    func setDayColors(_ dayColors: [Day: Color]) {
        self.dayColors = dayColors
    }
    
    /// [8.2]
    func getHasDailyNotification() {}
    
    func setHasDailyNotification(_ enabled: Bool) {
        hasDailyNotification = enabled
    }
    
    func getHasPlanNotification() {}
    
    func setHasPlanNotification(_ enabled: Bool) {
        hasPlanNotification = enabled
    }
    
    func getTodaysLastNotificationDate() {}

    func setTodaysLastNotificationDate(_ date: Date) {
        todaysLastNotificationDate = date
    }
    
    func getPlanLastNotificationDate() {}

    func setPlanLastNotificationDate(_ date: Date) {
        planLastNotificationDate = date
    }
    
    /// [8.3]
    func getDataUnit() {}
    
    func setDataUnit(_ type: Data_Pill.Unit) {
        dataUnit = type
    }
}

