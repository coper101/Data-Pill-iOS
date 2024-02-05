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
        
    private let supportedFamilies: [WidgetFamily] = {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .accessoryRectangular]
        } else {
            return [.systemSmall]
        }
    }()
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: WidgetKind.main.name,
            intent: UsageTypeIntent.self,
            provider: Provider(widgetModel: .init())
        ) { entry in
            WidgetPillView(
                usedData: entry.usedData,
                maxData: entry.maxData,
                dataUnit: entry.dataUnit,
                localizedSubtitle: entry.localizedSubtitle,
                subtitle: entry.subtitle,
                color: entry.color
            )
            .widgetURL(entry.usageType.url)
        }
        .configurationDisplayName("Data Pill")
        .description("Monitor data usage.")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabledIfAvailable()
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        
        if #available(iOS 17.0, *) {
            
            EmptyView()
            
        } else {
            
            WidgetPillView(
                usedData: 0.5,
                maxData: 1,
                dataUnit: .gb,
                localizedSubtitle: "TODAY",
                subtitle: "TODAY",
                color: Colors.secondaryBlue.color
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("iOS 16 Below / System / Small")
        }
        
        
        if #available(iOS 16.0, *) {
            WidgetPillView(
                usedData: 0.5,
                maxData: 1,
                dataUnit: .gb,
                localizedSubtitle: "USED",
                subtitle: "USED",
                color: Colors.secondaryBlue.color
            )
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Accessory / Rectangular")
        }
    }
}

@available(iOS 17.0, *)
#Preview("System / Small", as: .systemSmall) {
    Data_Pill_Widget()
} timeline: {
    SimpleEntry(
       date: .init(),
       usedData: 0.5,
       maxData: 1,
       dataUnit: .gb,
       localizedSubtitle: "USED",
       subtitle: "USED",
       color: Colors.secondaryBlue.color,
       usageType: .daily
    )
}
