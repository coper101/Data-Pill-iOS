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

    var color: Color
    var percentage: Int
    var date: Date
    
    var hasBackground: Bool = true
    var hasLabel: Bool = true
    var usageType: ToggleItem
    
    var widthScale: CGFloat = 0.45
    var customSize: CGSize? = nil
    
    var isContentShown: Bool = true
    var showFillLine: Bool = false
    var hasPillOutline: Bool = false /// for tracking pill outline
    var showPercentage: Bool = false
    
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
                if percentage >= 15 && hasLabel {
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
                color: appViewModel.dayColors.values.first!,
                percentage: percentage,
                date: Date(),
                usageType: .daily
            )
            .previewDisplayName(
                displayName("Filled")
            )
            
            PillView(
                color: appViewModel.dayColors.values.first!,
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
            "TODAY" : date.getWeekday().toLocalizedShortWeekdayName()
    }
}

func getPillTitleCharCount(with usageType: ToggleItem, on date: Date) -> Int {
    switch usageType {
    case .plan:
        return "TOTAL".count
    case .daily:
        return {
            let title = date.isToday() ?
                "TODAY" : date.getWeekday().toShortWeekdayName()
            return title.count
        }()
    }
}
