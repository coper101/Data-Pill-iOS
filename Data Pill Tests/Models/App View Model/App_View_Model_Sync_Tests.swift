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

final class App_View_Model_Sync_Tests: XCTestCase {
    
    private var appViewModel: AppViewModel!
    private var localDatabase: Database!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        localDatabase = nil
        appViewModel = nil
    }
    
    /// This deletes and create a new SQLite file of the Database
    func load_and_clear_local_database() throws {
        try check_if_simulator()
        localDatabase = LocalDatabase(container: .dataUsage, appGroup: .dataPill)
        guard let url = localDatabase.container.persistentStoreDescriptions.first?.url else {
            XCTFail("Can't find Database Store URL")
            return
        }
        let coordinator = localDatabase.container.persistentStoreCoordinator
        try coordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    }
    
    /// Prevent from running on a physical device
    func check_if_simulator() throws {
        #if targetEnvironment(simulator)
        #else
            XCTFail("Can't run on a Physical Device")
        #endif
    }
 
    // MARK: Sync Old Local Data
    func test_sync_old_local_then_remote_that_has_local_data_to_upload() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let lastSyncedToRemoteDate = TestData.createDate(offset: -2, from: todaysDate)
        
        let appDataRepository = AppDataRepository()
        appDataRepository.setLastSyncedToRemoteDate(lastSyncedToRemoteDate)
        
        try load_and_clear_local_database()
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
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
       let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            XCTAssertEqual(oldData[0].isSyncedToRemote, true)
            XCTAssertEqual(oldData[1].isSyncedToRemote, true)
            
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
        
        try load_and_clear_local_database()
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
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
       let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            XCTAssertEqual(oldData[0].isSyncedToRemote, false)
            XCTAssertEqual(oldData[1].isSyncedToRemote, false)
            
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
        
        try load_and_clear_local_database()
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
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
       let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            
            let firstDate = oldData[0].lastSyncedToRemoteDate!
            XCTAssertEqual(Calendar.current.startOfDay(for: firstDate), todaysDate)
            
            let secondDate = oldData[1].lastSyncedToRemoteDate!
            XCTAssertEqual(Calendar.current.startOfDay(for: secondDate), todaysDate)

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
        
        try load_and_clear_local_database()
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
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
       let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            
            let firstDate = oldData[0].lastSyncedToRemoteDate!
            XCTAssertNotEqual(Calendar.current.startOfDay(for: firstDate), todaysDate)
            
            let secondDate = oldData[1].lastSyncedToRemoteDate!
            XCTAssertNotEqual(Calendar.current.startOfDay(for: secondDate), todaysDate)

            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    // MARK: Sync Old Remote Data
    func test_sync_old_local_then_remote_that_has_remote_data_to_download() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_and_clear_local_database()
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
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
       let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertEqual(oldData.count, 2)
            XCTAssertEqual(oldData[0].isSyncedToRemote, true)
            XCTAssertEqual(oldData[1].isSyncedToRemote, true)
            
            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }
    
    func test_sync_old_local_then_remote_that_has_remote_data_to_download_but_failed_to_login() throws {
        // (1) Given
        let todaysDate = Calendar.current.startOfDay(for: .init())
        
        try load_and_clear_local_database()
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
            dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: remoteDatabase)
        )
        
        // (2) When
        appViewModel.syncOldThenRemoteData()
        
        // (3) Then
       let syncOldData = XCTestExpectation(description: "Sync Old Data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let allData = dataUsageRepository.getAllData()
            let oldData = allData.filter { $0.date != todaysDate }
            
            XCTAssertTrue(oldData.isEmpty)
            
            syncOldData.fulfill()
        }
        
        wait(for: [syncOldData], timeout: 5.0)
    }

}
