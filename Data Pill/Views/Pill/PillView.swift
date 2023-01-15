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
    @Namespace private var animation

    var color: Colors
    var percentage: Int
    var date: Date
    var hasBackground = true
    var usageType: ToggleItem
    var widthScale: CGFloat = 0.45
    var customSize: CGSize? = nil
    
    var isContentShown = true
    var showFillLine = false
    var hasPillOutline = false /// for tracking pill outline
    var showPercentage = false
    
    // MARK: - UI
    var label: some View {
        PillTitleView(
            date: date,
            percentage: percentage,
            showPercentage: showPercentage,
            usageType: usageType
        )
    }
    
    var body: some View {
        BasePillView(
            percentage: percentage,
            isContentShown: isContentShown,
            fillLineTitle: showFillLine ? getPillTitle(with: usageType, on: date) : nil,
            fillLineTitleCharCount: showFillLine ? getPillTitleCharCount(with: usageType, on: date) : 0,
            hasPillOutline: hasPillOutline,
            hasBackground: hasBackground,
            color: color,
            widthScale: widthScale,
            customSize: customSize,
            label: {
                if percentage >= 15 {
                    label
                }
            },
            faintLabel: {}
        )
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct PillView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel = .init()
    static var percentage = 100
    
    static var previews: some View {
        Group {
            
            PillView(
                color: appViewModel.days[0].color,
                percentage: percentage,
                date: Date(),
                usageType: .daily
            )
            .previewDisplayName(
                displayName("Filled")
            )
            
            PillView(
                color: appViewModel.days[0].color,
                percentage: percentage,
                date: Date(),
                usageType: .daily,
                isContentShown: false,
                showFillLine: true
            )
            .previewDisplayName(
                displayName("Fill Line")
            )
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

func getPillTitle(with usageType: ToggleItem, on date: Date) -> LocalizedStringKey {
    switch usageType {
    case .plan:
        return "TOTAL"
    case .daily:
        return date.isToday() ?
            "TODAY" : date.getWeekday().toLocalizedWeekdayName()
    }
}

func getPillTitleCharCount(with usageType: ToggleItem, on date: Date) -> Int {
    switch usageType {
    case .plan:
        return "TOTAL".count
    case .daily:
        return {
            let title = date.isToday() ?
                "TODAY" : date.getWeekday().toWeekdayName()
            return title.count
        }()
    }
}
