//
//  AppViewModel.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import Combine
import SwiftUI
import WidgetKit
import OSLog

final class AppViewModel: ObservableObject {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    let appDataRepository: AppDataRepositoryProtocol
    let dataUsageRepository: DataUsageRepositoryProtocol
    let dataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol
    let networkDataRepository: NetworkDataRepositoryProtocol
    let networkConnectionRepository: NetworkConnectivity
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
    
    @Published var lastSyncedToRemoteDate: Date?
    
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
    
    /// [4] Network Connection
    @Published var hasInternetConnection: Bool = true

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
    
    @Published var isSyncingPlan = false
    @Published var isSyncingTodaysData = false
    @Published var isSyncingOldData = false
    
    @Published var isSyncing = false
    
    /// Background iCloud Syncing
    @Published var backgroundTaskID: UIBackgroundTaskIdentifier?
    
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
        networkConnectionRepository: NetworkConnectivity = NetworkConnectionRepository(),
        toastTimer: ToastTimer<LocalizedStringKey> = .init(),
        setupValues: Bool = true
    ) {
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.dataUsageRemoteRepository = dataUsageRemoteRepository
        self.networkDataRepository = networkDataRepository
        self.networkConnectionRepository = networkConnectionRepository
        self.toastTimer = toastTimer
        
        guard setupValues else {
            return
        }
        republishAppData()
        republishDataUsage()
        republishNetworkData()
        republishNetworkConnection()
        republishToast()
        
        setInputValues()
        
        observeSynchronization()
        observePlanSettings()
        observeRemoteData()
        observeEditPlan()
        observeDataErrors()
        
        syncRemoteOnChange()
        
        // #if DEBUG
        //     addTestData()
        // #endif
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
        
        appDataRepository.lastSyncedToRemoteDatePublisher
            .sink { [weak self] in
                self?.lastSyncedToRemoteDate = $0
                Logger.appModel.debug("lastSyncedToRemoteDate: \(String(describing: $0))")
            }
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
    
    func republishNetworkConnection() {
        networkConnectionRepository.hasInternetConnectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.hasInternetConnection = $0 }
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
    
    func observeSynchronization() {
        
        $isSyncingPlan
            .combineLatest($isSyncingTodaysData, $isSyncingOldData)
            .sink { [weak self] in self?.isSyncing = $0 || $1 || $2 }
            .store(in: &cancellables)
    }
    
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
    
    func observeRemoteData() {
        
        NotificationCenter.default
            .publisher(for: .plan)
            .sink { [weak self] _ in self?.syncLocalPlanFromRemote(true) }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .todaysData)
            .sink { [weak self] _ in self?.syncTodaysData() }
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
        
        Logger.appModel.debug("refreshUsedDataToday - todaysData: \(todaysData)")
        
        dataUsageRepository.updateData(todaysData)
    }
    
    // MARK: - Data Plan
    func didTapStartPlan() {
        closeGuide()
        appDataRepository.setIsPlanActive(true)
        dataUsageRepository.updateToLatestPlan()
    }
    
    func didTapStartNonPlan() {
        closeGuide()
        appDataRepository.setIsPlanActive(false)
        dataUsageRepository.updateToLatestPlan()
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
    
    // MARK: - Scene Phase
    func didChangeActiveScenePhase() {
        updatePlanPeriod()
        syncPlan()
        syncTodaysData()
        
        setupBackgroundTask()
        syncOldThenRemoteData()
    }

    func didChangeBackgroundScenePhase() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.main.name)
    }
    
    // MARK: - Background Task
    func setupBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Sync Old And Remote Data") { [weak self] in
            /// when background task runs out of time (30 sec starting from entering background)
            /// invalidate background task
            self?.endBackgroundTask()
        }
        Logger.appModel.debug("setupBackgroundTask - \(String(describing: self.backgroundTaskID))")
    }
    
    func endBackgroundTask() {
        if let taskID = self.backgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskID)
            backgroundTaskID = .invalid
            Logger.appModel.debug("endBackgroundTask - \(String(describing: self.backgroundTaskID))")
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
    func syncLocalPlanFromRemote(_ updateToLatestPlanAfterwards: Bool) {
        guard hasInternetConnection else {
            Logger.appModel.debug("syncLocalPlanFromRemote - no internet connection")
            return
        }
        
        dataUsageRemoteRepository.getPlan()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.appModel.debug("syncLocalPlanFromRemote - get existing plan error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                self?.isSyncingPlan = false
                
            } receiveValue: { [weak self] remotePlan in
                guard let self, let remotePlan else {
                    Logger.appModel.debug("syncLocalPlanFromRemote - get existing plan doesn't exist")
                    return
                }
                Logger.appModel.debug("syncLocalPlanFromRemote - get existing plan: \(remotePlan.startDate) - \(remotePlan.endDate)")
                
                // prevent updating plan after adding to core data - can cause this syncPlan to be triggered again
                self.dataUsageRepository.updatePlan(
                    startDate: remotePlan.startDate,
                    endDate: remotePlan.endDate,
                    dataAmount: remotePlan.dataAmount,
                    dailyLimit: remotePlan.dailyLimit,
                    planLimit: remotePlan.planLimit,
                    updateToLatestPlanAfterwards: updateToLatestPlanAfterwards
                )
            }
            .store(in: &self.cancellables)
    }
    
    func syncPlan() {
        isSyncingPlan = true
        
        guard hasInternetConnection else {
            Logger.appModel.debug("syncPlan - no internet connection")
            isSyncingPlan = false
            return
        }
        
        // write existing plan to local
        // for newly installed app or installed app then icloud authenticated with fresh default plan
        let isFreshPlan = (
            startDate == Calendar.current.startOfDay(for: .init()) &&
            endDate == Calendar.current.startOfDay(for: .init()) &&
            dataAmount == 0 &&
            dataLimit == 0 &&
            dataLimitPerDay == 0
        )
        
        // download (write existing plan to local database)
        guard wasGuideShown else {
            syncLocalPlanFromRemote(false)
            return
        }
        
        guard !isFreshPlan else {
            syncLocalPlanFromRemote(true)
            return
        }
        
        // upload
        dataUsageRemoteRepository.syncPlan(
            startDate: self.startDate,
            endDate: self.endDate,
            dataAmount: self.dataAmount,
            dailyLimit: self.dataLimitPerDay,
            planLimit: self.dataLimit
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                Logger.appModel.debug("syncPlan - is plan saved or updated: \(error.localizedDescription)")
            case .finished:
                break
            }
            self?.isSyncingPlan = false
            
        } receiveValue: { isSavedOrUpdated in
            Logger.appModel.debug("syncPlan - is plan saved or updated: \(isSavedOrUpdated)")
        }
        .store(in: &self.cancellables)
    }
    
    func syncLocalTodaysDataFromRemote() -> AnyPublisher<Bool, Never> {
        let date = Calendar.current.startOfDay(for: self.todaysData.date ?? .init())
        
        Logger.appModel.debug("syncLocalTodayDataFromRemote - today's date: \(date)")
                
        return dataUsageRemoteRepository.getData(on: date)
            .replaceError(with: nil)
            .flatMap { [weak self] (remoteData: RemoteData?) in
                guard let self, let remoteData else {
                    Logger.appModel.debug("syncLocalTodayDataFromRemote - get existing todays data doesn't exist")
                    return Just(false)
                }

                let todaysData = self.todaysData

                let remoteDailyUsedData = remoteData.dailyUsedData
                let localDailyUsedData = todaysData.dailyUsedData
                
                Logger.appModel.debug("syncLocalTodayDataFromRemote - get existing todays data from remote: \(remoteDailyUsedData)")
                Logger.appModel.debug("syncLocalTodayDataFromRemote - get existing todays data from local: \(localDailyUsedData)")

                // uddate only if remote data is more than locals e.g. (remote: 10 MB > local: 5 MB)
                if remoteDailyUsedData > localDailyUsedData {
                    Logger.appModel.debug("syncLocalTodayDataFromRemote - remote: \(remoteDailyUsedData) > local \(localDailyUsedData)")
                    todaysData.dailyUsedData = remoteData.dailyUsedData
                    self.dataUsageRepository.updateData(todaysData)
                    return Just(true)
                }
                return Just(false)
            }
            .eraseToAnyPublisher()
    }

    func syncTodaysData() {
        isSyncingTodaysData = true

        guard hasInternetConnection else {
            Logger.appModel.debug("syncTodaysData - no internet connection")
            isSyncingTodaysData = false
            return
        }
        
        // update latest from remote and write local database
        // then update remote database if any new changes in local
        syncLocalTodaysDataFromRemote()
            .flatMap { [weak self] isLocalUpdated -> AnyPublisher<(Bool, Bool), Never> in
                guard let self else {
                    return Just((isLocalUpdated, false)).eraseToAnyPublisher()
                }
                if isLocalUpdated {
                    return Just((isLocalUpdated, false)).eraseToAnyPublisher()
                }
                return self.dataUsageRemoteRepository
                    .syncTodaysData(self.todaysData, isSyncedToRemote: self.todaysData.isSyncedToRemote)
                    .replaceError(with: false)
                    .flatMap { isRemoteUpdated in
                        Just((isLocalUpdated, isRemoteUpdated))
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (values: (isLocalUpdated: Bool, isRemoteUpdated: Bool)) in
                Logger.appModel.debug("syncTodaysData - local today's data updated: \(values.isLocalUpdated)")
                Logger.appModel.debug("syncTodaysData - remote today's data updated: \(values.isRemoteUpdated)")

                guard let self else {
                    return
                }

                let todaysData = self.todaysData
                                
                // update synced date
                if (values.isRemoteUpdated || values.isLocalUpdated) {
                    todaysData.lastSyncedToRemoteDate = .init()
                }
                
                // update is synced to remote attribute
                if (values.isRemoteUpdated || values.isLocalUpdated) && !todaysData.isSyncedToRemote {
                    todaysData.isSyncedToRemote = true
                    self.dataUsageRepository.updateData(todaysData)
                }

                self.isSyncingTodaysData = false
            }
            .store(in: &self.cancellables)
    }
    
    func syncOldThenRemoteData() {
        isSyncingOldData = true
        
        guard hasInternetConnection else {
            Logger.appModel.debug("syncOldThenRemoteData - no internet connection")
            isSyncingOldData = false
            endBackgroundTask()
            return
        }
        
        var localData = dataUsageRepository.getAllData()
        Logger.appModel.debug("syncOldThenRemoteData - all local data dates: \(localData.compactMap(\.date))")

        dataUsageRemoteRepository.syncOldLocalData(localData, lastSyncedDate: lastSyncedToRemoteDate)
            .flatMap { (areOldDataAdded, areOldDataUpdated, addedRemoteData: [RemoteData]) -> AnyPublisher<(Bool, Bool, [RemoteData], [RemoteData]), Error> in
              
                localData = self.dataUsageRepository.getAllData()
                let date = Calendar.current.startOfDay(for: self.todaysData.date ?? .init())

                return self.dataUsageRemoteRepository.syncOldRemoteData(localData, excluding: date)
                    .flatMap { oldRemoteData in
                        Just((areOldDataAdded, areOldDataUpdated, addedRemoteData, oldRemoteData))
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.appModel.debug("syncOldThenRemoteData - error: \(error.localizedDescription)")
                    
                    self?.isSyncingOldData = false
                    self?.endBackgroundTask()
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (areOldDataAdded: Bool, areOldDataUpdated: Bool, addedRemoteData: [RemoteData], oldRemoteData: [RemoteData]) in
                                
                Logger.appModel.debug("syncOldThenRemoteData - old local data added to remote database: \(areOldDataAdded)")
                Logger.appModel.debug("syncOldThenRemoteData - old local data updated to remote database: \(areOldDataUpdated)")
                
                guard let self else {
                    return
                }
                                
                if !addedRemoteData.isEmpty && (areOldDataAdded || areOldDataUpdated) {
                    self.dataUsageRepository.updateData(addedRemoteData)
                        .flatMap { areUpdated in
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data to update count: \(addedRemoteData.count)")
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data updated to local database: \(areUpdated)")
                            return self.dataUsageRepository.addData(oldRemoteData, isSyncedToRemote: true)
                        }
                        .sink { areAdded in
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data to add count: \(oldRemoteData.count)")
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data added to local database: \(areAdded)")
                            
                            self.appDataRepository.setLastSyncedToRemoteDate(.init())
                            self.isSyncingOldData = false
                            self.endBackgroundTask()
                        }
                        .store(in: &self.cancellables)
                    return
                }
                
                if !oldRemoteData.isEmpty {
                    self.dataUsageRepository.addData(oldRemoteData, isSyncedToRemote: true)
                        .sink { areAdded in
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data to add count: \(oldRemoteData.count)")
                            Logger.appModel.debug("syncOldThenRemoteData - old remote data added to local database: \(areAdded)")
                            
                            self.appDataRepository.setLastSyncedToRemoteDate(.init())
                            self.isSyncingOldData = false
                            self.endBackgroundTask()
                        }
                        .store(in: &self.cancellables)
                    return
                }
                
                self.appDataRepository.setLastSyncedToRemoteDate(.init())
                self.isSyncingOldData = false
                self.endBackgroundTask()
            }
            .store(in: &self.cancellables)
    }
    
    func syncRemoteOnChange() {
        dataUsageRemoteRepository.subscribeToRemotePlanChanges()
            .flatMap { isPlanSubscribed in
                Logger.appModel.debug("syncRemoteOnChange - isPlanSubscribed: \(isPlanSubscribed)")
                return self.dataUsageRemoteRepository.subscribeToRemoteTodaysDataChanges()
            }
            .sink { isTodaysDataSubscribed in
                Logger.appModel.debug("syncRemoteOnChange - isTodaysDataSubscribed: \(isTodaysDataSubscribed)")
            }
            .store(in: &cancellables)
    }
    
}

extension AppViewModel {
    
    func addTestData() {
        Logger.appModel.debug("adding test data")
        
        let todaysDate = Date()

        let remoteDataToAdd = (1...50).map { value in
            let date = Calendar.current.date(byAdding: .day, value: Int(-value), to: todaysDate)!
            let startDate = Calendar.current.startOfDay(for: date)
            return RemoteData(date: startDate, dailyUsedData: 1_500)
        }
        // self.dataUsageRepository.addData(remoteDataToAdd, isSyncedToRemote: false)
        // Update Database
        // dataUsageRepository.updatePlan(
        //     startDate: Calendar.current.date(
        //         byAdding: .day, value: -3, to: todaysDate)!,
        //     endDate: Calendar.current.date(
        //         byAdding: .day, value: 0, to: todaysDate)!,
        //     dataAmount: 10,
        //     dailyLimit: 4,
        //     planLimit: 9
        // )
        
        // refreshUsedDataToday(1000)
    }
    
}
