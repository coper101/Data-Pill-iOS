//
//  App_View_Model_Refresh_Data_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 17/3/23.
//

import XCTest
@testable import Data_Pill

final class App_View_Model_Refresh_Data_Tests: XCTestCase {

    /// When View of app is not shown, the Today's Data will not be created
    /// - ensure today's data is created every test case
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    // MARK: - Refresh Used Mobile Data
    func test_refresh_used_data_today_with_empty_total_used_data() throws {
        // (1) Given
        let newTotalUsedData = 0.0
        let existingTotalUsedData = 100.0
        
        // (2) When
        // (3) Then
        refreshDataUsedToday(
            existingTotalUsedData: existingTotalUsedData,
            newTotalUsedData: newTotalUsedData,
            dailyUsedData: 0,
            totalUsedDataToday: 100
        )
    }
    
    func test_refresh_used_data_today_with_has_total_used_data() throws {
        // (1) Given
        let newTotalUsedData = 400.0
        let existingTotalUsedData = 100.0
        
        // (2) When
        // (3) Then
        refreshDataUsedToday(
            existingTotalUsedData: existingTotalUsedData,
            newTotalUsedData: newTotalUsedData,
            dailyUsedData: 300,
            totalUsedDataToday: 400
        )
    }
    
    func test_refresh_used_data_today_with_has_total_used_data_same() throws {
        // (1) Given
        let newTotalUsedData = 100.0
        let existingTotalUsedData = 100.0
        
        // (2) When
        // (3) Then
        refreshDataUsedToday(
            existingTotalUsedData: existingTotalUsedData,
            newTotalUsedData: newTotalUsedData,
            dailyUsedData: 0,
            totalUsedDataToday: 100
        )
    }
}

extension XCTestCase {
    
    func refreshDataUsedToday(
        existingTotalUsedData: Double,
        newTotalUsedData: Double,
        dailyUsedData: Double,
        totalUsedDataToday: Double
    ) {
        // (2) When
        let appViewModel = createAppViewModel(withTotalUsedData: existingTotalUsedData)
        appViewModel.republishDataUsage()

        let expectation = self.expectation(description: "Get Updated Today's Data")
        let expectation2 = self.expectation(description: "Get Updated Today's Data After Refresh")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            appViewModel.refreshUsedDataToday(newTotalUsedData)
            
            expectation.fulfill()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                // (3) Then
                let dateToday = appViewModel.todaysData.date
                let dailyUsedDataToday = appViewModel.todaysData.dailyUsedData
                let totalUsedDataToday = appViewModel.todaysData.totalUsedData
                
                XCTAssertNotNil(dateToday)
                XCTAssertTrue(dateToday!.isToday())
                XCTAssertEqual(dailyUsedDataToday, dailyUsedData)
                XCTAssertEqual(totalUsedDataToday, totalUsedDataToday)
                 
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation, expectation2], timeout: 1.5)
    }
}
