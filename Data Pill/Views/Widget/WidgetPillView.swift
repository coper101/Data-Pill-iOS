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
    @Environment(\.colorScheme) var colorScheme
    var fillUsageType: FillUsage
    var usedData: Double
    var maxData: Double
    var dataUnit: Unit
    var localizedSubtitle: LocalizedStringKey
    var subtitle: String
    var color: Color
    
    // MARK: - UI
    var smallWidget: some View {
        SmallWidgetView(
            fillUsageType: fillUsageType,
            usedData: usedData,
            maxData: maxData,
            dataUnit: dataUnit,
            localizedSubtitle: localizedSubtitle,
            subtitle: subtitle,
            color: color
        )
    }
    
    var rectangularWidget: some View {
        RectangularWidgetView(
            fillUsageType: fillUsageType,
            usedData: usedData,
            maxData: maxData,
            dataUnit: dataUnit,
            subtitle: subtitle,
            color: color
        )
    }
    
    var body: some View {
        Group {
            switch widgetFamily {
            case .accessoryRectangular:
                
                /// For Lock Screen Widget
                if #available(iOS 17.0, *) {
                    
                    rectangularWidget
                        .containerBackground(for: .widget) {
                            Color.clear
                        }
                    
                } else {
                    
                    rectangularWidget
                    
                } //: if-else
                
            default:
               
                /// For Home Screen Widget - Has Background Color
                if #available(iOS 17.0, *) {
                    
                    smallWidget
                        .containerBackground(for: .widget) {
                            colorScheme == .dark ? Color.black : Color.white
                        }
                    
                } else {
                    
                    smallWidget
                    
                } //: if-else
            }
        }
    }

}
