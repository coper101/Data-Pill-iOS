//
//  Mock_Remote_Database_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 10/3/23.
//

@testable import Data_Pill
import XCTest
import CloudKit

final class Mock_Remote_Database_Tests: XCTestCase {
    
    private var successRemoteDatabase: RemoteDatabase!
    private var failRemoteDatabase: RemoteDatabase!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        successRemoteDatabase = MockSuccessCloudDatabase()
        failRemoteDatabase = MockFailCloudDatabase()
    }
    
    override func tearDownWithError() throws {
        successRemoteDatabase = nil
        failRemoteDatabase = nil
    }
        
    // MARK: - Account
    func test_is_available() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase.isAvailable(),
            description: "Is Available"
        ) { isAvailable in
            
            // (3) Then
            XCTAssertTrue(isAvailable)
        }
    }
    
    func test_is_available_has_error() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase.isAvailable(),
            description: "Is Available",
            onFailure: { error in
                
                // (3) Then
                let remoteDatabaseError = error as? RemoteDatabaseError
                XCTAssertNotNil(remoteDatabaseError)
                XCTAssertEqual(remoteDatabaseError, .accountError(.noAccount))
            }
        ) { _ in }
    }

    // MARK: - Records
    /// Fetch
    func test_fetch_record_success() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase.fetch(with: .init(), of: .plan),
            description: "Fetch Plan Record"
        ) { records in
            
            // (3) Then
            XCTAssertEqual(records.count, 1)
            
        }
    }
    
    func test_fetch_record_fail() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase.fetch(with: .init(), of: .plan),
            description: "Fetch Plan Record"
        ) { records in
            
            // (3) Then
            XCTAssertEqual(records.count, 0)
            
        }
    }
    
    /// Fetch All
    func test_fetch_all_records_success() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase.fetchAll(of: .plan, recursively: false),
            description: "Fetch All Plan Records"
        ) { records in
            
            // (3) Then
            XCTAssertEqual(records.count, 2)
            
        }
    }
    
    func test_fetch_all_records_fail() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase.fetchAll(of: .plan, recursively: false),
            description: "Fetch All Plan Records"
        ) { records in
            
            // (3) Then
            XCTAssertEqual(records.count, 0)
            
        }
    }
    
    /// Save Single
    func test_save_record_success() throws {
        // (1) Given
        let planRecord = TestData.createPlanRecord()
        
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase.save(record: planRecord),
            description: "Save Plan Record"
        ) { isSaved in
            
            // (3) Then
            XCTAssertTrue(isSaved)
            
        }
    }
    
    func test_save_record_fail() throws {
        // (1) Given
        let planRecord = TestData.createPlanRecord()
        
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase.save(record: planRecord),
            description: "Save Plan Record",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, RemoteDatabaseError.saveError("Save Error"))
            },
            onSuccess: { _ in }
        )
    }
    
    /// Save Multiple
    func test_save_records_success() throws {
        // (1) Given
        let planRecord = TestData.createPlanRecord()
        
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase.save(records: [planRecord, planRecord]),
            description: "Save Plan Records"
        ) { areSaved in
            
            // (3) Then
            XCTAssertTrue(areSaved)
            
        }
    }
    
    func test_save_records_fail() throws {
        // (1) Given
        let planRecord = TestData.createPlanRecord()
        
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase.save(records: [planRecord, planRecord]),
            description: "Save Plan Records",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, RemoteDatabaseError.saveError("Save Error"))
            },
            onSuccess: { _ in }
        )
    }
    
    // MARK: - Subscription
    func test_create_record_subscription_success() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase
                .createOnUpdateRecordSubscription(of: .plan, id: ""),
            description: "Create Plan Subscription"
        ) { isSubscribed in
            
            // (3) Then
            XCTAssertTrue(isSubscribed)
            
        }
    }
    
    func test_create_record_subscription_fail() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase
                .createOnUpdateRecordSubscription(of: .plan, id: ""),
            description: "Create Plan Subscription"
        ) { isSubscribed in
            
            // (3) Then
            XCTAssertFalse(isSubscribed)
            
        }
    }
    
    func test_fetch_all_subscriptions_success() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: successRemoteDatabase.fetchAllSubscriptions(),
            description: "Fetch All Subscriptions"
        ) { subscriptionIDs in
            
            // (3) Then
            XCTAssertEqual(subscriptionIDs, ["Plan", "Data"])
            
        }
    }
    
    func test_fetch_all_subscriptions_fail() throws {
        // (1) Given
        // (2) When
        createExpectation(
            publisher: failRemoteDatabase.fetchAllSubscriptions(),
            description: "Fetch All Subscriptions"
        ) { subscriptionIDs in
            
            // (3) Then
            XCTAssertEqual(subscriptionIDs, [])
            
        }
    }
}
