//
//  App_View_Model_Cloud_Sync_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 2/7/23.
//

@testable import Data_Pill
import XCTest
import CloudKit

final class App_View_Model_Cloud_Sync_Tests: XCTestCase {
    
    private var appViewModel: AppViewModel!
    
    private var dataUsageRepository: DataUsageRepositoryProtocol!
    private var localDatabase: Database!
    private var remoteDatabase: RemoteDatabase!
    private var remoteData: CloudData!
    private var appDataRepository: AppDataRepositoryProtocol!

    override func setUpWithError() throws {
        continueAfterFailure = false
        remoteData = .init()
    }

    override func tearDownWithError() throws {
        appViewModel = nil
        dataUsageRepository = nil
        localDatabase = nil
        remoteDatabase = nil
        remoteData = nil
        appDataRepository = nil
    }

    // MARK: - Helpers
    func load_fresh_data_usage_repository() throws {
        try prevent_running_on_real_device()
        localDatabase = LocalDatabase(container: .dataUsage, appGroup: .dataPill)
        dataUsageRepository = DataUsageRepository(database: localDatabase)
    
        /// delete all Data
        createExpectation(
            publisher: dataUsageRepository.deleteAllData(),
            description: "Delete All Data"
        ) { areDeleted in
            XCTAssertTrue(areDeleted)
        }
        
        /// delete all Plan
        createExpectation(
            publisher: dataUsageRepository.deleteAllPlan(),
            description: "Delete All Plan"
        ) { areDeleted in
            XCTAssertTrue(areDeleted)
            self.dataUsageRepository.updateToLatestData()
            self.dataUsageRepository.updateToLatestPlan()
        }
    }
    
    func load_fresh_app_data_repository() throws {
        appDataRepository = AppDataRepository()
        appDataRepository.setWasGuideShown(false)
    }
    
    func load_fresh_remote_database(hasAccess: Bool = true) throws {
        remoteDatabase = MockCloudDatabase(hasAccess: hasAccess, data: remoteData)
    }
    
    func setup_up_app_view_model(hasInternet: Bool = true) throws {
        appViewModel = createAppViewModel(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkDataRepository: MockNetworkDataRepository(), /// use mock as it crashes,
            networkConnectionRepository: hasInternet ? MockHasNetworkConnectionRepository() : MockNoNetworkConnectionRepository(),
            setupValues: true
        )
    }
    
    func prevent_running_on_real_device() throws {
        #if targetEnvironment(simulator)
        #else
            XCTFail("Can't run on a Physical Device")
        #endif
    }
    
    // MARK: - New User
    /// * Preconditions  *
    /// - Network Connection:  Unavailable
    /// - Remote Database: No Internet
    ///
    /// * New User  *
    /// 1. User has Installed the App
    /// 2. Open App
    ///
    /// * Initial *
    /// - Remote Database: Empty
    /// - Local Database: Today's Data, Plan
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Plan
    /// - Local Database: Today's Data (Not Synced), Plan (Not Synced)
    func test_on_launch_app_new_user_no_internet_connection() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_fresh_app_data_repository()
        try load_fresh_remote_database()
        try load_fresh_data_usage_repository()
        try setup_up_app_view_model(hasInternet: false)
        
