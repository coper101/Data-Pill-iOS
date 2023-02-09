//
//  AppViewModel.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import Combine
import SwiftUI
import OSLog

final class AppViewModel: ObservableObject {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    let appDataRepository: AppDataRepositoryProtocol
    let dataUsageRepository: DataUsageRepositoryProtocol
    let dataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol
    let networkDataRepository: NetworkDataRepositoryProtocol
    let toastTimer: ToastTimer<LocalizedStringKey>
    
    /// [A] App Data
    @Published var wasGuideShown = false

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
    
    @Published var todaysData: Data = createFakeData()
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
    
    var usedData: Double {
        usageType == .daily ?
            todaysData.dailyUsedData.toGB() :
            dataUsageRepository.getTotalUsedData(from: startDate, to: endDate).toGB()
    }
    
    
    var dateUsedInPercentage: Int {
        usedData.toPercentage(with: maxData)
    }
    
    // MARK: - UI
    @Published var isGuideShown = false
    @Published var isPlanActive = false
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
    @Published var toastMessage: LocalizedStringKey?

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
    
    var buttonDisabledPlanLimit: Bool {
        Validator.hasExceededLimit(
            value: dataLimitValue,
            max: dataAmount,
            min: 0
        )
    }
    
    var buttonDisabledDailyLimit: Bool {
        Validator.hasExceededLimit(
            value: dataLimitPerDayValue,
            max: maxDataAmountForLimit,
            min: 0
        )
    }
    
    var maxDataAmountForLimit: Double {
        /// Max of 100 GB for Non-Plan
        isPlanActive ? dataAmount : 100
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
        dataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol = DataUsageRemoteRepository(
            remoteDatabase: CloudDatabase(container: .dataPill)
        ),
        networkDataRepository: NetworkDataRepositoryProtocol = NetworkDataRepository(),
        toastTimer: ToastTimer<LocalizedStringKey> = .init(),
        setupValues: Bool = true
    ) {
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.dataUsageRemoteRepository = dataUsageRemoteRepository
        self.networkDataRepository = networkDataRepository
        self.toastTimer = toastTimer
        
        guard setupValues else {
            return
        }
        republishAppData()
        republishDataUsage()
        republishNetworkData()
        republishToast()
        
        setInputValues()
        
        observePlanSettings()
        observeEditPlan()
        observeDataErrors()
        
//        if !isGuideShown {
//            print("adding test data")
//            #if DEBUG
//                addTestData()
//            #endif
//        }
        
        syncTodaysData()
        syncOldData()
    }
    
}

// MARK: Republication
extension AppViewModel {
    
    func republishAppData() {
        appDataRepository.wasGuideShownPublisher
            .sink { [weak self] in self?.wasGuideShown = $0 }
            .store(in: &cancellables)
        
        appDataRepository.isPlanActivePublisher
            .sink { [weak self] in self?.isPlanActive = $0 }
            .store(in: &cancellables)
        
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
                                
                self.syncPlan()
            }
            .store(in: &cancellables)
        
        dataUsageRepository.todaysDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] todaysData in
                guard let todaysData else {
                    /// create a new data if it doesn't exist
                    self?.dataUsageRepository.addData(
                        date: Calendar.current.startOfDay(for: .init()),
                        totalUsedData: 0,
                        dailyUsedData: 0,
                        hasLastTotal: false
                    )
                    return
                }
                self?.todaysData = todaysData
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
    
    func republishToast() {
        toastTimer.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.toastMessage = $0 }
            .store(in: &cancellables)
    }
}

// MARK: Observation
extension AppViewModel {
    
    func observePlanSettings() {
        /// UI
        $isPlanActive
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in
                self?.didChangeIsPlanActive($0)
                self?.appDataRepository.setIsPlanActive($0)
            }
            .store(in: &cancellables)
        
