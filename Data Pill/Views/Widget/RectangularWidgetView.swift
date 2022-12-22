//
//  RectangularWidgetView.swift
//  Data Pill
//
//  Created by Wind Versi on 11/12/22.
//

import SwiftUI
import WidgetKit

enum RectangularWidgetSize: String, Identifiable, CaseIterable {
    case s
    case m
    case l
    case xl
    case xxl
    var id: String {
        "\(self.rawValue)"
    }
    var size: CGSize {
        switch self {
        case .s:
            return .init(width: 153, height: 68)
        case .m:
            return .init(width: 157, height: 72)
        case .l:
            return .init(width: 160, height: 72)
        case .xl:
            return .init(width: 170, height: 76)
        case .xxl:
            return .init(width: 172, height: 76)
        }
    }
}

struct RectangularWidgetView: View {
    // MARK: - Props
    var usedData: Double
    var maxData: Double
    var dataUnit: Unit
    var subtitle: String
    var color: Colors
    
    var percentageUsed: Int {
        usedData.toPercentage(with: maxData)
    }
    
    var data: String {
        let usedDataDp = usedData.toDp(n: 2)
        let maxDataDp = maxData.toDp(n: 2)
        if usedDataDp.count > 3 || maxDataDp.count > 3 {
            return usedDataDp
        }
        return  "\(usedDataDp) / \(maxDataDp)"
    }
    
    // MARK: - UI
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            let width = reader.size.width
            
            HStack(spacing: spaceBetween(width)) {
                
                // MARK: - Row 1: PILL
                ZStack(alignment: .center) {
                    
                    // Layer 1: Pill
                    BasePillView(
                        percentage: percentageUsed,
                        isContentShown: true,
                        orientation: .horizontal,
                        hasBackground: true,
                        backgroundColor: .onBackground,
                        backgroundOpacity: 0.5,
                        color: .onBackground,
                        widthScale: 0,
                        customSize: .init(
                            width: width * 0.6,
                            height: height * 0.7
                        ),
                        label: {}
                    )
                    
                    // Layer 2: Percentage
                    Text("\(percentageUsed)")
                        .textStyle(
                            foregroundColor: .background,
                            font: .bold,
                            size: 24,
                            lineLimit: 1
                        )
                    
                } //: ZStack
                                
                // MARK: - Row 2:
                VStack(
                    alignment: .trailing,
                    spacing: 8
                ) {
                    
                    // Row 1: DATA USED
                    Text("\(data)")
                        .textStyle(
                            foregroundColor: .onBackground,
                            font: .bold,
                            size: 12,
                            lineLimit: 1
                        )
                    
                    // Row 2: SUBTITLE
                    Text(subtitle(width))
                        .kerning(1.0)
                        .textStyle(
                            foregroundColor: .onBackground,
                            font: .bold,
                            size: 12
                        )
                        .alignmentGuide(.trailing) { $0.width - 2 }
                    
                } //: HStack
                                
            } //: VStack
            .fillMaxSize(alignment: .center)
            
        } //: GeometryReader
    }
    
    // MARK: - Functions
    func spaceBetween(_ width: CGFloat) -> CGFloat {
        if width == RectangularWidgetSize.s.size.width {
            return 6
        } else if width == RectangularWidgetSize.m.size.width {
            return 7
        } else if width == RectangularWidgetSize.l.size.width {
            return 9
        } else if width == RectangularWidgetSize.xl.size.width {
            return 10
        } else {
            return 10
        }
    }
    
    func subtitle(_ width: CGFloat) -> String {
        if width <= RectangularWidgetSize.l.size.width {
            return "USED"
        } else {
            return "TODAY"
        }
    }
}

// MARK: - Preview
struct RectangularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(RectangularWidgetSize.allCases) { widgetSize in
            let size = widgetSize.size
            if #available(iOS 16.0, *) {
                RectangularWidgetView(
                    usedData: 0.5,
                    maxData: 0.9,
                    dataUnit: .gb,
                    subtitle: "Mon",
                    color: .secondaryBlue
                )
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Rectangular / \(size.width)x\(size.height)")
                .frame(width: size.width, height: size.height)
                .background(Color.gray)
            } else {
                // Fallback on earlier versions
                EmptyView()
            }
        }
    }
}
