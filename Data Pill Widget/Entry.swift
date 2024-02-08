//
//  Entry.swift
//  Data Pill WidgetExtension
//
//  Created by Wind Versi on 28/11/22.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let usedData: Double
    let maxData: Double
    let dataUnit: Unit
    let localizedSubtitle: LocalizedStringKey
    let subtitle: String
    let color: Color
    let usageType: ToggleItem
    let fillUsageType: FillUsage
}
