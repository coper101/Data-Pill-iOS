//
//  Mock_Data_Usage_Remote_Repository_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 13/3/23.
//

@testable import Data_Pill
import XCTest

final class Mock_Data_Usage_Remote_Repository_Tests: XCTestCase {

    private var repository: DataUsageRemoteRepositoryProtocol!
    private var repositoryFail: DataUsageRemoteRepositoryProtocol!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        repository = MockSuccessDataUsageRemoteRepository()
        repositoryFail = MockFailDataUsageRemoteRepository()
    }

    override func tearDownWithError() throws {
        repository = nil
        repositoryFail = nil
    }

    // MARK: - Plan
    func test_is_plan_added() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.isPlanAdded(),
            description: "Check Plan is Added"
        ) { isAdded in
            
            // (3) Then
            XCTAssertTrue(isAdded)
        }
    }
    
    func test_is_plan_not_added() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.isPlanAdded(),
            description: "Check Plan is Added"
        ) { isAdded in
            
            // (3) Then
            XCTAssertFalse(isAdded)
        }
    }
    
    func test_get_plan() throws {
        // (1) Given
        let remotePlan = TestData.createEmptyRemotePlan()
        
        // (2) When
        createExpectation(
            publisher: repository.getPlan(),
            description: "Get Plan"
        ) { plan in
            
            // (3) Then
            XCTAssertNotNil(plan)
            XCTAssertEqual(plan!, remotePlan)
        }
    }
    
    func test_get_empty_plan() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.getPlan(),
            description: "Get Plan"
        ) { plan in
            
            // (3) Then
            XCTAssertNil(plan)
        }
    }
    
    func test_add_plan() throws {
        // (1) Given
        let remotePlan = TestData.createEmptyRemotePlan()
        
        // (2) When
        createExpectation(
            publisher: repository.addPlan(remotePlan),
            description: "Add Plan"
        ) { isAdded in
            
            // (3) Then
            XCTAssertTrue(isAdded)
        }
    }
    
    func test_add_plan_failed() throws {
        // (1) Given
        let remotePlan = TestData.createEmptyRemotePlan()
        
        // (2) When
        createExpectation(
            publisher: repositoryFail.addPlan(remotePlan),
            description: "Add Plan"
        ) { isAdded in
            
            // (3) Then
            XCTAssertFalse(isAdded)
        }
    }
    
    func test_update_plan() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.updatePlan(
                startDate: .init(),
                endDate: .init(),
                dataAmount: 0,
                dailyLimit: 0,
                planLimit: 0
            ),
            description: "Update Plan"
        ) { isUpdated in
            
            // (3) Then
            XCTAssertTrue(isUpdated)
        }
    }
    
    func test_update_plan_failed() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.updatePlan(
                startDate: .init(),
                endDate: .init(),
                dataAmount: 0,
                dailyLimit: 0,
                planLimit: 0
            ),
            description: "Update Plan"
        ) { isUpdated in
            
            // (3) Then
            XCTAssertFalse(isUpdated)
        }
    }
    
    // MARK: - Data
    func test_is_data_added_on() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.isDataAdded(on: .init()),
            description: "Check Data is Added On"
        ) { isAdded in
            
            // (3) Then
            XCTAssertTrue(isAdded)
        }
    }
    
    func test_is_data_added_on_failed() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.isDataAdded(on: .init()),
            description: "Check Data is Added On"
        ) { isAdded in
            
            // (3) Then
            XCTAssertFalse(isAdded)
        }
    }
    
    func test_get_data() throws {
        // (1) Given
        let remoteData = TestData.createEmptyRemoteData()
        
        // (2) When
        createExpectation(
            publisher: repository.getData(on: .init()),
            description: "Get Data"
        ) { data in
            
            // (3) Then
            XCTAssertNotNil(data)
            XCTAssertEqual(data!, remoteData)
        }
    }
    
    func test_get_empty_data() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.getData(on: .init()),
            description: "Get Data"
        ) { data in
            
            // (3) Then
            XCTAssertNil(data)
        }
    }
    
    func test_add_data() throws {
        // (1) Given
        let remoteData = TestData.createEmptyRemoteData()
        
        // (2) When
        createExpectation(
            publisher: repository.addData(remoteData),
            description: "Add a Data"
        ) { isAdded in
            
            // (3) Then
            XCTAssertTrue(isAdded)
        }
    }
    
    func test_add_data_failed() throws {
        // (1) Given
        let remoteData = TestData.createEmptyRemoteData()

        // (2) When
        createExpectation(
            publisher: repositoryFail.addData(remoteData),
            description: "Add a Data"
        ) { isAdded in
            
            // (3) Then
            XCTAssertFalse(isAdded)
        }
    }
    
    func test_update_todays_data() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.updateData(
                date: .init(),
                dailyUsedData: 0
            ),
            description: "Update Data"
        ) { isUpdated in
            
            // (3) Then
            XCTAssertTrue(isUpdated)
        }
    }
    
    func test_update_data_failed() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.updateData(
                date: .init(),
                dailyUsedData: 0
            ),
            description: "Update Data"
        ) { isUpdated in
            
            // (3) Then
            XCTAssertFalse(isUpdated)
        }
    }
    
    // MARK: - User
    func test_is_logged_in_user() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.isLoggedInUser(),
            description: "Check Is User Logged In"
        ) { isLoggedIn in
            
            // (3) Then
            XCTAssertTrue(isLoggedIn)
        }
    }
    
    func test_is_not_logged_in_user() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.isLoggedInUser(),
            description: "Check Is User Logged In"
        ) { isLoggedIn in
            
            // (3) Then
            XCTAssertFalse(isLoggedIn)
        }
    }
    
    // MARK: - Synchronization
    /// Today's Data
    func test_sync_todays_data() throws {
        // (1) Given
        TestData.createLocalData { data in
                        
            XCTAssertNotNil(data)
            
            // (2) When
            self.createExpectation(
                publisher: self.repository.syncTodaysData(data!, isSyncedToRemote: true),
                description: "Sync Today's Data"
            ) { isSynced in
                
                // (3) Then
                XCTAssertTrue(isSynced)
            }
        }
    }
    
    func test_sync_todays_data_failed() throws {
        // (1) Given
        TestData.createLocalData { data in
                        
            XCTAssertNotNil(data)
            
            // (2) When
            self.createExpectation(
                publisher: self.repositoryFail.syncTodaysData(data!, isSyncedToRemote: true),
                description: "Sync Today's Data"
            ) { isSynced in
                
                // (3) Then
                XCTAssertFalse(isSynced)
            }
        }
    }
    
    /// Plan
    func test_sync_plan() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.syncPlan(
                startDate: .init(),
                endDate: .init(),
                dataAmount: 0,
                dailyLimit: 0,
                planLimit: 0
            ),
            description: "Sync Plan"
        ) { isSynced in
            
            // (3) Then
            XCTAssertTrue(isSynced)
        }
    }
    
    func test_sync_plan_failed() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.syncPlan(
                startDate: .init(),
                endDate: .init(),
                dataAmount: 0,
                dailyLimit: 0,
                planLimit: 0
            ),
            description: "Sync Plan"
        ) { isSynced in
            
            // (3) Then
            XCTAssertFalse(isSynced)
        }
    }
    
    /// All Data
    func test_sync_old_local_data() throws {
        // (1) Given
        let localData: [Data_Pill.Data] = []
        let lastSyncedDate = Date()
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then
            XCTAssertTrue(areOldDataAdded)
            XCTAssertTrue(areOldDataUpdated)
            XCTAssertTrue(addedRemoteData.isEmpty)
        }
    }
    
    func test_sync_old_local_data_failed() throws {
        // (1) Given
        let localData: [Data_Pill.Data] = []
        let lastSyncedDate = Date()

        // (2) When
        createExpectation(
            publisher: repositoryFail.syncOldLocalData(localData, lastSyncedDate: lastSyncedDate),
            description: "Sync Old Local Data"
        ) { (areOldDataAdded, areOldDataUpdated, addedRemoteData) in
            
            // (3) Then
            XCTAssertFalse(areOldDataAdded)
            XCTAssertFalse(areOldDataUpdated)
            XCTAssertTrue(addedRemoteData.isEmpty)
        }
    }
    
    func test_sync_old_remote_data() throws {
        // (1) Given
        let localData: [Data_Pill.Data] = []
        
        // (2) When
        createExpectation(
            publisher: repository.syncOldRemoteData(
                localData,
                excluding: .init()
            ),
            description: "Sync Old Remote Data"
        ) { remoteData in
            
            // (3) Then
            XCTAssertEqual(
                remoteData,
                [
                    TestData.createEmptyRemoteData(),
                    TestData.createEmptyRemoteData()
                ]
            )
        }
    }
    
    func test_sync_old_remote_data_failed() throws {
        // (1) Given
        let localData: [Data_Pill.Data] = []

        // (2) When
        createExpectation(
            publisher: repositoryFail.syncOldRemoteData(
                localData,
                excluding: .init()
            ),
            description: "Sync Old Remote Data"
        ) { remoteData in
            
            // (3) Then
            XCTAssertTrue(remoteData.isEmpty)
        }
    }
    
    // MARK: - Subscription
    /// Data
    func test_subscribe_to_remote_todays_data_changes() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.subscribeToRemoteTodaysDataChanges(),
            description: "Subscribe to Todays Data Changes"
        ) { isSubscribed in
            
            // (3) Then
            XCTAssertTrue(isSubscribed)
        }
    }
    
    func test_subscribe_to_remote_todays_data_changes_failed() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.subscribeToRemoteTodaysDataChanges(),
            description: "Subscribe to Todays Data Changes"
        ) { isSubscribed in
            
            // (3) Then
            XCTAssertFalse(isSubscribed)
        }
    }
    
    /// Plan
    func test_subscribe_to_remote_plan_changes() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repository.subscribeToRemotePlanChanges(),
            description: "Subscribe to Plan Changes"
        ) { isSubscribed in
            
            // (3) Then
            XCTAssertTrue(isSubscribed)
        }
    }
    
    func test_subscribe_to_remote_plan_changes_failed() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: repositoryFail.subscribeToRemotePlanChanges(),
            description: "Subscribe to Plan Changes"
        ) { isSubscribed in
            
            // (3) Then
            XCTAssertFalse(isSubscribed)
        }
    }
}
