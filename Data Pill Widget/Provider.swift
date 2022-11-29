//
//  Provider.swift
//  Data Pill
//
//  Created by Wind Versi on 28/11/22.
//

import WidgetKit
import CoreData

struct Provider: IntentTimelineProvider {
    
    typealias Entry = SimpleEntry
    typealias Intent = UsageTypeIntent
    var widgetViewModel: WidgetViewModel
    
    /// Show placeholder data before transitioning to show the actual data
    func placeholder(in context: Context) -> Entry {
        print("placholder")
        return .init(
            date: Date(),
            usedData: 0,
            maxData: 0,
            dataUnit: .gb,
            subtitle: "Day",
            color: .surface,
            usageType: .daily
        )
    }

    /// Show widget snapshot or preview before adding it to home screen
    func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        print("getSnapshot")
        let entry = getNewEntry(for: configuration, date: Date())
        completion(entry)
    }
    
    /// Set the time when the data of widget will be updated
    func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let currentDate = Date()
        var entries = [SimpleEntry]()
        let entry = getNewEntry(for: configuration, date: currentDate)
        entries.append(entry)
        
        let nextRefreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextRefreshDate))
        print("timeline: ", timeline)
        
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
    
    func getNewEntry(for configuration: Intent, date: Date) -> SimpleEntry {
        let usageType = usageType(for: configuration)
        let todaysDate = widgetViewModel.todaysData.date ?? .init()
        var color: Colors {
            let weekday = todaysDate.toDateComp().weekday ?? 1
            return widgetViewModel.days[weekday - 1].color
        }
        let subtitle = (usageType == .plan) ? "Plan" : todaysDate.toWeekdayFormat()
        return .init(
            date: date,
            usedData: widgetViewModel.usedData(for: usageType),
            maxData: widgetViewModel.maxData(for: usageType),
            dataUnit: widgetViewModel.unit,
            subtitle: subtitle,
            color: color,
            usageType: usageType
        )
    }
}
