//
//  Provider.swift
//  Data Pill
//
//  Created by Wind Versi on 28/11/22.
//

import WidgetKit
import CoreData

struct Provider: IntentTimelineProvider {
    
    let widgetModel: WidgetModel
    typealias Entry = SimpleEntry
    typealias Intent = UsageTypeIntent
    
    /// Show placeholder data before transitioning to show the actual data
    func placeholder(in context: Context) -> Entry {
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
        let entry = getNewEntry(for: configuration, date: currentDate)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
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
        
        widgetModel.setUsageType(usageType)
        widgetModel.getLatestData()
        
        let todaysDate = widgetModel.todaysData.date ?? .init()
        var color: Colors {
            let weekday = todaysDate.toDateComp().weekday ?? 1
            return widgetModel.days[weekday - 1].color
        }
        let subtitle = (usageType == .plan) ? "Plan" : todaysDate.toWeekdayFormat()
        
        let newEntry = Entry(
            date: date,
            usedData: widgetModel.usedData,
            maxData: widgetModel.maxData,
            dataUnit: widgetModel.unit,
            subtitle: subtitle,
            color: color,
            usageType: usageType
        )
        
        return newEntry
    }
}
