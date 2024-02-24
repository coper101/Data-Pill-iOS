//
//  RemoteIdentifiers.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation

// MARK: - Types
protocol CK {
    func toDictionary() -> [String: Any]
}

enum RecordType: String {
    case plan = "Plan"
    case data = "Data"
    var type: String {
        self.rawValue
    }
}


// MARK: - Identifiers
enum CloudContainer: String {
    case dataPill = "iCloud.com.penguinworks.Data-Pill"
    var identifier: String {
        self.rawValue
    }
}

