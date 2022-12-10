//
//  Network_Data_Repository_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 23/10/22.
//

import XCTest
@testable import Data_Pill

final class Network_Data_Repository_Test_Case: XCTestCase {

    var repository: NetworkDataRepositoryProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        repository = MockNetworkDataRepository()
    }

    override func tearDownWithError() throws {
        repository = nil
    }
    
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
