//
//  ToggleItem.swift
//  Data Pill
//
//  Created by Wind Versi on 27/11/22.
//

import Foundation

enum ToggleItem: String {
    case plan = "Plan"
    case daily = "Daily"
    
    var url: URL {
        .init(string: "datapill:///\(self.rawValue.lowercased())")!
    }
}

enum SlideToggleItem {
    case plan
    case nonPlan
}
