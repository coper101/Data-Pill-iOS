//
//  Data_Pill_Widget.swift
//  Data Pill Widget
//
//  Created by Wind Versi on 27/11/22.
//

import WidgetKit
import SwiftUI

// MARK: - Provider
// Source of Truth
// Configure when to update the Widget
struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = UsageTypeIntent
    
    func placeholder(in context: Context) -> Entry {
        .init(
            date: Date(),
            usageType: .daily,
            usedData: 0.1,
            maxData: 1.0,
            dataUnit: .gb,
            day: "Mon",
            color: .secondaryBlue
        )
    }

    func getSnapshot(
        for: Intent,
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        let entry = SimpleEntry(
            date: Date(),
            usageType: .daily,
            usedData: 0.1,
            maxData: 1.0,
            dataUnit: .gb,
            day: "Mon",
            color: .secondaryBlue
        )
        completion(entry)
    }
    
    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        var entries: [Entry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let usageType = usageType(for: configuration)
        let day = (usageType == .plan) ? "Plan" : "Mon"
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                usageType: usageType,
                usedData: 0.1,
                maxData: 1.0,
                dataUnit: .gb,
                day: day,
                color: .secondaryBlue
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func usageType(for configuration: Intent) -> ToggleItem {
        switch configuration.usageType {
        case .daily:
            return .daily
        case .plan:
            return .plan
        case .unknown:
            return .daily
        }
    }
}


// MARK: - Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let usageType: ToggleItem
    let usedData: Double
    let maxData: Double
    let dataUnit: Unit
    let day: String
    let color: Colors
}

struct Data_Pill_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetPillView(
            usedData: entry.usedData,
            maxData: entry.maxData,
            dataUnit: entry.dataUnit,
            subtitle: entry.day,
            color: entry.color
        )
        .widgetURL(entry.usageType.url)
    }
}


// MARK: - Widget
@main
struct Data_Pill_Widget: Widget {
    let kind: String = "Data_Pill_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: UsageTypeIntent.self,
            provider: Provider()
        ) { entry in
            Data_Pill_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Data Pill")
        .description("Monitor data usage.")
        .supportedFamilies([.systemSmall])
    }
}


// MARK: - Preview
struct Data_Pill_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Data_Pill_WidgetEntryView(
            entry: .init(
                date: Date(),
                usageType: .daily,
                usedData: 0.1,
                maxData: 1.0,
                dataUnit: .gb,
                day: "Mon",
                color: .secondaryBlue
            )
        )
        .previewContext(
            WidgetPreviewContext(family: .systemSmall)
        )
    }
}
