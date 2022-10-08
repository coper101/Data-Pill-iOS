//
//  AppState.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import Combine

final class AppState: ObservableObject {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    let appDataRepository: AppDataRepositoryProtocol
    let dataUsageRepository: DataUsageRepositoryProtocol
    let networkDataRepository: NetworkDataRepositoryProtocol
    
    /// App Data
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    @Published var unit = Unit.gb
    
    /// Data Usage
    @Published var thisWeeksData = [Data]()
    @Published var totalUsedDataPlan = 0.0
    @Published var dataError: DatabaseError?
    
    /// Network Data
    @Published var totalUsedData = 0.0

    var numOfDaysOfPlan: Int {
        startDate.toNumOfDays(to: endDate)
    }
    
    var maxData: Double {
        usageType == .daily ?
            dataLimitPerDay :
            dataLimit
    }
    
    var todaysData: Data {
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            // create a new data if it doesn't exist
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
    
    var usedData: Double {
        usageType == .daily ?
            todaysData.dailyUsedData.toGB() :
            totalUsedData.toGB()
    }
    
    
    var dateUsedInPercentage: Int {
        return usedData.toPercentage(with: maxData)
    }
    
    // MARK: - UI
    /// Usage Type - Plan or Daily
    @Published var usageType: ToggleItem = .daily
    
    /// Notification
    @Published var isNotifOn = false
    @Published var isHistoryShown = false
    @Published var isBlurShown = false
    
    /// Edit Data Plan
    @Published var isDataPlanEditing = false
    @Published var editDataPlanType: EditDataPlan = .dataPlan
    @Published var isStartDatePickerShown = false
    @Published var isEndDatePickerShown = false
    
    @Published var dataValue = "0.0"
    @Published var startDateValue: Date = .init()
    @Published var endDateValue: Date = .init()
    
    /// Edit Data Limit
    @Published var isDataLimitEditing = false
    @Published var isDataLimitPerDayEditing = false
    
    @Published var dataLimitValue = "0.0"
    @Published var dataLimitPerDayValue = "0.0"
    
    var numOfDaysOfPlanValue: Int {
        startDateValue.toNumOfDays(to: endDateValue)
    }
    
    /// Weekday color can be customizable in the future
    @Published var days: [DayPill] = [
        .init(color: .secondaryBlue, day: .sunday),
        .init(color: .secondaryPurple, day: .monday),
        .init(color: .secondaryGreen, day: .tuesday),
        .init(color: .secondaryRed, day: .wednesday),
        .init(color: .secondaryOrange, day: .thursday),
        .init(color: .secondaryPurple, day: .friday),
        .init(color: .secondaryBlue, day: .saturday)
    ]
    
    init(
        appDataRepository: AppDataRepositoryProtocol = AppDataRepository(),
        dataUsageRepository: DataUsageRepositoryProtocol = DataUsageRepository(),
        networkDataRepository: NetworkDataRepositoryProtocol = NetworkDataRepository()
    ) {
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.networkDataRepository = networkDataRepository
        
        republishAppData()
        republishDataUsage()
        republishNetworkData()
        
        setInputValues()
        
        observeUsageType()
        observeNotification()
        observeStartDate()
        observeEndDate()
        observeDataAmount()
        observeDailyDataLimit()
        observeTotalDataLimit()
        observeTotalUsedData()
    }
    
    func setInputValues() {
        dataValue = "\(dataAmount)"
        startDateValue = startDate
        endDateValue = endDate
        dataLimitValue = "\(dataLimit)"
        dataLimitPerDayValue = "\(dataLimitPerDay)"
    }
    
}

// MARK: - Republish Data
extension AppState {
    
    func republishAppData() {
        appDataRepository.usageTypePublisher
            .sink { [weak self] in self?.usageType = $0 }
            .store(in: &cancellables)
        
        appDataRepository.isNotifOnPublisher
            .sink { [weak self] in self?.isNotifOn = $0 }
            .store(in: &cancellables)
        
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
        dataUsageRepository.thisWeeksDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                self.thisWeeksData = $0
                self.totalUsedDataPlan = self.dataUsageRepository
                    .getTotalUsedData(from: self.startDate, to: self.endDate)
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

// MARK: - Observe Data
extension AppState {
    
    func observeUsageType() {
        $usageType
            .sink { [weak self] in self?.appDataRepository.setUsageType($0.rawValue) }
            .store(in: &cancellables)
    }
    
    func observeNotification() {
        $isNotifOn
            .sink { [weak self] in self?.appDataRepository.setIsNotification($0) }
            .store(in: &cancellables)
    }
    
    func observeStartDate() {
        $startDate
            .sink { [weak self] in self?.appDataRepository.setStartDate($0) }
            .store(in: &cancellables)
    }
    
    func observeEndDate() {
        $endDate
            .sink { [weak self] in self?.appDataRepository.setEndDate($0) }
            .store(in: &cancellables)
    }
    
    func observeDataAmount() {
        $dataAmount
            .sink { [weak self] in self?.appDataRepository.setDataAmount($0) }
            .store(in: &cancellables)
    }
    
    func observeDailyDataLimit() {
        $dataLimitPerDay
            .sink { [weak self] in self?.appDataRepository.setDataLimitPerDay($0) }
            .store(in: &cancellables)
    }
    
    func observeTotalDataLimit() {
        $dataLimit
            .sink { [weak self] in self?.appDataRepository.setDataLimit($0) }
            .store(in: &cancellables)
    }
    
    func observeTotalUsedData() {
        $totalUsedData
            .sink { [weak self] in self?.refreshUsedDataToday($0) }
            .store(in: &cancellables)
    }
    
}

// MARK: - Mutate Data
extension AppState {
    
    /// updates the amount used Data today
    func refreshUsedDataToday(_ totalUsedData: Double) {
        
        // ignore initial value which is exactly zero
        if totalUsedData == 0 {
            return
        }
                
        // calculate new amount used data
        var amountUsed = 0.0
        if let recentDataWithHasTotal = dataUsageRepository.getDataWithHasTotal() {
            print("recentDataWithHasTotal:\n", recentDataWithHasTotal)
            let recentTotalUsedData = recentDataWithHasTotal.totalUsedData
            amountUsed = totalUsedData - recentTotalUsedData
        }
        
        // new amount can't be calculated since device was restarted
        if amountUsed < 0 {
            amountUsed = 0
        }
                
        let todaysData = todaysData
        todaysData.dailyUsedData += amountUsed
        todaysData.totalUsedData = totalUsedData
        todaysData.hasLastTotal = true
        
        dataUsageRepository.updateData(item: todaysData)

        print(
            """
                * Network Data *
                  Total Data Used: \(totalUsedData) MB
                  Amount Used: \(amountUsed) MB
                
                - Updated Today's Data:
                \(todaysData)
                """
        )
    }
    
}

// MARK: - Debug
extension AppState: CustomDebugStringConvertible {
    
    var debugDescription: String {
        """
            - * AppState *
            
            - UI
              selectedItem: \(usageType)
              isNotifOn: \(isNotifOn)
            
            - Data
              dataAmount: \(dataAmount)
              dataLimitPerDay: \(dataLimitPerDay)
              dataLimit: \(dataLimit)

              startDate: \(startDate)
              endDate: \(endDate)
            
            """
    }
    
}
