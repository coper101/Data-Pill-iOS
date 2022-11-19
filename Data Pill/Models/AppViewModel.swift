//
//  AppViewModel.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import Combine

final class AppViewModel: ObservableObject {
    
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
    
    var usedData: Double {
        usageType == .daily ?
            todaysData.dailyUsedData.toGB() :
            dataUsageRepository.getTotalUsedData(from: startDate, to: endDate).toGB()
    }
    
    
    var dateUsedInPercentage: Int {
        return usedData.toPercentage(with: maxData)
    }
    
    // MARK: - UI
    /// Usage Type - Plan or Daily
    @Published var usageType: ToggleItem = .daily
    
    /// Notification
    @Published var isPeriodAuto = false
    @Published var isHistoryShown = false
    @Published var isBlurShown = false
    
    /// Edit Data Plan
    @Published var isDataPlanEditing = false
    @Published var editDataPlanType: EditDataPlan = .dataPlan
    @Published var isStartDatePickerShown = false
    @Published var isEndDatePickerShown = false
    
    @Published var dataValue = "0.0"
    @Published var startDateValue = Date()
    @Published var endDateValue = Date()
    
    /// Edit Data Limit
    @Published var isDataLimitEditing = false
    @Published var isDataLimitPerDayEditing = false
    
    @Published var dataLimitValue = "0.0"
    @Published var dataLimitPerDayValue = "0.0"
    
    var numOfDaysOfPlanValue: Int {
        startDateValue.toNumOfDays(to: endDateValue)
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
                entity: .data
            )
        ),
        networkDataRepository: NetworkDataRepositoryProtocol = NetworkDataRepository(),
        setupValues: Bool = true
    ) {
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.networkDataRepository = networkDataRepository
        
        guard setupValues else {
            return
        }
        republishAppData()
        republishDataUsage()
        republishNetworkData()
        
        setInputValues()
        observePlanSettings()
        observeEditPlan()
        observeDataErrors()
    }
    
}

// MARK: Republication
extension AppViewModel {
    
