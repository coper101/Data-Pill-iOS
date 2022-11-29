//
//  PillView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct PillView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions: Dimensions

    var color: Colors = .secondaryBlue
    var percentage: Int
    var date: Date
    var hasBackground = true
    var usageType: ToggleItem
    var widthScale: CGFloat = 0.45
    var isContentShown = true

    var displayedDate: String {
        switch usageType {
        case .plan:
            return "TOTAL"
        case .daily:
            return date.isToday() ?
                "TODAY" :
                date.toDayMonthFormat().uppercased()
        }
    }
    
    // MARK: - UI
    var label: some View {
        HStack(spacing: 0) {
            
            // Col 1: PERCENTAGE
            Text("\(percentage)%")
                .textStyle(
                    foregroundColor: .onSecondary,
                    font: .semibold,
                    size: 20
                )
                .opacity(0.5)
            
            // Col 2: TODAY or DATE
            Spacer()
            Text(displayedDate)
                .textStyle(
                    foregroundColor: .onSecondary,
                    font: .semibold,
                    size: 20
                )
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            
        } //: HStack
        .padding(.horizontal, 18)
    }
    
    var body: some View {
        BasePillView(
            percentage: percentage,
            isContentShown: isContentShown,
            hasBackground: hasBackground,
            color: color,
            widthScale: widthScale,
            label: { label }
        )
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct PillView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel = .init()
    
    static var previews: some View {
        Group {
            
            PillView(
                color: appViewModel.days[0].color,
                percentage: 20,
                date: Date(),
                usageType: .daily
            )
            .previewDisplayName(
                displayName(
                    "Content Shown"
                )
            )
            
            PillView(
                color: appViewModel.days[0].color,
                percentage: 20,
                date: Date(),
                usageType: .daily,
                isContentShown: false
            )
            .previewDisplayName(
                displayName(
                    "Content Hidden"
                )
            )
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
