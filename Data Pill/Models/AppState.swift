//
//  AppState.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import Combine

final class AppState: ObservableObject, CustomDebugStringConvertible {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    private let appDataRepository: AppDataRepository
    private let dataUsageRepository: DataUsageRepository
    private let networkDataRepository: NetworkDataRepository
    
    /// App Data
    @Published var startDate = "2022-09-12T10:44:00+0000".toDate()
    @Published var endDate = "2022-10-12T10:44:00+0000".toDate()
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    @Published var unit: Unit = .gb
    
    /// Data Usage
    @Published var data: [Data] = .init()
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
        guard let todaysData = data.first(where: { data in
            if let date = data.date {
                return date.isToday()
            }
            return false
        }) else {
            // create a new data if it doesn't exist
            dataUsageRepository.addData(
                date: .init(),
                totalUsedData: 0,
                dailyUsedData: 0,
                hasLastTotal: false
            )
            return data.first(where: { data in
                if let date = data.date {
                    return date.isToday()
                }
                return false
            })!
        }
        return todaysData
    }
    
    var weeksData: [Data] {
        guard
            let date = todaysData.date,
            let weekday = date.toDateComp().weekday
        else {
            return .init()
        }
        return data.suffix(weekday)
    }
    
    var usedData: Double {
        usageType == .daily ?
            todaysData.dailyUsedData :
        0
//            totalUsedData(
//                data,
//                from: startDate,
//                to: endDate
//            )
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
    
    // MARK: - Initialize
    init(
        appDataRepository: AppDataRepository = .init(),
        dataUsageRepository: DataUsageRepository = .init(),
        networkDataRepository: NetworkDataRepository = .init()
    ) {
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.networkDataRepository = networkDataRepository
        
        republishAppData()
        republishDataUsage()
        republishNetworkData()
    }
    
    // MARK: - Functions
    func republishAppData() {
        appDataRepository.$usageType
            .sink { [weak self] usageType in self?.usageType = usageType }
            .store(in: &cancellables)
        
        appDataRepository.$isNotifOn
            .sink { [weak self] isNotifOn in self?.isNotifOn = isNotifOn }
            .store(in: &cancellables)
        
        appDataRepository.$startDate
            .sink { [weak self] startDate in self?.startDate = startDate }
            .store(in: &cancellables)
        
        appDataRepository.$endDate
            .sink { [weak self] endDate in self?.endDate = endDate }
            .store(in: &cancellables)
        
        appDataRepository.$dataAmount
            .sink { [weak self] dataAmount in self?.dataAmount = dataAmount }
            .store(in: &cancellables)
        
        appDataRepository.$dataLimit
            .sink { [weak self] dataLimit in self?.dataLimit = dataLimit }
            .store(in: &cancellables)
        
        appDataRepository.$dataLimitPerDay
            .sink { [weak self] dataLimitPerDay in self?.dataLimitPerDay = dataLimitPerDay }
            .store(in: &cancellables)
        
        appDataRepository.$unit
            .sink { [weak self] unit in self?.unit = unit }
            .store(in: &cancellables)
    }
    
    func republishDataUsage() {
        dataUsageRepository.$data
            .sink { [weak self] data in self?.data = data }
            .store(in: &cancellables)
        
        dataUsageRepository.$dataError
            .sink { [weak self] dataError in self?.dataError = dataError }
            .store(in: &cancellables)
    }
    
    func republishNetworkData() {
        networkDataRepository.$totalUsedData
            .sink { [weak self] totalUsedData in self?.totalUsedData = totalUsedData }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Debug
    var debugDescription: String {
        """
            * AppState *
            
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
