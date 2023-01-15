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
    var dataUnit: Unit
    var width: CGFloat
    
    var percentageUsed: Int {
        usedData.toPercentage(with: maxData)
    }
    
    var data: String {
        "\(usedData.toDp(n: 2)) / \(maxData.toDp(n: 2)) \(dataUnit.rawValue)"
    }
        
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "USED",
            verticalSpacing: 5,
            isToggleOn: .constant(false),
            width: width
        ) {
            
            // Row 1: PERCENTAGE USED
            HStack(
                alignment: .firstTextBaseline,
                spacing: 0
            ) {
                
                Text(verbatim: "\(percentageUsed)")
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
            Text(verbatim: "\(data)")
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 14,
                    lineLimit: 1
                )
                .opacity(0.5)
                .padding(.bottom, 10)
                .id(data)
                .accessibilityLabel(AccessibilityLabels.dataUsedAmount.rawValue)
            
        } //: ItemCardView
        .accessibilityIdentifier("used")
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsedCardView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel = .init()
    
    static var previews: some View {
        UsedCardView(
            usedData: 0.13,
            maxData: 0.3,
            dataUnit: appViewModel.unit,
            width: 150
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
