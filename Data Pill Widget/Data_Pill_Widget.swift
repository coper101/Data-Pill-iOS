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
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetPillView(
            usedData: 0.5,
            maxData: 1,
            dataUnit: .gb,
            localizedSubtitle: "TODAY",
            subtitle: "TODAY",
            color: .secondaryBlue
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("System Small")
        
        if #available(iOSApplicationExtension 16.0, *) {
            WidgetPillView(
                usedData: 0.5,
                maxData: 1,
                dataUnit: .gb,
                localizedSubtitle: "USED",
                subtitle: "USED",
                color: .secondaryBlue
            )
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Accessory Rectangular")
        }
    }
}
