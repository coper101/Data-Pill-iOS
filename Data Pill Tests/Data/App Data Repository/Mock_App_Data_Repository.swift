//
//  Mock_App_Data_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
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
}

