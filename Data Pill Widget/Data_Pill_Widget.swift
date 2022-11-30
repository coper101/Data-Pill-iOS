//
//  Data_Pill_Widget.swift
//  Data Pill Widget
//
//  Created by Wind Versi on 27/11/22.
//

import WidgetKit
import SwiftUI

@main
struct Data_Pill_Widget: Widget {
    let kind: String = "Data_Pill_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: UsageTypeIntent.self,
            provider: Provider()
        ) { entry in
            WidgetPillView(
                usedData: entry.usedData,
                maxData: entry.maxData,
                dataUnit: entry.dataUnit,
                subtitle: entry.subtitle,
                color: entry.color
            )
            .widgetURL(entry.usageType.url)
        }
        .configurationDisplayName("Data Pill")
        .description("Monitor data usage.")
        .supportedFamilies([.systemSmall])
    }
}
