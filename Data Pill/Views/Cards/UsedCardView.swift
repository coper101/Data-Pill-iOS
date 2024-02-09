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
                    lineLimit: 1
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
    static var appViewModel: AppViewModel = TestData.createAppViewModel()
    
    static var previews: some View {
        Group {
            UsedCardView(
                usedData: 0.13,
                maxData: 0.3,
                fillUsageType: .accumulate,
                dataUnit: appViewModel.unit,
                width: 150
            )
            .previewDisplayName("Accumulate")
            
            UsedCardView(
                usedData: 0.13,
                maxData: 0.3,
                fillUsageType: .deduct,
                dataUnit: appViewModel.unit,
                width: 150
            )
            .previewDisplayName("Deduct")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
