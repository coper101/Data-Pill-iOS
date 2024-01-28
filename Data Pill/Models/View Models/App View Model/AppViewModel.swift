//
//  AppViewModel.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI
import Combine
import OSLog

enum SyncOldDataOperation {
    case upload
    case download
}

struct SyncOldDataProgress {
    var operation: SyncOldDataOperation
    var syncedCount: Int
    var totalCount: Int
    
    var shortMessage: String {
        switch operation {
        case .upload:
            return "Syncing \(totalCount) Item to iCloud"
        case .download:
            return "Syncing \(totalCount) Items from iCloud"
        }
    }
    
    mutating func updateSynced(count: Int) {
        syncedCount = count
    }
    
    mutating func updateTotal(count: Int) {
        totalCount = count
    }
    
    mutating func updateOperation(operation: SyncOldDataOperation) {
        self.operation = operation
    }
}

final class AppViewModel: ObservableObject {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - Data
    let appDataRepository: AppDataRepositoryProtocol
    let dataUsageRepository: DataUsageRepositoryProtocol
    let dataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol
    let networkDataRepository: NetworkDataRepositoryProtocol
    let networkConnectionRepository: NetworkConnectivity
    let localNotificationManager: LocalNotification
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
    
    @Published var todaysLastNotificationDate: Date?
    @Published var planLastNotificationDate: Date?
    
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
    @Published var hasInternetConnection: Bool = false

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
    
    var dataUsedInPercentage: Int {
        usedData.toPercentage(with: maxData)
    }
    
    // MARK: - UI
    @Published var isGuideShown = false
    @Published var isPlanActive = false
    @Published var isHistoryShown = false
    @Published var isBlurShown = false
    @Published var isTappedOutside = false
    @Published var isLongPressedOutside = false
    
    @Published var isSettingsShown = false
    @Published var activeSettingsScreen: SettingsScreen? = nil
    
    
    @Published var isSyncingPlan = false
    @Published var isSyncingTodaysData = false
    @Published var isSyncingOldData = false
    
    @Published var syncOldDataProgress: SyncOldDataProgress? = nil
    
    @Published var isSyncing = false
    @Published var isSyncPlanCancelled = false
    @Published var isSyncTodaysDataCancelled = false
    @Published var isSyncOldDataCancelled = false
    
    var syncStatus: SyncStatus {
        if isSyncing && isSyncingPlan {
            return .syncing(message: "Syncing")
            
        } else if isSyncing && isSyncingTodaysData {
            return .syncing(message: "Syncing")
            
        } else if isSyncing && isSyncingOldData {
            return .syncing(message: syncOldDataProgress?.shortMessage ?? "Syncing")
            
        } else if (isSyncPlanCancelled || isSyncTodaysDataCancelled || isSyncOldDataCancelled) {
            return .failed(message: "Syncing Unavailable")
            
        } else {
            return .synced
            
        }
    }
    
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
    @Published var dayColors: [Day: Colors] = defaultDayColors
    
    /// Settings
    @Published var isDarkMode = false
    @Published var hasDailyNotification = false
    @Published var hasPlanNotification = false
    @Published var isNotificationAlertShown: Bool = false
    
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
    
    // MARK: - Initializer
    /// - parameters:
    ///   - appDataRepository: The data source for app settings
    ///   - dataUsageRepository: The data source for data usage persistence
    ///   - networkDataRepository: The data source for ceullular data usage
    ///   - networkConnectionRepository: The data source for internet connection
    ///   - toastTimer: The timer for showing Toast
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
        localNotificationManager: LocalNotification = LocalNotificationManager.shared,
        toastTimer: ToastTimer<LocalizedStringKey> = .init(),
        setupValues: Bool = true
    ) {
        self.networkConnectionRepository = networkConnectionRepository
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.dataUsageRemoteRepository = dataUsageRemoteRepository
        self.networkDataRepository = networkDataRepository
        self.localNotificationManager = localNotificationManager
        self.toastTimer = toastTimer
        
        if 
            ProcessInfo.isUITesting &&
            ProcessInfo.isMockedCloud &&
            ProcessInfo.isMockedMobileData
        {
            addTestData()
        }
        
        guard setupValues else {
            return
        }
        
        /// Disable iCloud for Now
        // republishNetworkConnection()
        republishAppData()
        republishDataUsage()
        // republishDataUsageRemote()
        republishNetworkData()
        republishToast()
        
        setInputValues()
        
        // observeSynchronization()
        observePlanSettings()
        // observeRemoteData()
        observeEditPlan()
        observeDataErrors()
        observeSettings()
        
        // syncRemoteOnChange()
    }
}

extension AppViewModel {
    
    func addTestData() {
        let todaysDate = Date()
        let remoteDataToAdd = (1...50).map { value in
            let date = Calendar.current.date(byAdding: .day, value: Int(-value), to: todaysDate)!
            let startDate = Calendar.current.startOfDay(for: date)
            return RemoteData(date: startDate, dailyUsedData: 1_500)
        }
        
        Logger.appModel.debug("- TESTING DATA: ✏️ Adding Old Data")
        self.dataUsageRepository.addData(remoteDataToAdd, isSyncedToRemote: false)
            .sink { areAdded in
                Logger.appModel.debug("- TESTING DATA: ✅ Added Successfully")
            }
            .store(in: &cancellables)
    }
}
