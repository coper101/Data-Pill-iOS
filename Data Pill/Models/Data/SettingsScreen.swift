//
//  SettingsScreen.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import Foundation

enum SettingsScreen: String, CaseIterable {
    case customizePill = "Customize Pill"
    case notifications = "Notifications"
    case showAllRecords = "All Records"
    case reportABug = "Report a Bug"
    case requestAFeature = "Request a Feature"
}

extension SettingsScreen: Identifiable {
    
    var id: String {
        self.rawValue
    }
    
    var title: String {
        self.rawValue
    }
}
