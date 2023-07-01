//
//  App_View_Model_Sync_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 26/6/23.
//

@testable import Data_Pill
import XCTest
import Combine
import CloudKit
import CoreData
import Foundation
import OSLog

final class App_View_Model_Sync_Tests: XCTestCase {
    
    private var appViewModel: AppViewModel!
    private var networkConnectionRepository: NetworkConnectivity!
    private var localDatabase: Database!
    private var dataUsageRepository: DataUsageRepositoryProtocol!

    override func setUpWithError() throws {
        networkConnectionRepository = MockNoNetworkConnectionRepository()
        networkConnectionRepository.hasInternetConnection = true
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        localDatabase = nil
        dataUsageRepository = nil
        appViewModel = nil
    }
    
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
    
    func prevent_running_on_real_device() throws {
        #if targetEnvironment(simulator)
        #else
            XCTFail("Can't run on a Physical Device")
        #endif
    }
    
    // MARK: - Sync Plan
    /// ``syncPlan()`` is fired:
    ///  - on initialize `DataUsageRepository`, republishes `Plan`
    ///  - on active `ScenePhase`
    func test_sync_plan_while_guide_is_shown() throws {
        // (1) Given
        let startDate = Calendar.current.startOfDay(for: .init())
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!
        
        try load_fresh_data_usage_repository()
        let remoteDatabase = MockSyncRemoteDatabase()
        
        let appDataRepository =  AppDataRepository()
        appDataRepository.setWasGuideShown(false)
        
        /// Today's Data
        dataUsageRepository.addData(
            date: startDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        /// Plan is using default values
        
        // (2) When
        /// Fired from ``didChangeActiveScenePhase()``
        appViewModel.syncPlan()
        
        // (3) Then
       let syncPlan = XCTestExpectation(description: "Sync Plan")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let plan = self.dataUsageRepository.getPlan()

            XCTAssertNotNil(plan)
            XCTAssertEqual(plan!.startDate, startDate)
            XCTAssertEqual(plan!.endDate, endDate)
            XCTAssertEqual(plan!.dataAmount, 10)
            XCTAssertEqual(plan!.dailyLimit, 0.5)
            XCTAssertEqual(plan!.planLimit, 9)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncPlan.fulfill()
        }
        
        wait(for: [syncPlan], timeout: 5.0)
    }
    
    func test_sync_plan_on_fresh_plan_without_the_guide_shown_and_fresh_plan() throws {
        // (1) Given
        let startDate = Calendar.current.startOfDay(for: .init())
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!
        
        try load_fresh_data_usage_repository()
        let remoteDatabase = MockSyncRemoteDatabase()
        
        let appDataRepository =  AppDataRepository()
        appDataRepository.setWasGuideShown(true)
        
        /// Today's Data
        dataUsageRepository.addData(
            date: startDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        /// Plan is using default values
        
        // (2) When
        /// Fired from ``didChangeActiveScenePhase()``
        appViewModel.syncPlan()
        
        // (3) Then
       let syncPlan = XCTestExpectation(description: "Sync Plan")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let plan = self.dataUsageRepository.getPlan()

            XCTAssertNotNil(plan)
            XCTAssertEqual(plan!.startDate, startDate)
            XCTAssertEqual(plan!.endDate, endDate)
            XCTAssertEqual(plan!.dataAmount, 10)
            XCTAssertEqual(plan!.dailyLimit, 0.5)
            XCTAssertEqual(plan!.planLimit, 9)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncPlan.fulfill()
        }
        
        wait(for: [syncPlan], timeout: 5.0)
    }
    
    func test_sync_plan_that_has_local_changes() throws {
        // (1) Given
        let startDate = Calendar.current.startOfDay(for: .init())
        let endDate = Calendar.current.date(byAdding: .day, value: 10, to: startDate)!
        let dataAmount = 5.0
        let dataLimit = 0.1
        let planLimit = 0.45
        
        try load_fresh_data_usage_repository()
        let remoteDatabase = MockSyncRemoteDatabase()
        
        let appDataRepository =  AppDataRepository()
        appDataRepository.setWasGuideShown(true)
        
        /// Today's Data
        dataUsageRepository.addData(
            date: startDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        /// Edit Plan
        dataUsageRepository.updatePlan(
            startDate: startDate,
            endDate: endDate,
            dataAmount: dataAmount,
            dailyLimit: dataLimit,
            planLimit: planLimit,
            updateToLatestPlanAfterwards: true
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        /// Fired from ``didChangeActiveScenePhase()``
        appViewModel.syncPlan()
        
        // (3) Then
       let syncPlan = XCTestExpectation(description: "Sync Plan")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let plan = self.dataUsageRepository.getPlan()

            XCTAssertNotNil(plan)
            XCTAssertEqual(plan!.startDate, startDate)
            XCTAssertEqual(plan!.endDate, endDate)
            XCTAssertEqual(plan!.dataAmount, dataAmount)
            XCTAssertEqual(plan!.dailyLimit, dataLimit)
            XCTAssertEqual(plan!.planLimit, planLimit)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncPlan.fulfill()
        }
        
        wait(for: [syncPlan], timeout: 5.0)
    }
    
    // MARK: - Sync Today's Data
    /// ``syncTodaysData()`` is fired:
    ///  - on active `ScenePhase`
    func test_sync_todays_data_that_has_changes_in_local() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let dailyUsedData = 1_500.0
        let isSyncedToRemote = true
        let lastSyncedToRemoteDate = TestData.createDate(offset: -1, from: todaysDate)
        
        try load_fresh_data_usage_repository()
        let remoteDatabase = MockSyncTodaysDataRemoteDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: dailyUsedData,
            dailyUsedData: dailyUsedData, /// 1_500 > 1_000 (More than `RemoteDatabase`s)
            hasLastTotal: true,
            isSyncedToRemote: isSyncedToRemote, /// Data already exists in `RemoteDatabase`
            lastSyncedToRemoteDate: lastSyncedToRemoteDate
        )
        
