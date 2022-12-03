//
//  Entry.swift
//  Data Pill WidgetExtension
//
//  Created by Wind Versi on 28/11/22.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let usedData: Double
    let maxData: Double
    let dataUnit: Unit
    let subtitle: String
    let color: Colors
    let usageType: ToggleItem
}