        /// - Network Connection is  Unavailable
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)

        /// - Remote: Check Empty Data
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }

        /// - Remote: Check Empty Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            
            XCTAssertTrue(records.isEmpty)
        }

        // (2) When
        /// - On Appear App UI
        appViewModel.didChangeActiveScenePhase()
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)

        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Today's Data Again (No Change)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check Plan Again (No Change)
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        /// - Local: Old Data (None)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertTrue(oldData.isEmpty)
        
        /// - Remote: Check Uploaded Data (Empty)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
        
        /// - Remote: Check Uploaded Plan (Empty)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
    }
    
    /// * Preconditions  *
    /// - Network Connection:  Available
    /// - Remote Database: Not Allowed (Not Logged In, Disabled iCloud)
    ///
    /// * New User  *
    /// 1. User has Installed the App
    /// 2. Open App
    ///
    /// * Initial *
    /// - Remote Database: Empty
    /// - Local Database: Today's Data, Plan
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Plan
    /// - Local Database: Today's Data (Not Synced), Plan (Not Synced)
    func test_on_launch_app_new_user_no_access_to_remote_database() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_fresh_app_data_repository()
        try load_fresh_remote_database(hasAccess: false)
        try load_fresh_data_usage_repository()
        try setup_up_app_view_model()
        
        /// - Network Connection is  Unavailable
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)

        /// - Remote: Check Empty Data
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }

        /// - Remote: Check Empty Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            
            XCTAssertTrue(records.isEmpty)
        }

        // (2) When
        /// - On Appear App UI
        appViewModel.didChangeActiveScenePhase()
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)

        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Today's Data Again (No Change)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check Plan Again (No Change)
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        /// - Local: Old Data (None)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertTrue(oldData.isEmpty)
        
        /// - Remote: Check Uploaded Data (Empty)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
        
        /// - Remote: Check Uploaded Plan (Empty)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
    }

    /// * Preconditions  *
    /// - Network Connection: Available
    /// - Remote Database: Has Access
    ///
    /// * New User  *
    /// 1. User has Installed the App
    /// 2. Open App
    ///
    /// * Initial *
    /// - Remote Database: Empty
    /// - Local Database: Today's Data, Plan
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Plan
    /// - Local Database: Today's Data (Synced), Plan (Synced)
    func test_on_launch_app_new_user() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_fresh_app_data_repository()
        try load_fresh_remote_database()
        try load_fresh_data_usage_repository()

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)

        /// - Remote: Check Empty Data
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }

        /// - Remote: Check Empty Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
        
        try setup_up_app_view_model()
        
        /// - Network Connection is Available
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)

        // (2) When
        /// - On Appear App UI
        appViewModel.didChangeActiveScenePhase()
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)

        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Today's Data Again (No Change)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertTrue(todaysData.isSyncedToRemote)
        XCTAssertNotNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check Plan Again (No Change)
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        /// - Local: Old Data (None)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertTrue(oldData.isEmpty)
        
        /// - Remote: Check Uploaded Data (Today's Data)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 1)
            
            let firstRecord = records.first
            XCTAssertNotNil(firstRecord)
            
            let todaysRemoteData = RemoteData.toRemoteData(firstRecord!)
            XCTAssertNotNil(todaysRemoteData)

            XCTAssertEqual(todaysRemoteData!.date, todaysDate)
        }
        
        /// - Remote: Check Uploaded Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
        }
    }
    
    /// * Preconditions  *
    /// - Network Connection: Available
    /// - Remote Database: Has Now Access
    ///
    /// * New User  *
    /// 1. User has Installed the App
    /// 2. Open App
    /// 3. Dismiss User Guide
    /// 3. App goes in Background
    /// 4. App comes to Foreground
    ///
    /// * Initial *
    /// - Remote Database: Empty
    /// - Local Database: Today's Data, Plan
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Plan
    /// - Local Database: Today's Data (No Change as Previously Synced), Plan (No Change as Previously Synced)
    func test_on_launch_app_new_user_open_app_comes_to_foreground() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        try test_on_launch_app_new_user()
        
        // (2) When
        /// - 3.
        appViewModel.didTapStartPlan()
        XCTAssertEqual(appViewModel.wasGuideShown, true)
        XCTAssertEqual(appViewModel.isGuideShown, false)
        
        /// - 4.
        appViewModel.didChangeActiveScenePhase()

        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Remote: Check Uploaded Data (Today's Data)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 1)
            
            let firstRecord = records.first
            XCTAssertNotNil(firstRecord)
            
            let todaysRemoteData = RemoteData.toRemoteData(firstRecord!)
            XCTAssertNotNil(todaysRemoteData)

            XCTAssertEqual(todaysRemoteData!.date, todaysDate)
        }
        
        /// - Remote: Check Uploaded Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
        }
    }
    
    // MARK: - Existing User
    /// * Preconditions  *
    /// - Network Connection: Unavailable
    /// - Remote Database: No Internet
    ///
    /// * Existing User *
    /// 1. User has Installed the App
    /// 2. Open App
    ///
    /// * Initial  *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Today's Data, Old Data, Plan
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Today's Data (Not Synced), Existing Old Data (None), Existing Plan (Not Synced)
    func test_on_launch_app_existing_user_no_internet_connection() throws {
        // (1) Given
        try load_fresh_remote_database()

        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesteredayDate = TestData.createDate(offset: -1, from: todaysDate)
        
        let planStartDate = TestData.createDate(offset: -15, from: todaysDate)
        let planEndDate = TestData.createDate(offset: 15, from: todaysDate)
        
        let records: [CKRecord] = [
            /// Today's Data
            TestData.createDataRecord(date: todaysDate, dailyUsedData: 100),
            /// Plan
            TestData.createPlanRecord(
                startDate: planStartDate,
                endDate: planEndDate,
                dataAmount: 15,
                dailyLimit: 0.5,
                planLimit: 14
            ),
            /// Old Data
            TestData.createDataRecord(date: yesteredayDate, dailyUsedData: 50),
        ]
        
        createExpectation(
            publisher: remoteDatabase.save(records: records),
            description: "Save Records"
        ) { areSaved in
            XCTAssertTrue(areSaved)
        }
        
        /// - Remote: Check Existing Data (Today's Data, Old Data)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
            
            let firstRecord = records[0]
            let secondRecord = records[1]
            
            let todaysRemoteData = RemoteData.toRemoteData(secondRecord)
            XCTAssertNotNil(todaysRemoteData)
            XCTAssertEqual(todaysRemoteData!.date, todaysDate)
            XCTAssertEqual(todaysRemoteData!.dailyUsedData, 100)
            
            let yesterdayRemoteData = RemoteData.toRemoteData(firstRecord)
            XCTAssertNotNil(yesterdayRemoteData)
            XCTAssertEqual(yesterdayRemoteData!.dailyUsedData, 50)
        }
        
        /// - Remote: Check Existing Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
            
            let firstRecord = records[0]

            let remotePlan = RemotePlan.toRemotePlan(firstRecord)
            XCTAssertNotNil(remotePlan)
            XCTAssertEqual(remotePlan!.startDate, planStartDate)
            XCTAssertEqual(remotePlan!.endDate, planEndDate)
            XCTAssertEqual(remotePlan!.dataAmount, 15)
            XCTAssertEqual(remotePlan!.planLimit, 14)
            XCTAssertEqual(remotePlan!.dailyLimit, 0.5)
        }
        
        try load_fresh_app_data_repository()
        try load_fresh_data_usage_repository()
        try setup_up_app_view_model(hasInternet: false)
        
        /// - Network Connection is Unavailable
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        // (2) When
        /// - On Appear App UI
        appViewModel.didChangeActiveScenePhase()
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)
        
        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Local Plan
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        /// - Local: Check Updated Data (Today's Data)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check New Data (Old Data - Yesterday)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertTrue(oldData.isEmpty)
        
        /// - Remote: Check Existing Data Again (No Change)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
        }
        
        /// - Remote: Check Existing Plan Again (No Change)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
        }
    }
    
    /// * Preconditions  *
    /// - Network Connection: Unavailable
    /// - Remote Database: No Internet
    ///
    /// * Existing User *
    /// 1. User has Installed the App
    /// 2. Open App
    ///
    /// * Initial  *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Today's Data, Plan
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Today's Data (No Synced), Existing Old Data (No Synced), Existing Plan (Not Synced)
    func test_on_launch_app_existing_user_no_access_to_remote_database() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesteredayDate = TestData.createDate(offset: -1, from: todaysDate)
        
        let planStartDate = TestData.createDate(offset: -15, from: todaysDate)
        let planEndDate = TestData.createDate(offset: 15, from: todaysDate)
        
        /// Add Plan
        remoteData.planRecords.add(
            TestData.createPlanRecord(
                startDate: planStartDate,
                endDate: planEndDate,
                dataAmount: 15,
                dailyLimit: 0.5,
                planLimit: 14
            )
        )
        /// Add Today's Data
        remoteData.dataRecords.add(
            TestData.createDataRecord(date: todaysDate, dailyUsedData: 100)
        )
        /// Add Old Data
        remoteData.dataRecords.add(
            TestData.createDataRecord(date: yesteredayDate, dailyUsedData: 50)
        )
               
        try load_fresh_remote_database(hasAccess: false)
        try load_fresh_app_data_repository()
        try load_fresh_data_usage_repository()
        try setup_up_app_view_model(hasInternet: true)
        
        /// - Network Connection is Available
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        // (2) When
        /// - On Appear App UI
        appViewModel.didChangeActiveScenePhase()
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)
        
        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Local Plan
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        /// - Local: Check Updated Data (Today's Data)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check New Data (Old Data - Yesterday)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertTrue(oldData.isEmpty)
        
        /// - Remote: Check Existing Data Again (No Change)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
        }
        
        /// - Remote: Check Existing Plan Again (No Change)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
        }
    }
    
    /// * Preconditions  *
    /// - Network Connection: Available
    /// - Remote Database: Has Access
    ///
    /// * Existing User *
    /// 1. User has Installed the App
    /// 2. Open App
    ///
    /// * Initial  *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Empty
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Existing Today's Data, Existing Old Data, Existing Plan
    func test_on_launch_app_existing_user() throws {
        // (1) Given
        try load_fresh_remote_database()

        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesteredayDate = TestData.createDate(offset: -1, from: todaysDate)
        
        let planStartDate = TestData.createDate(offset: -15, from: todaysDate)
        let planEndDate = TestData.createDate(offset: 15, from: todaysDate)
        
        let records: [CKRecord] = [
            /// Today's Data
            TestData.createDataRecord(date: todaysDate, dailyUsedData: 100),
            /// Plan
            TestData.createPlanRecord(
                startDate: planStartDate,
                endDate: planEndDate,
                dataAmount: 15,
                dailyLimit: 0.5,
                planLimit: 14
            ),
            /// Old Data
            TestData.createDataRecord(date: yesteredayDate, dailyUsedData: 50),
        ]
        
        createExpectation(
            publisher: remoteDatabase.save(records: records),
            description: "Save Records"
        ) { areSaved in
            XCTAssertTrue(areSaved)
        }
        
        /// - Remote: Check Existing Data (Today's Data, Old Data)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
            
            let firstRecord = records[0]
            let secondRecord = records[1]
            
            let todaysRemoteData = RemoteData.toRemoteData(secondRecord)
            XCTAssertNotNil(todaysRemoteData)
            XCTAssertEqual(todaysRemoteData!.date, todaysDate)
            XCTAssertEqual(todaysRemoteData!.dailyUsedData, 100)
            
            let yesterdayRemoteData = RemoteData.toRemoteData(firstRecord)
            XCTAssertNotNil(yesterdayRemoteData)
            XCTAssertEqual(yesterdayRemoteData!.dailyUsedData, 50)
        }
        
        /// - Remote: Check Existing Plan
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
            
            let firstRecord = records[0]

            let remotePlan = RemotePlan.toRemotePlan(firstRecord)
            XCTAssertNotNil(remotePlan)
            XCTAssertEqual(remotePlan!.startDate, planStartDate)
            XCTAssertEqual(remotePlan!.endDate, planEndDate)
            XCTAssertEqual(remotePlan!.dataAmount, 15)
            XCTAssertEqual(remotePlan!.planLimit, 14)
            XCTAssertEqual(remotePlan!.dailyLimit, 0.5)
        }
        
        try load_fresh_app_data_repository()
        try load_fresh_data_usage_repository()

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        try setup_up_app_view_model()
        
        /// - Network Connection is Available
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)
        
        // (2) When
        /// - On Appear App UI
        appViewModel.didChangeActiveScenePhase()
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)
        
        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Local Plan
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, planStartDate)
        XCTAssertEqual(plan.endDate, planEndDate)
        XCTAssertEqual(plan.dataAmount, 15)
        XCTAssertEqual(plan.dailyLimit, 0.5)
        XCTAssertEqual(plan.planLimit, 14)
        
        /// - Local: Check Updated Data (Today's Data)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertTrue(todaysData.isSyncedToRemote)
        XCTAssertNotNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check New Data (Old Data - Yesterday)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertEqual(oldData.count, 1)
        
        let yesterdaysData = try XCTUnwrap(oldData.first)
        XCTAssertEqual(yesterdaysData.date, yesteredayDate)
        XCTAssertTrue(yesterdaysData.isSyncedToRemote)
        XCTAssertNotNil(yesterdaysData.lastSyncedToRemoteDate)
        
        /// - Remote: Check Existing Data Again (Today's Data, Old Data)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
            
            let firstRecord = records[0]
            let secondRecord = records[1]
            
            let todaysRemoteData = RemoteData.toRemoteData(secondRecord)
            XCTAssertNotNil(todaysRemoteData)
            XCTAssertEqual(todaysRemoteData!.date, todaysDate)
            XCTAssertEqual(todaysRemoteData!.dailyUsedData, 100)
            
            let yesterdayRemoteData = RemoteData.toRemoteData(firstRecord)
            XCTAssertNotNil(yesterdayRemoteData)
            XCTAssertEqual(yesterdayRemoteData!.dailyUsedData, 50)
        }
        
        /// - Remote: Check Existing Plan Again
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
            
            let firstRecord = records[0]

            let remotePlan = RemotePlan.toRemotePlan(firstRecord)
            XCTAssertNotNil(remotePlan)
            XCTAssertEqual(remotePlan!.startDate, planStartDate)
            XCTAssertEqual(remotePlan!.endDate, planEndDate)
            XCTAssertEqual(remotePlan!.dataAmount, 15)
            XCTAssertEqual(remotePlan!.planLimit, 14)
            XCTAssertEqual(remotePlan!.dailyLimit, 0.5)
        }
    }
    
    /// * Preconditions  *
    /// - Network Connection: Available
    /// - Remote Database: Has Now Access
    ///
    /// * Existing User  *
    /// 1. User has Installed the App
    /// 2. Open App
    /// 3. Dismiss User Guide
    /// 3. App goes in Background - User Logins to iCloud Account or Network Connection is Available
    /// 4. App comes to Foreground
    ///
    /// * Initial  *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Empty
    ///
    /// * Output *
    /// - Remote Database: Today's Data, Old Data, Plan
    /// - Local Database: Existing Today's Data, Existing Old Data, Existing Plan
    func test_on_launch_app_existing_user_open_app_comes_to_foreground_with_access_to_remote_database() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesteredayDate = TestData.createDate(offset: -1, from: todaysDate)
        
        let planStartDate = TestData.createDate(offset: -15, from: todaysDate)
        let planEndDate = TestData.createDate(offset: 15, from: todaysDate)
        
        /// Add Plan
        remoteData.planRecords.add(
            TestData.createPlanRecord(
                startDate: planStartDate,
                endDate: planEndDate,
                dataAmount: 15,
                dailyLimit: 0.5,
                planLimit: 14
            )
        )
        /// Add Today's Data
        remoteData.dataRecords.add(
            TestData.createDataRecord(date: todaysDate, dailyUsedData: 100)
        )
        /// Add Old Data
        remoteData.dataRecords.add(
            TestData.createDataRecord(date: yesteredayDate, dailyUsedData: 50)
        )
        
        try load_fresh_remote_database(hasAccess: true)
        try load_fresh_app_data_repository()
        try load_fresh_data_usage_repository()

        /// - Local: Check Today's Data Exist (Not Synced to Remote)
        var todaysData = try XCTUnwrap(dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertFalse(todaysData.isSyncedToRemote)
        XCTAssertNil(todaysData.lastSyncedToRemoteDate)

        /// - Local: Check Plan Exist (Fresh Plan, Not Synced To Remote)
        var plan = try XCTUnwrap(dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, todaysDate)
        XCTAssertEqual(plan.endDate, todaysDate)
        XCTAssertEqual(plan.dataAmount, 0)
        XCTAssertEqual(plan.dailyLimit, 0)
        XCTAssertEqual(plan.planLimit, 0)
        
        try setup_up_app_view_model()
        
        /// - Network Connection is Available
        let hasInternetConnection = XCTestExpectation(description: "Internet Connection is Available")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.appViewModel.hasInternetConnection)
            hasInternetConnection.fulfill()
        }
        wait(for: [hasInternetConnection], timeout: 5.0)
        
        // (2) When
        /// - On Appear App UI (1st Time App Comes to Foreground)
        appViewModel.showGuide()
        
        /// - Guide is Shown
        XCTAssertTrue(appViewModel.isGuideShown)
        
        /// - Guide is Dismissed
        appViewModel.didTapStartPlan()
        XCTAssertTrue(appViewModel.wasGuideShown)
        XCTAssertFalse(appViewModel.isGuideShown)
        
        /// - On Appear App UI (2nd Time App Comes to Foreground)
        appViewModel.didChangeActiveScenePhase()
        
        // (3) Then
        /// - Syncing Today's Data, Plan and Old Data
        let syncing = XCTestExpectation(description: "Syncing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            syncing.fulfill()
        }
        wait(for: [syncing], timeout: 5.0)
        
        /// - Local: Check Local Plan
        plan = try XCTUnwrap(appViewModel.dataUsageRepository.getPlan())
        XCTAssertEqual(plan.startDate, planStartDate)
        XCTAssertEqual(plan.endDate, planEndDate)
        XCTAssertEqual(plan.dataAmount, 15)
        XCTAssertEqual(plan.dailyLimit, 0.5)
        XCTAssertEqual(plan.planLimit, 14)
        
        /// - Local: Check Updated Data (Today's Data)
        todaysData = try XCTUnwrap(appViewModel.dataUsageRepository.getTodaysData())
        XCTAssertEqual(todaysData.date, todaysDate)
        XCTAssertTrue(todaysData.isSyncedToRemote)
        XCTAssertNotNil(todaysData.lastSyncedToRemoteDate)
        
        /// - Local: Check New Data (Old Data - Yesterday)
        let allData = appViewModel.dataUsageRepository.getAllData()
        let oldData = allData.filter { $0.date != todaysDate }
        XCTAssertEqual(oldData.count, 1)
        
        let yesterdaysData = try XCTUnwrap(oldData.first)
        XCTAssertEqual(yesterdaysData.date, yesteredayDate)
        XCTAssertTrue(yesterdaysData.isSyncedToRemote)
        XCTAssertNotNil(yesterdaysData.lastSyncedToRemoteDate)
        
        /// - Remote: Check Existing Data Again (Today's Data, Old Data)
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Remote Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
            
            let firstRecord = records[0]
            let secondRecord = records[1]
            
            let todaysRemoteData = RemoteData.toRemoteData(firstRecord)
            XCTAssertNotNil(todaysRemoteData)
            XCTAssertEqual(todaysRemoteData!.date, todaysDate)
            XCTAssertEqual(todaysRemoteData!.dailyUsedData, 100)
            
            let yesterdayRemoteData = RemoteData.toRemoteData(secondRecord)
            XCTAssertNotNil(yesterdayRemoteData)
            XCTAssertEqual(yesterdayRemoteData!.dailyUsedData, 50)
        }
        
        /// - Remote: Check Existing Plan Again
        createExpectation(
            publisher: remoteDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Remote Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
            
            let firstRecord = records[0]

            let remotePlan = RemotePlan.toRemotePlan(firstRecord)
            XCTAssertNotNil(remotePlan)
            XCTAssertEqual(remotePlan!.startDate, planStartDate)
            XCTAssertEqual(remotePlan!.endDate, planEndDate)
            XCTAssertEqual(remotePlan!.dataAmount, 15)
            XCTAssertEqual(remotePlan!.planLimit, 14)
            XCTAssertEqual(remotePlan!.dailyLimit, 0.5)
        }
    }
}
