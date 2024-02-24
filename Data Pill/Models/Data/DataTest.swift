//
//  DataTest.swift
//  Data Pill
//
//  Created by Wind Versi on 9/10/22.
//

import Foundation

/// For Initializing Data Entity without using Core Data
/// These properties will be set to attributes of Data Entity Object
struct DataTest {
    var date = Date()
    var totalUsedData = 0.0
    var dailyUsedData = 0.0
    var hasLastTotal = false
    var isSyncedToRemote = false
    var lastSyncedDateToRemote: Date? = nil
}
