//
//  App_View_Model_Refresh_Data_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 17/3/23.
//

import XCTest
@testable import Data_Pill

final class App_View_Model_Refresh_Data_Tests: XCTestCase {

    /**
        When View of app is not shown, the Today's Data will not be created
            - ensure today's data is created every test case
    */
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // MARK: - Mobile Data
    func test_refresh_used_data_today_with_empty_total_used_data() throws {
        // (1) Given
        let newTotalUsedData = 0.0
        let existingTotalUsedData = 100.0
        
        // (2) When
        let appViewModel = createAppViewModel(withTotalUsedData: existingTotalUsedData)
        appViewModel.republishDataUsage()

        let expectation = expectation(description: "Get Updated Today's Data")
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
                XCTAssertEqual(dailyUsedDataToday, 0)
                XCTAssertEqual(totalUsedDataToday, 100)
                
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation, expectation2], timeout: 1.5)
    }
    
    func test_refresh_used_data_today_with_has_total_used_data() throws {
        // (1) Given
        let newTotalUsedData = 400.0
        let existingTotalUsedData = 100.0
        
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
                XCTAssertEqual(dailyUsedDataToday, 300)
                XCTAssertEqual(totalUsedDataToday, 400)
                
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation, expectation2], timeout: 1.5)
    }
    
    func test_refresh_used_data_today_with_has_total_used_data_same() throws {
        // (1) Given
        let newTotalUsedData = 100.0
        let existingTotalUsedData = 100.0
        
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
                XCTAssertEqual(dailyUsedDataToday, 0)
                XCTAssertEqual(totalUsedDataToday, 100)
                
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation, expectation2], timeout: 1.5)
    }
    

}
