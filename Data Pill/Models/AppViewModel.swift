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
    
    /// [A] App Data
    @Published var unit = Unit.gb
    @Published var usageType: ToggleItem = .daily
    @Published var isPeriodAuto = false
    
    @Published var dataPlusStepperValue = 1.0
    @Published var dataMinusStepperValue = 1.0
    
    @Published var dataLimitPerDayPlusStepperValue = 1.0
    @Published var dataLimitPerDayMinusStepperValue = 1.0
    
    @Published var dataLimitPlusStepperValue = 1.0
    @Published var dataLimitMinusStepperValue = 1.0
    
    /// [B] Data Usage
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    
    @Published var thisWeeksData = [Data]()
    
    @Published var totalUsedDataPlan = 0.0
    
    @Published var dataError: DatabaseError?
    
    /// [3] Network Data
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
        usedData.toPercentage(with: maxData)
    }
    
    // MARK: - UI
    @Published var isHistoryShown = false
    @Published var isBlurShown = false
    @Published var isTappedOutside = false
    @Published var isLongPressedOutside = false
    
    /// Edit Data Plan
    @Published var isDataPlanEditing = false
    @Published var editDataPlanType: EditDataPlan = .dataPlan
    @Published var isStartDatePickerShown = false
    @Published var isEndDatePickerShown = false
    
    @Published var dataValue = "0.0"
    @Published var startDateValue = Date()
    @Published var endDateValue = Date()
    @Published var date = Date()
    
    /// Edit Data Limit
    @Published var isDataLimitEditing = false
    @Published var isDataLimitPerDayEditing = false
    
    @Published var dataLimitValue = "0.0"
    @Published var dataLimitPerDayValue = "0.0"
    
    var numOfDaysOfPlanValue: Int {
        startDateValue.toNumOfDays(to: endDateValue)
    }
    
    var isDatePickerShown: Bool {
        isEndDatePickerShown || isStartDatePickerShown
    }
    
    var buttonType: ButtonType {
        isDatePickerShown ? .done : .save
    }
    
    var buttonDisabled: Bool {
        (numOfDaysOfPlanValue <= 0) && (buttonType == .save)
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
            database: LocalDatabase(container: .dataUsage, appGroup: .dataPill)
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
        
        appDataRepository.unitPublisher
            .sink { [weak self] in self?.unit = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataPlusStepperValuePublisher
            .sink { [weak self] in self?.dataPlusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataMinusStepperValuePublisher
            .sink { [weak self] in self?.dataMinusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPlusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitPlusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitMinusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitMinusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPerDayPlusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitPerDayPlusStepperValue = $0 }
            .store(in: &cancellables)
        
        appDataRepository.dataLimitPerDayMinusStepperValuePublisher
            .sink { [weak self] in self?.dataLimitPerDayMinusStepperValue = $0 }
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.totalUsedData = $0 }
            .store(in: &cancellables)
    }
}

// MARK: Observation
extension AppViewModel {
    
    func observePlanSettings() {
        /// UI
        $usageType
            .sink { [weak self] in self?.appDataRepository.setUsageType($0.rawValue) }
            .store(in: &cancellables)
        
        $isPeriodAuto
            .sink { [weak self] in self?.appDataRepository.setIsPeriodAuto($0) }
            .store(in: &cancellables)
        
        $dataPlusStepperValue
            .sink { [weak self] in self?.appDataRepository.setPlusStepperValue($0, type: .data) }
            .store(in: &cancellables)
        
        $dataLimitPerDayPlusStepperValue
            .sink { [weak self] in self?.appDataRepository.setMinusStepperValue($0, type: .data) }
            .store(in: &cancellables)
        
        $dataLimitPerDayPlusStepperValue
            .sink { [weak self] in self?.appDataRepository.setPlusStepperValue($0, type: .dailyLimit) }
            .store(in: &cancellables)
        
        $dataLimitPerDayMinusStepperValue
            .sink { [weak self] in self?.appDataRepository.setMinusStepperValue($0, type: .dailyLimit) }
            .store(in: &cancellables)
        
        $dataLimitPlusStepperValue
            .sink { [weak self] in self?.appDataRepository.setPlusStepperValue($0, type: .planLimit) }
            .store(in: &cancellables)
        
        $dataLimitMinusStepperValue
            .sink { [weak self] in self?.appDataRepository.setMinusStepperValue($0, type: .planLimit) }
            .store(in: &cancellables)
        
        /// Data Usage
        $totalUsedData
            .removeDuplicates()
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
        
        dataUsageRepository.updateData(todaysData)
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
        guard
            isPeriodAuto,
            let todaysDate = todaysData.date,
            !todaysDate.isDateInRange(from: startDate, to: endDate),
            let newStartDate = startDate.addDay(value: numOfDaysOfPlan),
            let newEndDate = newStartDate.addDay(value: numOfDaysOfPlan - 1)
        else {
            return
        }
        updatePlan(startDate: newStartDate, endDate: newEndDate)
    }
    
