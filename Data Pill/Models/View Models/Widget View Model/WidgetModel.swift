//
//  WidgetModel.swift
//  Data Pill WidgetExtension
//
//  Created by Wind Versi on 28/11/22.
//

import Foundation
import Combine

final class WidgetModel {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    private let appDataRepository: AppDataRepositoryProtocol
    private let dataUsageRepository: DataUsageRepositoryProtocol
    private let networkDataRepository: NetworkDataRepositoryProtocol
    
    /// [A] App Data
    @Published var unit = Unit.gb
    @Published var usageType = ToggleItem.daily
    
    /// [B] Data Usage
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    
    @Published var totalUsedDataPlan = 0.0
    
    @Published var dataError: DatabaseError?
    
    /// [C] Network Data
    @Published var totalUsedData = 0.0
    
    var usedData: Double {
        usageType == .daily ?
            todaysData.dailyUsedData.toGB() :
            dataUsageRepository.getTotalUsedData(from: startDate, to: endDate).toGB()
    }
    
    var maxData: Double {
        usageType == .daily ?
            dataLimitPerDay :
            dataLimit
    }
    
    var todaysData: Data {
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            /// create a new data if it doesn't exist
            dataUsageRepository.addData(
                date: Calendar.current.startOfDay(for: .init()),
                totalUsedData: 0,
                dailyUsedData: 0,
                hasLastTotal: false,
                isSyncedToRemote: false,
                lastSyncedToRemoteDate: nil
            )
            return dataUsageRepository.getTodaysData()!
        }
        return todaysData
    }
    
    // MARK: - UI
    /// Weekday color can be customizable in the future
    @Published var days = dayPills
    
    // MARK: - Initializer
    /// - parameters:
    ///   - appDataRepository: The data source for app settings
    ///   - dataUsageRepository: The data source for data usage persistence
    ///   - networkDataRepository: The data source for ceullular data usage
    ///   - setupValues: Execute events (useful for testing)
    init(
        appDataRepository: AppDataRepositoryProtocol = AppDataRepository(),
        dataUsageRepository: DataUsageRepositoryProtocol = DataUsageRepository(
            database: LocalDatabase(container: .dataUsage, appGroup: .dataPill)
        ),
        networkDataRepository: NetworkDataRepositoryProtocol = NetworkDataRepository(),
        republishAndObserveData: Bool = true
    ) {
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.networkDataRepository = networkDataRepository
        
        if republishAndObserveData {
            self.republishAndObserveData()
        }
    }
    
    func republishAndObserveData() {
        /// [A]
        republishAppData()
        
        /// [B]
        republishDataUsage()
        
        /// [C]
        republishNetworkData()
        observePlanSettings()
    }
    
    func getLatestData() {
        /// [A]
        appDataRepository.loadAllData(
            unit: nil,
            usageType: nil
        )
        
        /// [B]
        /// Data Usage will be refreshed when network data is received
        dataUsageRepository.updateToLatestPlan()
        
        /// [C]
        networkDataRepository.receiveUsedDataInfo()
    }
    
}

// MARK: Republication
extension WidgetModel {
    
    func republishAppData() {
        appDataRepository.unitPublisher
            .sink { [weak self] in self?.unit = $0 }
            .store(in: &cancellables)
    }
    
    func republishDataUsage() {
        dataUsageRepository.planPublisher
            .sink { [weak self] plan in
                guard let plan, let self else {
                    return
                }
                self.startDate = plan.startDate ?? .init()
                self.endDate = plan.endDate ?? .init()
                self.dataAmount = plan.dataAmount
                self.dataLimit = plan.planLimit
                self.dataLimitPerDay = plan.dailyLimit
            }
            .store(in: &cancellables)
        
        dataUsageRepository.dataErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dataError = $0 }
            .store(in: &cancellables)
    }
    
    func republishNetworkData() {
        networkDataRepository.totalUsedDataPublisher
            .sink { [weak self] in self?.totalUsedData = $0 }
            .store(in: &cancellables)
    }
}

// MARK: Observation
extension WidgetModel {
    
    func observePlanSettings() {
        $totalUsedData
            .sink { [weak self] in self?.refreshUsedDataToday($0) }
            .store(in: &cancellables)
    }
}

// MARK: Events
extension WidgetModel {
    
    // MARK: - Mobile Data
    /// updates the amount used Data today
    func refreshUsedDataToday(_ totalUsedData: Double) {
        /// ignore initial value which is exactly zero
        if totalUsedData == 0 {
            return
        }
        /// calculate new amount used data
        var amountUsed = 0.0
        if let recentDataWithHasTotal = dataUsageRepository.getDataWithHasTotal() {
            let recentTotalUsedData = recentDataWithHasTotal.totalUsedData
            amountUsed = totalUsedData - recentTotalUsedData
        }
        /// new amount can't be calculated since device was restarted
        if amountUsed < 0 {
            amountUsed = 0
        }
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            return
        }
        
        let dailyUsedData = todaysData.dailyUsedData + amountUsed
                
        updateTodaysData(
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: true
        )
    }
    
    func setUsageType(_ usageType: ToggleItem) {
        self.usageType = usageType
    }
    
    func updateTodaysData(
        date: Date? = nil,
        totalUsedData: Double? = nil,
        dailyUsedData: Double? = nil,
        hasLastTotal: Bool? = nil,
        isSyncedToRemote: Bool? = nil,
        lastSyncedToRemoteDate: Date? = nil
    ) {
        dataUsageRepository.updateTodaysData(
            date: date,
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: hasLastTotal,
            isSyncedToRemote: isSyncedToRemote,
            lastSyncedToRemoteDate: lastSyncedToRemoteDate
        )
    }
}
