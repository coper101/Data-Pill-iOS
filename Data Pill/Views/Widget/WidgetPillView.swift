//
//  WidgetPillView.swift
//  Data Pill
//
//  Created by Wind Versi on 27/11/22.
//

import SwiftUI
import WidgetKit

struct WidgetPillView: View {
    // MARK: - Props
    @Environment(\.widgetFamily) var widgetFamily
    var usedData: Double
    var maxData: Double
    var dataUnit: Unit
    var subtitle: String
    var color: Colors
    
    // MARK: - UI
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            RectangularWidgetView(
                usedData: usedData,
                maxData: maxData,
                dataUnit: dataUnit,
                subtitle: subtitle,
                color: color
            )
        default:
            SmallWidgetView(
                usedData: usedData,
                maxData: maxData,
                dataUnit: dataUnit,
                subtitle: subtitle,
                color: color
            )
        }
    }

}