        $usageType
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in self?.appDataRepository.setUsageType($0.rawValue) }
            .store(in: &cancellables)
        
        $isPeriodAuto
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in self?.appDataRepository.setIsPeriodAuto($0) }
            .store(in: &cancellables)
        
        /// Data Usage
        $totalUsedData
            .removeDuplicates()
            .sink { [weak self] in self?.refreshUsedDataToday($0) }
            .store(in: &cancellables)
        
    }
    
    func observeEditPlan() {
        
        $isDataPlanEditing
            .dropFirst()
            .sink(receiveValue: didChangeIsDataPlanEditing)
            .store(in: &cancellables)
        
        $isDataLimitEditing
            .dropFirst()
            .sink(receiveValue: didChangeIsDataLimitEditing)
            .store(in: &cancellables)
        
        $isDataLimitPerDayEditing
            .dropFirst()
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
    
    // MARK: - Data Plan
    func didTapStartPlan() {
        closeGuide()
        appDataRepository.setIsPlanActive(true)
    }
    
    func didTapStartNonPlan() {
        closeGuide()
        appDataRepository.setIsPlanActive(false)
    }
    
    func didChangeIsPlanActive(_ isActive: Bool) {        
        if !isActive && (usageType == .plan) {
            appDataRepository.setUsageType(ToggleItem.daily.rawValue)
        }
        
        /// update daily limit if it exceeds max data amount
        /// when Plan becomes active
        if isActive && (dataLimitPerDay > dataAmount) {
            dataLimitPerDay = dataAmount
            dataLimitPerDayValue = "\(dataAmount)"
        }
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
            planLimit: planLimit,
            updateToLatestPlanAfterwards: true
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
            appDataRepository.setPlusStepperValue(value, type: .planLimit)
            didTapPlusLimit()
        case .dailyLimit:
            appDataRepository.setPlusStepperValue(value, type: .dailyLimit)
            didTapPlusLimit()
        case .data:
            appDataRepository.setPlusStepperValue(value, type: .data)
            didTapPlusData()
        }
    }
    
    func didChangeMinusStepperValue(value: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            appDataRepository.setMinusStepperValue(value, type: .planLimit)
            didTapMinusLimit()
        case .dailyLimit:
            appDataRepository.setMinusStepperValue(value, type: .dailyLimit)
            didTapMinusLimit()
        case .data:
            appDataRepository.setMinusStepperValue(value, type: .data)
            didTapMinusData()
        }
    }
    
    func didChangeIsDataPlanEditing(_ isEditing: Bool) {
        print(#function)

        if toastTimer.timer != nil {
            toastTimer.reset()
        }
        
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
        print(#function)
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
        print(#function)

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
            max: maxDataAmountForLimit,
            by: plusValue,
            onExceed: { [weak self] in
                if isPlanActive {
                    self?.toastTimer.showToast(message: "Exceeds maximum data amount")
                    return
                }
                self?.toastTimer.showToast(message: "You have reached the max limit")
            }
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
        
        if isDataPlanEditing {
            isDataPlanEditing = false
        }
        
        if isStartDatePickerShown {
            isStartDatePickerShown = false
        }
        
        if isEndDatePickerShown {
            isEndDatePickerShown = false
        }
        
        if isDataLimitEditing {
            isDataLimitEditing = false
        }
        
        if isDataLimitPerDayEditing {
            isDataLimitPerDayEditing = false
        }
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
            appDataRepository.setUsageType(ToggleItem.plan.rawValue)
        } else if url == ToggleItem.daily.url {
            appDataRepository.setUsageType(ToggleItem.daily.rawValue)
        }
    }
    
    // MARK: - Guide
    func showGuide() {
        isGuideShown = !wasGuideShown
    }
    
    func closeGuide() {
        isGuideShown = false
        appDataRepository.setWasGuideShown(true)
    }
    
    // MARK: - iCloud
    // Sync Plan
    func doSyncPlan() -> AnyPublisher<Bool, Error> {
        dataUsageRemoteRepository.isLoggedInUser()
            .flatMap { isLoggedIn in
                /// 1. not logged in
                guard isLoggedIn else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1. logged in
                return self.dataUsageRemoteRepository.isPlanAdded()
                    .eraseToAnyPublisher()
            }
            .flatMap { isPlanAdded in
                /// 2. update existing plan
                guard !isPlanAdded else {
                    return self.dataUsageRemoteRepository
                        .updatePlan(
                            startDate: self.startDate,
                            endDate: self.endDate,
                            dataAmount: self.dataAmount,
                            dailyLimit: self.dataLimitPerDay,
                            planLimit: self.dataLimit
                        )
                        .eraseToAnyPublisher()
                }
                /// 2. add new plan
                return self.dataUsageRemoteRepository
                    .addPlan(
                        .init(
                            startDate: self.startDate,
                            endDate: self.endDate,
                            dataAmount: self.dataAmount,
                            dailyLimit: self.dataLimitPerDay,
                            planLimit: self.dataLimit
                        )
                    )
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncPlan() {
        // write existing plan to local (newly installed app)
        guard wasGuideShown else {
            dataUsageRemoteRepository.getPlan()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        Logger.appModel.debug("syncPlan - get existing plan error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] remotePlan in
                    guard let self, let remotePlan else {
                        return
                    }
                    Logger.appModel.debug("syncPlan - get existing plan: \(remotePlan.startDate) - \(remotePlan.endDate)")
                    
                    self.dataUsageRepository.updatePlan(
                        startDate: remotePlan.startDate,
                        endDate: remotePlan.endDate,
                        dataAmount: remotePlan.dataAmount,
                        dailyLimit: remotePlan.dailyLimit,
                        planLimit: remotePlan.planLimit,
                        updateToLatestPlanAfterwards: false
                        
                    )
                }
                .store(in: &self.cancellables)
            return
        }
        
        // upload
        doSyncPlan()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Logger.appModel.debug("syncPlan - is plan saved or updated: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { isSavedOrUpdated in
                Logger.appModel.debug("syncPlan - is plan saved or updated: \(isSavedOrUpdated)")
            }
            .store(in: &self.cancellables)
    }
    
    // Sync Today's Data
    func doSyncTodaysData() -> AnyPublisher<Bool, Error> {
        guard let todaysDate = todaysData.date else {
            return Fail(error: RemoteDatabaseError.nilProp("Today's Date is nil"))
                .eraseToAnyPublisher()
        }
        let date = Calendar.current.startOfDay(for: todaysDate)
        let dailyUsedData = todaysData.dailyUsedData
        
        return dataUsageRemoteRepository.isLoggedInUser()
            .flatMap { isLoggedIn  in
                /// 1. not logged in
                guard isLoggedIn else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                /// 1. logged in
                return self.dataUsageRemoteRepository.isDataAdded(on: date)
                    .eraseToAnyPublisher()
            }
            .flatMap { isDataAdded in
                /// 2. update existing data
                guard !isDataAdded else {
                    return self.dataUsageRemoteRepository
                        .updateData(date: date, dailyUsedData: dailyUsedData)
                        .eraseToAnyPublisher()
                }
                /// 2. add new data
                return self.dataUsageRemoteRepository
                    .addData(.init(date: date, dailyUsedData: dailyUsedData))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncTodaysData() {
        // write existing todays data to local (newly installed app)
        guard wasGuideShown else {
            let date = Calendar.current.startOfDay(for: self.todaysData.date ?? .init())
            dataUsageRemoteRepository.getData(on: date)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        Logger.appModel.debug("syncTodaysData - get existing plan error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] remoteData in
                    guard let self, let remoteData else {
                        return
                    }
                    Logger.appModel.debug("syncTodaysData - get existing todays data: \(remoteData.dailyUsedData)")
                    
                    let todaysData = self.todaysData
                    todaysData.dailyUsedData = remoteData.dailyUsedData.toMB()
                    todaysData.totalUsedData = 0
                    todaysData.hasLastTotal = true
                    
                    self.dataUsageRepository.updateData(todaysData)
                }
                .store(in: &self.cancellables)
            return
        }
        
        // upload
        doSyncTodaysData()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Logger.appModel.debug("syncTodaysData - is plan saved or updated error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { isSavedOrUpdated in
                Logger.appModel.debug("syncTodaysData - is todays data saved or updated: \(isSavedOrUpdated)")
            }
            .store(in: &self.cancellables)
    }
    
    // Sync Old Data
    func doSyncOldData() -> AnyPublisher<Bool, Error> {
        var allDataFromLocal = dataUsageRepository.getAllData()
        
        /// exclude todays data
        allDataFromLocal.removeAll(where: { $0.date == Calendar.current.startOfDay(for: .init()) })
        
        guard !allDataFromLocal.isEmpty else {
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        for data in allDataFromLocal {
            Logger.appModel.debug("syncOldData - data from local: \(data.date.debugDescription)")
        }
        
        return dataUsageRemoteRepository.isLoggedInUser()
            .flatMap { isLoggedIn in
                /// 1. logged in
                if isLoggedIn {
                    return self.dataUsageRemoteRepository.getAllExistingDataDates()
                        .eraseToAnyPublisher()
                }
                return Just([Date]()).eraseToAnyPublisher()
            }
            .map { dataDatesFromRemote in
                /// data to update not added to cloud
                var dataToUpdate = [Data]()
                
                allDataFromLocal.forEach { data in
                    guard let date = data.date else {
                        return
                    }
                    guard dataDatesFromRemote.first(where: { $0 == date }) == nil else {
                        return
                    }
                    dataToUpdate.append(data)
                }
                
                for data in dataToUpdate {
                    Logger.appModel.debug("syncOldData - data to update: \(data.date.debugDescription)")
                }
                
                return dataToUpdate
            }
            .map { (dataToUpdate: [Data]) in
                /// convert all to cloud data type
                let remoteData: [RemoteData] = dataToUpdate.compactMap { data in
                    guard let date = data.date else {
                        return nil
                    }
                    return RemoteData(date: date, dailyUsedData: data.dailyUsedData)
                }
                return remoteData
            }
            .flatMap {
                /// save all old data
                self.dataUsageRemoteRepository.addData($0)
            }
            .eraseToAnyPublisher()
    }
    
    func syncOldData() {
        doSyncOldData()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Logger.appModel.debug("syncOldData - are old data added error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { areAdded in
                Logger.appModel.debug("syncOldData - are old data added: \(areAdded)")
            }
            .store(in: &self.cancellables)
    }
}

extension AppViewModel {
    
    func addTestData() {
        
        let todaysDate = Date()

        /// 3 Days Ago
        dataUsageRepository.addData(
            date: Calendar.current.date(
                byAdding: .day, value: -3, to: todaysDate)!,
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true
        )
        
        /// 2 Days Ago
        dataUsageRepository.addData(
            date: Calendar.current.date(
                byAdding: .day, value: -2, to: todaysDate)!,
            totalUsedData: 0,
            dailyUsedData: 5_000,
            hasLastTotal: true
        )
        
        /// Yesterday
        dataUsageRepository.addData(
            date: Calendar.current.date(
                byAdding: .day, value: -1, to: todaysDate)!,
            totalUsedData: 0,
            dailyUsedData: 2_100,
            hasLastTotal: true
        )
       
        /// Update Database
//        dataUsageRepository.updatePlan(
//            startDate: Calendar.current.date(
//                byAdding: .day, value: -3, to: todaysDate)!,
//            endDate: Calendar.current.date(
//                byAdding: .day, value: 0, to: todaysDate)!,
//            dataAmount: 10,
//            dailyLimit: 4,
//            planLimit: 9
//        )
        
        // refreshUsedDataToday(1000)
        
    }
    
}