    func updatePlan(
        startDate: Date? = nil,
        endDate: Date? = nil,
        dataAmount: Double? = nil,
        dailyLimit: Double? = nil,
        planLimit: Double? = nil
    ) {
        dataUsageRepository.updatePlan(
            startDate: startDate,
            endDate: endDate,
            dataAmount: dataAmount,
            dailyLimit: dailyLimit,
            planLimit: planLimit
        )
    }
    
    /// Data Amount
    func didTapAmount() {
        isBlurShown = true
        isDataPlanEditing = true
        editDataPlanType = .data
    }
    
    func didTapPlusData() {
        dataValue = Stepper.plus(
            value: dataValue,
            max: 100,
            by: dataPlusStepperValue
        )
    }
    
    func didTapMinusData() {
        dataValue = Stepper.minus(
            value: dataValue,
            by: dataMinusStepperValue
        )
    }
    
    func didChangePlusStepperValue(value: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            dataLimitPlusStepperValue = value
            didTapPlusLimit()
        case .dailyLimit:
            dataLimitPerDayPlusStepperValue = value
            didTapPlusLimit()
        case .data:
            dataPlusStepperValue = value
            didTapPlusData()
        }
    }
    
    func didChangeMinusStepperValue(value: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            dataLimitMinusStepperValue = value
            didTapMinusLimit()
        case .dailyLimit:
            dataLimitPerDayMinusStepperValue = value
            didTapMinusLimit()
        case .data:
            dataMinusStepperValue = value
            didTapMinusData()
        }
    }
    
    func didChangeIsDataPlanEditing(_ isEditing: Bool) {
        guard !isTappedOutside else {
            /// revert to previous values

            /// data plan
            dataValue = "\(dataAmount)"
            dataValue = "\(dataValue)"
            startDateValue = startDate
            endDateValue = endDate
            
            /// edit data limit
            dataLimitValue = "\(dataLimit)"
            dataLimitPerDayValue = "\(dataLimitPerDay)"
            
            isTappedOutside = false
            return
        }
        
        switch editDataPlanType {
        case .dataPlan:
            /// update dates
            updatePlan(startDate: startDateValue, endDate: endDateValue)
        case .data:
            /// update data amount only if editing is done
            guard
                let amount = Double(dataValue),
                !isEditing,
                editDataPlanType == .data
            else {
                /// invalid input, revert to previous value
                dataValue = "\(dataAmount)"
                return
            }
            updatePlan(dataAmount: amount)
            /// show proper format  e.g. 0.1 instead of .1
            dataValue = "\(dataAmount)"
            
            /// adjust daily limit
            if dataLimitPerDay > dataAmount {
                updatePlan(dailyLimit: dataAmount)
                dataLimitPerDayValue = "\(dataLimitPerDay)"
            }
            
            /// adjust plan limit
            if dataLimit > dataAmount {
                updatePlan(planLimit: dataAmount)
                dataLimitValue = "\(dataLimit)"
            }
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
        updatePlan(planLimit: amount)
    }
    
    func didChangeIsDataLimitPerDayEditing(_ isEditing: Bool) {
        /// update data limit per day only if editing is done
        guard
            let amount = Double(dataLimitPerDayValue),
            !isEditing
        else {
            return
        }
        updatePlan(dailyLimit: amount)
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
        
        let plusValue = (isDataLimitEditing) ?
            dataLimitPlusStepperValue :
            dataLimitPerDayPlusStepperValue
        
        let newValue = Stepper.plus(
            value: value,
            max: dataAmount,
            by: plusValue
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
        
        let minusValue = (isDataLimitEditing) ?
            dataLimitMinusStepperValue :
            dataLimitPerDayMinusStepperValue
                
        let newValue = Stepper.minus(
            value: value,
            by: minusValue
        )
        
        if isDataLimitEditing {
            dataLimitValue = newValue
            return
        }
        dataLimitPerDayValue = newValue
    }
    
    // MARK: - Operations
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
    
    func didTapOutside() {
        isTappedOutside = true
        
        isBlurShown = false
        isDataPlanEditing = false
        
        isStartDatePickerShown = false
        isEndDatePickerShown = false
        
        isDataLimitEditing = false
        isDataLimitPerDayEditing = false
    }
    
    func didLongPressedOutside() {
        isLongPressedOutside = true
    }
    
    func didReleasedLongPressed() {
        isLongPressedOutside = false
    }
    
    // MARK: - History
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
    
    // MARK: - Deep Link
    func didOpenURL(url: URL) {
        if url == ToggleItem.plan.url {
            usageType = .plan
        } else if url == ToggleItem.daily.url {
            usageType = .daily
        }
    }
    
}

// MARK: Debugging
extension AppViewModel: CustomDebugStringConvertible {
    
    var debugDescription: String {
        """
            
            
            * * * * * *  App State  * * * * * *
            
            - UI
              usage type: \(usageType)
              is Period Auto: \(isPeriodAuto)
            
              data plus val: \(dataPlusStepperValue)
              data minus val: \(dataMinusStepperValue)
            
              data limit per day plus val: \(dataLimitPerDayPlusStepperValue)
              data limit per day minus val: \(dataLimitPerDayMinusStepperValue)
            
              data limit plus val: \(dataLimitPlusStepperValue)
              data limit minus val: \(dataLimitMinusStepperValue)
            
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
