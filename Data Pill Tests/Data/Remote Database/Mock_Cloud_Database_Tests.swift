//
//  Mock_Cloud_Database_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 2/7/23.
//

@testable import Data_Pill
import XCTest
import CloudKit

final class Mock_Cloud_Database_Tests: XCTestCase {
    
    private var cloudDatabase: RemoteDatabase!

    override func setUpWithError() throws {
        cloudDatabase = MockCloudDatabase()
    }

    override func tearDownWithError() throws {
        cloudDatabase = nil
    }

    // MARK: - Status
    func test_is_logged_in() throws {
        createExpectation(
            publisher: cloudDatabase.checkLoginStatus(),
            description: "Is Logged In"
        ) { isLoggedIn in
            XCTAssertTrue(isLoggedIn)
        }
    }
    
    // MARK: - Fetch
    func test_fetch_all_plan_is_empty() throws {
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Plan"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
    }
    
    func test_fetch_all_data_is_empty() throws {
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
    }
    
    // MARK: - Save Plan Record
    func test_save_new_plan_record() throws {
        let record = TestData.createPlanRecord(
            startDate: .init(),
            endDate: .init(),
            dataAmount: 10,
            dailyLimit: 10,
            planLimit: 10
        )
        
        /// save
        createExpectation(
            publisher: cloudDatabase.save(record: record),
            description: "Save New Plan Record"
        ) { isSaved in
            XCTAssertTrue(isSaved)
        }
        
        /// check if saved
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Plan"
        ) { records in
            XCTAssertEqual(records.count, 1)
        }
    }
    
    func test_save_existing_plan_record() throws {
        /// save new plan
        try test_save_new_plan_record()
        
        /// get existing plan
        var planRecord: CKRecord? = nil
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .plan, recursively: false),
            description: "Fetch Existing Plan"
        ) { records in
            XCTAssertTrue(!records.isEmpty)
            planRecord = records.first
        }
        
        /// save existing plan
        planRecord?.setValue(12.0, forKey: "dataAmount")
        createExpectation(
            publisher: cloudDatabase.save(record: planRecord!),
            description: "Save Existing Plan Record"
        ) { isSaved in
            XCTAssertTrue(isSaved)
        }
        
        /// check correct value
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .plan, recursively: false),
            description: "Fetch Existing Plan"
        ) { records in
            XCTAssertTrue(!records.isEmpty)
            XCTAssertEqual(records.count, 1)
            
            planRecord = records.first
            XCTAssertNotNil(planRecord)
            
            let remotePlan = RemotePlan.toRemotePlan(planRecord!)
            XCTAssertNotNil(remotePlan)
            
            XCTAssertEqual(remotePlan!.dataAmount, 12.0)
        }
    }
    
    // MARK: - Save Data Record
    func test_save_new_data_record() throws {
        let record = TestData.createDataRecord(date: .init(), dailyUsedData: 10)
        
        /// save
        createExpectation(
            publisher: cloudDatabase.save(record: record),
            description: "Save New Data Record"
        ) { isSaved in
            XCTAssertTrue(isSaved)
        }
        
        /// check if saved
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Data"
        ) { records in
            XCTAssertEqual(records.count, 1)
        }
    }
    
    func test_save_new_data_records() throws {
        let todaysData = Calendar.current.startOfDay(for: .init())
        let records = [
            TestData.createDataRecord(
                date: TestData.createDate(offset: -1, from: todaysData),
                dailyUsedData: 10
            ),
            TestData.createDataRecord(
                date: TestData.createDate(offset: -2, from: todaysData),
                dailyUsedData: 10
            )
        ]
        
        /// save
        createExpectation(
            publisher: cloudDatabase.save(records: records),
            description: "Save New Data Records"
        ) { isSaved in
            XCTAssertTrue(isSaved)
        }
        
        /// check if saved
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
        }
    }
    
    func test_save_existing_data_record() throws {
        /// save new data
        try test_save_new_data_record()
        
        /// get existing data
        var dataRecord: CKRecord? = nil
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: false),
            description: "Fetch Existing Data"
        ) { records in
            XCTAssertTrue(!records.isEmpty)
            dataRecord = records.first
        }
        
        /// save existing data
        dataRecord?.setValue(20.0, forKey: "dailyUsedData")
        createExpectation(
            publisher: cloudDatabase.save(record: dataRecord!),
            description: "Save Existing Data Record"
        ) { isSaved in
            XCTAssertTrue(isSaved)
        }
        
        /// check correct value
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: false),
            description: "Fetch Existing Data"
        ) { records in
            XCTAssertTrue(!records.isEmpty)
            XCTAssertEqual(records.count, 1)
            
            dataRecord = records.first
            XCTAssertNotNil(dataRecord)
            
            let remoteData = RemoteData.toRemoteData(dataRecord!)
            XCTAssertNotNil(remoteData)
            
            XCTAssertEqual(remoteData!.dailyUsedData, 20.0)
        }
    }
    
    func test_save_existing_data_records() throws {
        /// save new data
        try test_save_new_data_records()
        
        /// get existing data
        var dataRecord1: CKRecord? = nil
        var dataRecord2: CKRecord? = nil
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: false),
            description: "Fetch Existing Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
            dataRecord1 = records[0]
            dataRecord2 = records[1]
        }
        
        /// save existing data
        dataRecord1?.setValue(21.0, forKey: "dailyUsedData")
        dataRecord2?.setValue(22.0, forKey: "dailyUsedData")
        createExpectation(
            publisher: cloudDatabase.save(records: [dataRecord1!, dataRecord2!]),
            description: "Save Existing Data Records"
        ) { isSaved in
            XCTAssertTrue(isSaved)
        }
        
        /// check correct value
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: false),
            description: "Fetch Existing Data"
        ) { records in
            XCTAssertEqual(records.count, 2)
            
            dataRecord1 = records[0]
            XCTAssertNotNil(dataRecord1)
            
            dataRecord2 = records[1]
            XCTAssertNotNil(dataRecord2)
            
            let remoteData1 = RemoteData.toRemoteData(dataRecord1!)
            XCTAssertNotNil(remoteData1)
            
            let remoteData2 = RemoteData.toRemoteData(dataRecord2!)
            XCTAssertNotNil(remoteData2)
            
            XCTAssertEqual(remoteData1!.dailyUsedData, 21.0)
            
            XCTAssertEqual(remoteData2!.dailyUsedData, 22.0)
        }
    }

}