        let addTodaysData = XCTestExpectation(description: "Add Today's Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let todaysData = self.dataUsageRepository.getTodaysData()
            
            XCTAssertNotNil(todaysData)
            XCTAssertEqual(todaysData!.date, todaysDate)
            XCTAssertEqual(todaysData!.totalUsedData, dailyUsedData)
            XCTAssertEqual(todaysData!.dailyUsedData, dailyUsedData)
            XCTAssertEqual(todaysData!.isSyncedToRemote, isSyncedToRemote)
            XCTAssertEqual(todaysData!.lastSyncedToRemoteDate, lastSyncedToRemoteDate)

            addTodaysData.fulfill()
        }
        
        wait(for: [addTodaysData], timeout: 5.0)
        
        appViewModel = .init(
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        dataUsageRepository.updateToLatestData()
        appViewModel.syncTodaysData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)

       let syncTodaysData = XCTestExpectation(description: "Sync Today's Data - Daily Usage is the Same")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let todaysData = self.dataUsageRepository.getTodaysData()

            XCTAssertNotNil(todaysData)
            XCTAssertEqual(todaysData!.dailyUsedData, dailyUsedData)
            
            XCTAssertFalse(self.appViewModel.isSyncing)
            
            syncTodaysData.fulfill()
        }
        
        wait(for: [syncTodaysData], timeout: 5.0)
    }
    
    func test_sync_todays_data_that_has_changes_in_remote() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_fresh_data_usage_repository()
        let remoteDatabase = MockSyncTodaysDataRemoteDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: false,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        let addTodaysData = XCTestExpectation(description: "Add Today's Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let todaysData = self.dataUsageRepository.getTodaysData()
            
            XCTAssertNotNil(todaysData)
            XCTAssertEqual(todaysData!.date, todaysDate)
            XCTAssertEqual(todaysData!.totalUsedData, 0)
            XCTAssertEqual(todaysData!.dailyUsedData, 0)
            XCTAssertEqual(todaysData!.isSyncedToRemote, false)
            XCTAssertEqual(todaysData!.lastSyncedToRemoteDate, nil)

            addTodaysData.fulfill()
        }
        
        wait(for: [addTodaysData], timeout: 5.0)
        
        appViewModel = .init(
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
                
        // (2) When
        appViewModel.syncTodaysData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)
        
        let syncTodaysData = XCTestExpectation(description: "Sync Today's Data - New Daily Usage, Updated Synced State")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let todaysData = self.dataUsageRepository.getTodaysData()

            XCTAssertNotNil(todaysData)
            XCTAssertEqual(todaysData!.dailyUsedData, 1_000)
            XCTAssertEqual(todaysData!.isSyncedToRemote, true)
            
            let date = todaysData!.lastSyncedToRemoteDate
            XCTAssertNotNil(date)
            
            let lastSyncedToRemoteDate = Calendar.current.startOfDay(for: date!)
            XCTAssertEqual(lastSyncedToRemoteDate, lastSyncedToRemoteDate)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncTodaysData.fulfill()
        }
        
        wait(for: [syncTodaysData], timeout: 5.0)
    }
 
    // MARK: - Sync Old Local Data
    /// ``syncOldLocalThenRemote()`` is fired:
    ///  - on active `ScenePhase` (not fired here)
    func test_sync_old_local_then_remote_that_has_local_data_to_upload() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedToRemoteDate = TestData.createDate(offset: -2, from: todaysDate)
        
        let appDataRepository = AppDataRepository()
        appDataRepository.setLastSyncedToRemoteDate(lastSyncedToRemoteDate)
        
        try load_fresh_data_usage_repository()
        let dataUsageRepository = DataUsageRepository(database: localDatabase)
        let remoteDatabase = MockSyncRemoteDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: nil
        )
        /// Yesterday
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -1, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: false, /// Data to Upload
            lastSyncedToRemoteDate: nil
        )
        /// 2 Days Ago
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -2, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: false, /// Data to Upload
            lastSyncedToRemoteDate: nil
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)

        let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            XCTAssertEqual(oldData[0].isSyncedToRemote, true)
            XCTAssertEqual(oldData[1].isSyncedToRemote, true)
            
            XCTAssertFalse(self.appViewModel.isSyncing)
            
            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    func test_sync_old_local_then_remote_that_has_local_data_to_upload_but_failed_to_login() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedToRemoteDate = TestData.createDate(offset: -2, from: todaysDate)
        
        let appDataRepository = AppDataRepository()
        appDataRepository.setLastSyncedToRemoteDate(lastSyncedToRemoteDate)
        
        try load_fresh_data_usage_repository()
        let dataUsageRepository = DataUsageRepository(database: localDatabase)
        let remoteDatabase = MockFailCloudDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: nil
        )
        /// Yesterday
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -1, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: false, /// Data to Upload
            lastSyncedToRemoteDate: nil
        )
        /// 2 Days Ago
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -2, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: false, /// Data to Upload
            lastSyncedToRemoteDate: nil
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)

        let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            XCTAssertEqual(oldData[0].isSyncedToRemote, false)
            XCTAssertEqual(oldData[1].isSyncedToRemote, false)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    func test_sync_old_local_then_remote_that_has_local_data_to_update() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedToRemoteDate = TestData.createDate(offset: -2, from: todaysDate)
        
        let appDataRepository = AppDataRepository()
        appDataRepository.setLastSyncedToRemoteDate(lastSyncedToRemoteDate)
        
        try load_fresh_data_usage_repository()
        let dataUsageRepository = DataUsageRepository(database: localDatabase)
        let remoteDatabase = MockSyncRemoteDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: nil
        )
        /// Yesterday
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -1, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: lastSyncedToRemoteDate /// Data to Update
        )
        /// 2 Days Ago
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -2, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: lastSyncedToRemoteDate /// Data to Update
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)

        let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            
            let firstDate = oldData[0].lastSyncedToRemoteDate!
            XCTAssertEqual(Calendar.current.startOfDay(for: firstDate), todaysDate)
            
            let secondDate = oldData[1].lastSyncedToRemoteDate!
            XCTAssertEqual(Calendar.current.startOfDay(for: secondDate), todaysDate)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    func test_sync_old_local_then_remote_that_has_local_data_to_update_but_failed_to_login() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedToRemoteDate = TestData.createDate(offset: -2, from: todaysDate)
        
        let appDataRepository = AppDataRepository()
        appDataRepository.setLastSyncedToRemoteDate(lastSyncedToRemoteDate)
        
        try load_fresh_data_usage_repository()
        let dataUsageRepository = DataUsageRepository(database: localDatabase)
        let remoteDatabase = MockFailCloudDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: nil
        )
        /// Yesterday
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -1, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: lastSyncedToRemoteDate /// Data to Update
        )
        /// 2 Days Ago
        dataUsageRepository.addData(
            date: TestData.createDate(offset: -2, from: todaysDate),
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: lastSyncedToRemoteDate /// Data to Update
        )
        
        appViewModel = .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)

        let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            
            let firstDate = oldData[0].lastSyncedToRemoteDate!
            XCTAssertNotEqual(Calendar.current.startOfDay(for: firstDate), todaysDate)
            
            let secondDate = oldData[1].lastSyncedToRemoteDate!
            XCTAssertNotEqual(Calendar.current.startOfDay(for: secondDate), todaysDate)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    // MARK: - Sync Old Remote Data
    /// ``syncOldLocalThenRemote()`` is fired:
    ///  - on active `ScenePhase` (not fired here)
    func test_sync_old_local_then_remote_that_has_remote_data_to_download() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_fresh_data_usage_repository()
        let dataUsageRepository = DataUsageRepository(database: localDatabase)
        let remoteDatabase = MockSyncRemoteDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: nil
        )
        
        appViewModel = .init(
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)

        let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            XCTAssertEqual(oldData[0].isSyncedToRemote, true)
            XCTAssertEqual(oldData[1].isSyncedToRemote, true)
            
            XCTAssertFalse(self.appViewModel.isSyncing)
        
            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    func test_sync_old_local_then_remote_that_has_remote_data_to_download_but_failed_to_login() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_fresh_data_usage_repository()
        let dataUsageRepository = DataUsageRepository(database: localDatabase)
        let remoteDatabase = MockFailCloudDatabase()
        
        /// Today's Data
        dataUsageRepository.addData(
            date: todaysDate,
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: true,
            lastSyncedToRemoteDate: nil
        )
        
        appViewModel = .init(
            dataUsageRepository: dataUsageRepository,
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase),
            networkConnectionRepository: networkConnectionRepository
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
        XCTAssertTrue(self.appViewModel.isSyncing)
        
        let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertTrue(oldData.isEmpty)
            
            XCTAssertFalse(self.appViewModel.isSyncing)

            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
}
