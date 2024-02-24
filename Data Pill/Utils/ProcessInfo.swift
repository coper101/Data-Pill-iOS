//
//  ProcessInfo.swift
//  Data Pill
//
//  Created by Wind Versi on 27/6/23.
//

import Foundation

extension ProcessInfo {
    
    static var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1"
    }
    
    static var isUITesting: Bool {
        processInfo.arguments.contains("UI_TESTING")
    }
    
    static var isMockedMobileData: Bool {
        guard let subscriberValue = processInfo.environment["MOCKED_MOBILE_DATA"] else {
            return false
        }
        return subscriberValue == "1"
    }
    
    static var isMockedCloud: Bool {
        guard let subscriberValue = processInfo.environment["MOCKED_CLOUD"] else {
            return false
        }
        return subscriberValue == "1"
    }
}
