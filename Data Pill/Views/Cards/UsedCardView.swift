//
//  UsedCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct UsedCardView: View {
    // MARK: - Props
    var usedData: Double
    var maxData: Double
    var fillUsageType: FillUsage
    var dataUnit: Unit
    var width: CGFloat
    
    var percentageUsed: String {
        let percentage = usedData.displayedUsageInPercentage(
            maxData: maxData,
            fillUsageType: fillUsageType
        )
        return "\(percentage)"
    }
    
    var dataUsed: String {
        usedData.displayedUsage(
            maxData: maxData,
            fillUsageType: fillUsageType,
            dataUnit: dataUnit
        )
    }
    
    var subtitle: LocalizedStringKey {
        switch fillUsageType {
        case .accumulate:
            return "USED"
        case .deduct:
            return "LEFT"
        }
    }
        
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: subtitle,
            verticalSpacing: 5,
            isToggleOn: .constant(false),
            width: width
        ) {
            
            // Row 1: PERCENTAGE USED
            HStack(
                alignment: .firstTextBaseline,
                spacing: 0
            ) {
                
                Text(verbatim: percentageUsed)
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 32,
                        lineLimit: 1
                    )
                    .id(percentageUsed)
                    .accessibilityLabel(AccessibilityLabels.percentageUsedNumber.rawValue)
                
                Text(verbatim: "%")
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 28,
                        lineLimit: 1
                    )
                    .accessibilityLabel(AccessibilityLabels.percentageUsedSign.rawValue)
            } //: HStack
            
            // Row 2: DATA
            Text(verbatim: dataUsed)
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 14,
                    lineLimit: 2
                )
                .opacity(0.5)
                .padding(.bottom, 10)
                .id(dataUsed)
                .accessibilityLabel(AccessibilityLabels.dataUsedAmount.rawValue)
            
        } //: ItemCardView
        .accessibilityIdentifier("used")
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsedCardView_Previews: PreviewProvider {
    static var dataUnit: Unit = .mb
    
    static let usedData = 1.123456 /// 1,123 MB (whole number only), 1.12 GB (2 dp max)
    static let maxData = 5.123456 /// 5,123 MB  (whole number only), 5.12 (2dp max)
    
    static var previews: some View {
        Group {
            UsedCardView(
                usedData: usedData,
                maxData: maxData,
                fillUsageType: .accumulate,
                dataUnit: dataUnit,
                width: 100
            )
            .previewDisplayName("Accumulate")
            
            UsedCardView(
                usedData: usedData,
                maxData: maxData,
                fillUsageType: .deduct,
                dataUnit: dataUnit,
                width: 100
            )
            .previewDisplayName("Deduct")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
