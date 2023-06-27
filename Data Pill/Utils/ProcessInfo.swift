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
}
