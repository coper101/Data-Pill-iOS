//
//  AppViewModel.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI
import Combine
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
    @Published var isSyncPlanCancelled = false
    @Published var isSyncTodaysDataCancelled = false
    @Published var isSyncOldDataCancelled = false
    
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
            remoteDatabase: MockCloudDatabase() //CloudDatabase(container: .dataPill)
        ),
        networkDataRepository: NetworkDataRepositoryProtocol = NetworkDataRepository(),
        networkConnectionRepository: NetworkConnectivity = NetworkConnectionRepository(),
        toastTimer: ToastTimer<LocalizedStringKey> = .init(),
        setupValues: Bool = true
    ) {
        self.networkConnectionRepository = networkConnectionRepository
        self.appDataRepository = appDataRepository
        self.dataUsageRepository = dataUsageRepository
        self.dataUsageRemoteRepository = dataUsageRemoteRepository
        self.networkDataRepository = networkDataRepository
        self.toastTimer = toastTimer
        
        guard setupValues else {
            return
        }
        republishNetworkConnection()
        republishAppData()
        republishDataUsage()
        republishNetworkData()
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

extension AppViewModel {
    
    func addTestData() {
        // Logger.appModel.debug("adding test data")
        
        // let todaysDate = Date()

        // let remoteDataToAdd = (1...50).map { value in
        //     let date = Calendar.current.date(byAdding: .day, value: Int(-value), to: todaysDate)!
        //     let startDate = Calendar.current.startOfDay(for: date)
        //     return RemoteData(date: startDate, dailyUsedData: 1_500)
        // }
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
