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
        repository = MockNetworkDataRepository()
    }

    override func tearDownWithError() throws {
        repository = nil
    }
    
    // MARK: - Total Used Data
    func test_get_total_used_data() throws {
        // (1) Given
        // (2) When
        let output = repository.getTotalUsedData()
        repository.usedDataInfo = output
        
        // (3) Then
        let expected = UsedDataInfo(
            wirelessWanDataReceived: 10_000_000,
            wirelessWanDataSent: 485_760
        )
        let totalUsedDataOutput = repository.totalUsedData
        XCTAssertEqual(output, expected)
        XCTAssertEqual(totalUsedDataOutput, 10.0)
    }
}
