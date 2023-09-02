//
//  Mock_Network_Data_Repository_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 23/10/22.
//

@testable import Data_Pill
import XCTest

final class Mock_Network_Data_Repository_Tests: XCTestCase {

    private var repository: NetworkDataRepositoryProtocol!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        repository = nil
    }
    
    // MARK: - Total Used Data
    func test_get_total_used_data() throws {
        // (1) Given
        repository = MockNetworkDataRepository(automaticUpdates: false)

        // (2) When
        /// The total used data `DataInfo` is received once and it is coverted to MB format
        
        // (3) Then
        let totalUsedDataOutput = repository.totalUsedData
        XCTAssertEqual(totalUsedDataOutput, 10.0, accuracy: 1) /// In MB (Megabytes)
    }
    
    func test_get_total_used_data_overtime() throws {
        // (1) Given
        repository = MockNetworkDataRepository(automaticUpdates: true)

        // (2) When
        /// The total used data `DataInfo` is received every 2 seconds and it is coverted to MB format
        
        // (3) Then
        let totalUsedDataOutput = repository.totalUsedData
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(totalUsedDataOutput, 20.0, accuracy: 2) /// In MB (Megabytes)
        }
    }
}
