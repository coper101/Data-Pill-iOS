//
//  Toast_Timer_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 19/1/23.
//

import XCTest
@testable import Data_Pill

final class Toast_Timer_Tests: XCTestCase {
    
    private var toastTimer: ToastTimer<String>!

    override func setUpWithError() throws {
        toastTimer = .init()
    }

    override func tearDownWithError() throws {
        toastTimer = nil
    }

    func test_show_toast() throws {
        // (1) Given
        let message = "Exceeds Maximum Data Amount"
        
        // (2) When
        toastTimer.showToast(message: message)
        
        // (3) Then
        XCTAssertNotNil(self.toastTimer.timer)
        XCTAssertEqual(toastTimer.message, message)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertNil(self.toastTimer.message)
            XCTAssertNil(self.toastTimer.timer)
        }
    }

}