    func republishAppData() {
        appDataRepository.usageTypePublisher
            .sink { [weak self] in self?.usageType = $0 }
            .store(in: &cancellables)
        
        appDataRepository.isPeriodAutoPublisher
            .sink { [weak self] in self?.isPeriodAuto = $0 }
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
                print(self.networkDataRepository, self, separator: "\n")
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
extension AppViewModel {
    
    func observePlanSettings() {
        
        $usageType
            .sink { [weak self] in self?.appDataRepository.setUsageType($0.rawValue) }
            .store(in: &cancellables)
        
        $isPeriodAuto
            .sink { [weak self] in self?.appDataRepository.setIsPeriodAuto($0) }
            .store(in: &cancellables)
        
        $startDate
            .sink { [weak self] in self?.appDataRepository.setStartDate($0) }
            .store(in: &cancellables)
        
        $endDate
            .sink { [weak self] in self?.appDataRepository.setEndDate($0) }
            .store(in: &cancellables)
        
        $dataAmount
            .sink { [weak self] in self?.appDataRepository.setDataAmount($0) }
            .store(in: &cancellables)
        
        $dataLimitPerDay
            .sink { [weak self] in self?.appDataRepository.setDataLimitPerDay($0) }
            .store(in: &cancellables)
        
        $dataLimit
            .sink { [weak self] in self?.appDataRepository.setDataLimit($0) }
            .store(in: &cancellables)
        
        $totalUsedData
            .sink { [weak self] in self?.refreshUsedDataToday($0) }
            .store(in: &cancellables)
        
    }
    
    func observeEditPlan() {
        
        $isDataPlanEditing
            .sink(receiveValue: didChangeIsDataPlanEditing)
            .store(in: &cancellables)
        
        $isDataLimitEditing
            .sink(receiveValue: didChangeIsDataLimitEditing)
            .store(in: &cancellables)
        
        $isDataLimitPerDayEditing
            .sink(receiveValue: didChangeIsDataLimitPerDayEditing)
            .store(in: &cancellables)
    }
    
    func observeDataErrors() {
        
        $dataError
            .sink(receiveValue: didChangeDataError)
            .store(in: &cancellables)
    }
}

// MARK: Events
extension AppViewModel {
    
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
    
    // MARK: - Edit Data Plan
    /// Initial Values
    func setInputValues() {
        dataValue = "\(dataAmount)"
        startDateValue = startDate
        endDateValue = endDate
        dataLimitValue = "\(dataLimit)"
        dataLimitPerDayValue = "\(dataLimitPerDay)"
    }
    
    /// Period
    func didTapPeriod() {
        isBlurShown = true
        isDataPlanEditing = true
        editDataPlanType = .dataPlan
    }
    
    func didTapStartPeriod() {
        isEndDatePickerShown = false
        isStartDatePickerShown = true
    }
    
    func didTapEndPeriod() {
        isStartDatePickerShown = false
        isEndDatePickerShown = true
    }
    
    func updatePlanPeriod() {
        print(#function)
        guard
            isPeriodAuto,
            let todaysDate = todaysData.date,
            !todaysDate.isDateInRange(from: startDate, to: endDate),
            let newStartDate = startDate.addDay(value: numOfDaysOfPlan),
            let newEndDate = newStartDate.addDay(value: numOfDaysOfPlan - 1)
        else {
            return
        }
        startDate = newStartDate
        endDate = newEndDate
    }
    
    /// Data Amount
    func didTapAmount() {
        isBlurShown = true
        isDataPlanEditing = true
        editDataPlanType = .data
    }
    
    func didTapPlusData() {
        guard var doubleValue = Double(dataValue) else {
            return
        }
        doubleValue += 1
        dataValue = "\(doubleValue)"
    }
    
    func didTapMinusData() {
        guard
            var doubleValue = Double(dataValue),
            doubleValue > 0
        else {
            return
        }
        doubleValue -= 1
        dataValue = "\(doubleValue)"
    }
    
    func didChangeIsDataPlanEditing(_ isEditing: Bool) {
        switch editDataPlanType {
        case .dataPlan:
            /// update dates
            startDate = startDateValue
            endDate = endDateValue
        case .data:
            /// update data amount only if editing is done
            guard
                let amount = Double(dataValue),
                !isEditing,
                editDataPlanType == .data
            else {
                return
            }
            dataAmount = amount
        }
    }
    
    func didChangeIsDataLimitEditing(_ isEditing: Bool) {
        /// update data limit only if editing is done
        guard
            let amount = Double(dataLimitValue),
            !isEditing
        else {
            return
        }
        dataLimit = amount
    }
    
    func didChangeIsDataLimitPerDayEditing(_ isEditing: Bool) {
        /// update data limit per day only if editing is done
        guard
            let amount = Double(dataLimitPerDayValue),
            !isEditing
        else {
            return
        }
        dataLimitPerDay = amount
    }
    
    // MARK: - Edit Data Limit
    func didTapLimit() {
        isBlurShown = true
        isDataLimitEditing = true
    }
    
    func didTapLimitPerDay() {
        isBlurShown = true
        isDataLimitPerDayEditing = true
    }
    
    func didTapPlusLimit() {
        let value = (isDataLimitEditing) ?
            dataLimitValue :
            dataLimitPerDayValue
        
        let newValue = Stepper.plus(
            value: value,
            max: dataAmount
        )
        
        if isDataLimitEditing {
            dataLimitValue = newValue
            return
        }
        dataLimitPerDayValue = newValue
    }
    
    func didTapMinusLimit() {
        let value = (isDataLimitEditing) ?
            dataLimitValue :
            dataLimitPerDayValue
                
        let newValue = Stepper.minus(value: value)
        
        if isDataLimitEditing {
            dataLimitValue = newValue
            return
        }
        dataLimitPerDayValue = newValue
    }
    
    func didTapSave() {
        isBlurShown = false
        isDataPlanEditing = false
        
        isStartDatePickerShown = false
        isEndDatePickerShown = false
        
        isDataLimitEditing = false
        isDataLimitPerDayEditing = false
    }
    
    func didTapDone() {
        isStartDatePickerShown = false
        isEndDatePickerShown = false
    }
    
    // MARK: History
    func didTapCloseHistory() {
        isBlurShown = false
        isHistoryShown = false
    }
    
    func didTapOpenHistory() {
        guard usageType == .daily else {
            return
        }
        isBlurShown = true
        isHistoryShown = true
    }
    
    // MARK: - Data Error
    func didChangeDataError(_ error: DatabaseError?) {
        guard let error = error, error == .loadingContainer() else {
            return
        }
        isBlurShown = true
    }
    
}

// MARK: Debugging
extension AppViewModel: CustomDebugStringConvertible {
    
    var debugDescription: String {
        """
            
            
            * * App State * *
            
            - UI
              usage type: \(usageType)
              is Notification On: \(isPeriodAuto)
            
            - Data
              plan data amount: \(dataAmount)
              plan data limit per day: \(dataLimitPerDay)
              plan data limit: \(dataLimit)
              plan start date: \(startDate)
              plan end date: \(endDate)
            
              today's data:\n(\(todaysData)  )
            
              this weeks data:\n\(thisWeeksData)

              used data (plan or daily): \(usedData)
                        
            """
    }
}
