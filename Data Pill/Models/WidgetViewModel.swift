//
//  WidgetViewModel.swift
//  Data Pill WidgetExtension
//
//  Created by Wind Versi on 28/11/22.
//

import Foundation
import Combine

final class WidgetViewModel {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    private let appDataRepository: AppDataRepositoryProtocol
    private let dataUsageRepository: DataUsageRepositoryProtocol
    private let networkDataRepository: NetworkDataRepositoryProtocol
    
    /// [A] App Data
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var unit = Unit.gb
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    @Published var usageType = ToggleItem.daily
    
    /// [B] Data Usage
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
                hasLastTotal: false
            )
            return dataUsageRepository.getTodaysData()!
        }
        return todaysData
    }
    
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
            database: LocalDatabase(
                container: .dataUsage,
                entity: .data,
                appGroup: .dataPill
            )
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
            startDate: nil,
            endDate: nil,
            dataAmount: nil,
            dataLimit: nil,
            dataLimitPerDay: nil,
            unit: nil,
            usageType: nil
        )
        
        /// [C]
        networkDataRepository.receiveDataInfo()
    }
    
}

// MARK: Republication
extension WidgetViewModel {
    
    func republishAppData() {
        appDataRepository.startDatePublisher
            .sink { [weak self] in self?.startDate = $0 }
            .store(in: &cancellables)
        
        appDataRepository.endDatePublisher
            .sink { [weak self] in self?.endDate = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataAmountPublisher
            .sink { [weak self] in self?.dataAmount = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPublisher
            .sink { [weak self] in self?.dataLimit = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPerDayPublisher
            .sink { [weak self] in self?.dataLimitPerDay = $0 }
            .store(in: &cancellables)
        
        appDataRepository.unitPublisher
            .sink { [weak self] in self?.unit = $0 }
            .store(in: &cancellables)
    }
    
    func republishDataUsage() {
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
extension WidgetViewModel {
    
    func observePlanSettings() {
        $totalUsedData
            .sink { [weak self] in self?.refreshUsedDataToday($0) }
            .store(in: &cancellables)
    }
}

// MARK: Events
extension WidgetViewModel {
    
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
        let todaysData = todaysData
        todaysData.dailyUsedData += amountUsed
        todaysData.totalUsedData = totalUsedData
        todaysData.hasLastTotal = true
        
        dataUsageRepository.updateData(item: todaysData)
    }
    
    func setUsageType(_ usageType: ToggleItem) {
        self.usageType = usageType
    }
}
