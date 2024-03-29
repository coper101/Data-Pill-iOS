//
//  SmallWidgetView.swift
//  Data Pill
//
//  Created by Wind Versi on 11/12/22.
//

import SwiftUI

enum SmallWidgetSize: Int, Identifiable, CaseIterable {
    case xxs = 141
    case xs = 148
    case s = 151
    case m = 155
    case r = 158
    case l = 159
    case xl = 169
    case xxl = 170
    var id: String {
        "\(self.rawValue)"
    }
}

struct SmallWidgetView: View {
    // MARK: - Props
    var fillUsageType: FillUsage
    var usedData: Double
    var maxData: Double
    var dataUnit: Unit
    var localizedSubtitle: LocalizedStringKey
    var subtitle: String
    var color: Color
    
    var percentageUsed: Int {
        usedData.displayedUsageInPercentage(
            maxData: maxData,
            fillUsageType: fillUsageType
        )
    }
    
    var dataUsed: String {
        usedData.displayedUsage(
            maxData: maxData,
            fillUsageType: fillUsageType,
            dataUnit: dataUnit
        )
    }
    
    // MARK: - UI
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            let width = reader.size.width
            
            HStack(
                alignment: .center,
                spacing: 0
            ) {
                
                // MARK: - Col 1: PILL
                BasePillView(
                    percentage: percentageUsed,
                    isContentShown: true,
                    hasBackground: true,
                    color: color,
                    widthScale: 0,
                    customSize: .init(
                        width: pillWidth(width),
                        height: height * 0.9
                    ),
                    label: {},
                    faintLabel: {}
                )
                
                Spacer()
                
                // MARK: - Col 2: INFO
                VStack(
                    alignment: .trailing,
                    spacing: 0
                ) {
                    
                    // Row 1: DATA USED IN PERCENTAGE
                    HStack(
                        alignment: .bottom,
                        spacing: 0.5
                    ) {
                        
                        Text(verbatim: "\(percentageUsed)")
                            .textStyle(
                                foregroundColor: .onSurface,
                                font: .semibold,
                                size: 23,
                                lineLimit: 1
                            )
                        
                        Text(verbatim: "%")
                            .textStyle(
                                foregroundColor: .onSurface,
                                font: .semibold,
                                size: 21,
                                lineLimit: 1
                            )
                         
                    } //: HStack
                    .padding(.top, 7)
                                    
                    // Row 2: DATA USED
                    Text(verbatim: dataUsed)
                        .multilineTextAlignment(.trailing)
                        .textStyle(
                            foregroundColor: .onSurface,
                            font: .semibold,
                            size: 12,
                            lineLimit: 2
                        )
                        .opacity(0.5)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Row 2: SUBTITLE
                    Text(localizedSubtitle)
                        .kerning(2.0)
                        .textStyle(
                            foregroundColor: Colors.onSurfaceLight2,
                            font: .bold,
                            size: (subtitle.count <= 3) ? 16 : 13
                        )
                        .padding(.bottom, 4)
                    
                } //: VStack
                 
            } //: HStack
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .fillMaxSize()
            
        } //: GeometryReader
    }
    
    // MARK: - Functions
    func pillWidth(_ width: CGFloat) -> CGFloat {
        let widgetSize = SmallWidgetSize(rawValue: Int(width))
        switch widgetSize {
        case .xxs:
            return 51
        case .xs, .s:
            return 54
        case .m, .r, .l:
            return 58
        default:
            return 64
        }
    }
    
    func showUnit(_ width: CGFloat) -> Bool {
        let widgetSize = SmallWidgetSize(rawValue: Int(width))
        switch widgetSize {
        case .s, .xs, .xxs:
            return false
        default:
            return true
        }
    }
    
}

// MARK: - Preview
struct SmallWidgetView_Previews: PreviewProvider {
    static let usedData = 1.123456 /// 1,123 MB (whole number only), 1.12 GB (2 dp max)
    static let maxData = 5.123456 /// 5,123 MB  (whole number only), 5.12 (2dp max)
    
    static var previews: some View {
        ForEach(SmallWidgetSize.allCases) { size in
            let theSize = CGFloat(size.rawValue)
            SmallWidgetView(
                fillUsageType: .accumulate,
                usedData: usedData,
                maxData: maxData,
                dataUnit: .gb,
                localizedSubtitle: "Today",
                subtitle: "Today",
                color: Colors.secondaryBlue.color
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("\(size.rawValue)")
            .frame(width: theSize, height: theSize)
        }
    }
}
