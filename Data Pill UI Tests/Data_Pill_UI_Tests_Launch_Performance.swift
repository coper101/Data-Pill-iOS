//
//  Data_Pill_UI_Tests_Launch_Performance.swift
//  Data Pill UI Tests
//
//  Created by Wind Versi on 25/12/22.
//

import XCTest

final class Data_Pill_UI_Tests_Launch_Performance: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    // ideal launch time: < 2 seconds
    func test_launch_performance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

}
