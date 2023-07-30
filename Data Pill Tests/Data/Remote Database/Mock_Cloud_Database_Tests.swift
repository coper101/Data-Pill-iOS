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
    
    private var cloudData: CloudData!
    private var cloudDatabase: RemoteDatabase!

    override func setUpWithError() throws {
        continueAfterFailure = false
        cloudData = .init()
    }

    override func tearDownWithError() throws {
        cloudData = nil
        cloudDatabase = nil
    }

    // MARK: - Status
    func test_has_access_to_cloud_database() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)
        
        createExpectation(
            publisher: cloudDatabase.isAvailable(),
            description: "Is Available"
        ) { isAvailable in
            XCTAssertTrue(isAvailable)
        }
    }
    
    func test_has_no_access_to_cloud_database() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: false, data: cloudData)
        
        createExpectation(
            publisher: cloudDatabase.isAvailable(),
            description: "Is Available"
        ) { isAvailable in
            XCTAssertFalse(isAvailable)
        }
    }
    
    // MARK: - Fetch
    func test_fetch_all_plan_is_empty() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .plan, recursively: true),
            description: "Fetch All Plan"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
    }
    
    func test_fetch_all_data_is_empty() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Data"
        ) { records in
            XCTAssertTrue(records.isEmpty)
        }
    }
    
    func test_fetch_all_data_has_no_access_to_cloud_database() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: false, data: cloudData)

        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .data, recursively: true),
            description: "Fetch All Data",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, .fetchError("No Access To Cloud"))
            }
        ) { _ in }
    }
        
    // MARK: - Save Plan Record
    func test_save_new_plan_record() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

        let record = TestData.createPlanRecord(
            startDate: todaysDate,
            endDate: todaysDate,
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
    
    func test_save_new_plan_record_has_no_access_to_cloud_database() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        cloudDatabase = MockCloudDatabase(hasAccess: false, data: cloudData)

        let record = TestData.createPlanRecord(
            startDate: todaysDate,
            endDate: todaysDate,
            dataAmount: 10,
            dailyLimit: 10,
            planLimit: 10
        )
        
        /// save
        createExpectation(
            publisher: cloudDatabase.save(record: record),
            description: "Save New Plan Record",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, .saveError("No Access To Cloud"))
            }
        ) { _ in }
        
        /// check if not saved
        let records = cloudData.planRecords as! [CKRecord]
        XCTAssertTrue(records.isEmpty)
    }
    
    func test_save_existing_plan_record() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

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
    
    func test_save_existing_plan_record_has_no_access_to_cloud_database() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())

        /// save new plan
        try test_save_new_plan_record()
        
        cloudDatabase = MockCloudDatabase(hasAccess: false, data: cloudData)
        
        /// get existing plan
        createExpectation(
            publisher: cloudDatabase.fetchAll(of: .plan, recursively: false),
            description: "Fetch Existing Plan",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, .fetchError("No Access To Cloud"))
            }
        ) { _ in }
        
        /// save existing plan
        var planRecord = TestData.createPlanRecord(
            startDate: todaysDate,
            endDate: todaysDate,
            dataAmount: 10,
            dailyLimit: 0.5,
            planLimit: 9
        )
        createExpectation(
            publisher: cloudDatabase.save(record: planRecord),
            description: "Save Existing Plan Record",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, .saveError("No Access To Cloud"))
            }
        ) { _ in }
        
        /// check same value
        let records = cloudData.planRecords as! [CKRecord]
        XCTAssertEqual(records.count, 1)
        
        planRecord = try XCTUnwrap(records.first)
        let remotePlan = try XCTUnwrap(RemotePlan.toRemotePlan(planRecord))
        
        XCTAssertEqual(remotePlan.dataAmount, 10.0)
        XCTAssertEqual(remotePlan.dailyLimit, 10.0)
        XCTAssertEqual(remotePlan.planLimit, 10.0)
    }
    
    // MARK: - Save Data Record
    func test_save_new_data_record() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

        let record = TestData.createDataRecord(date: todaysDate, dailyUsedData: 10)
        
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
    
    func test_save_new_data_record_has_no_access_to_cloud_database() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        cloudDatabase = MockCloudDatabase(hasAccess: false, data: cloudData)

        let record = TestData.createDataRecord(date: todaysDate, dailyUsedData: 10)
        
        /// save
        createExpectation(
            publisher: cloudDatabase.save(record: record),
            description: "Save New Data Record",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, .saveError("No Access To Cloud"))
            }
        ) { _ in }
        
        /// check if not saved
        let records = cloudData.dataRecords as! [CKRecord]
        XCTAssertTrue(records.isEmpty)
    }
    
    func test_save_new_data_records() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

        let records = [
            TestData.createDataRecord(
                date: TestData.createDate(offset: -1, from: todaysDate),
                dailyUsedData: 10
            ),
            TestData.createDataRecord(
                date: TestData.createDate(offset: -2, from: todaysDate),
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
    
    func test_save_new_data_records_has_no_access_to_cloud_database() throws {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        cloudDatabase = MockCloudDatabase(hasAccess: false, data: cloudData)

        let records = [
            TestData.createDataRecord(
                date: TestData.createDate(offset: -1, from: todaysDate),
                dailyUsedData: 10
            ),
            TestData.createDataRecord(
                date: TestData.createDate(offset: -2, from: todaysDate),
                dailyUsedData: 10
            )
        ]
        
        /// save
        createExpectation(
            publisher: cloudDatabase.save(records: records),
            description: "Save New Data Records",
            onFailure: { error in
                XCTAssertEqual(error as! RemoteDatabaseError, .saveError("No Access To Cloud"))
            }
        ) { _ in }
        
        /// check if not saved
        let dataRecords = cloudData.dataRecords as! [CKRecord]
        XCTAssertTrue(dataRecords.isEmpty)
    }
    
    func test_save_existing_data_record() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

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
        let records = cloudData.dataRecords as! [CKRecord]
        XCTAssertEqual(records.count, 1)
        
        dataRecord = records.first
        XCTAssertNotNil(dataRecord)
        
        let remoteData = RemoteData.toRemoteData(dataRecord!)
        XCTAssertNotNil(remoteData)
        
        XCTAssertEqual(remoteData!.dailyUsedData, 20.0)
    }
    
    func test_save_existing_data_records() throws {
        cloudDatabase = MockCloudDatabase(hasAccess: true, data: cloudData)

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
