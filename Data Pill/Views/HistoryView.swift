//
//  HistoryView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions: Dimensions

    var paddingHorizontal: CGFloat = 21
    var days: [DayPill]
    var weekData: [Data]
    var dataLimitPerDay: Double
    var usageType: ToggleItem
    
    var showFilledLines: Bool = false
    var closeAction: () -> Void
    
    var descendingWeeksData: [Data] {
        weekData.sorted {
            guard
                let date1 = $0.date,
                let date2 = $1.date
            else {
                return false
            }
            return date1 < date2
        }
    }

    // MARK: - UI
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Row 1: Top Bar
            HStack(spacing: 0) {
                
                // TITLE
                Text("This Week")
                    .textStyle(
                        foregroundColor: .onBackground,
                        font: .bold,
                        size: 30,
                        maxWidth: .infinity,
                        lineLimit: 1
                    )
                
                // CLOSE
                CloseIconView(action: closeAction)
                
            } //: HStack
            .padding(.leading, 21)
            .padding(.trailing, 6)
            .padding(.top, dimensions.insets.top)
            
            // MARK: - Row 2: Days of Week
            ZStack {
                
                ForEach(
                    Array(descendingWeeksData.enumerated()),
                    id: \.element
                ) { index, data in

                    let day = days[index]
                    let isFirstPill = index == 0

                    DraggablePillView(
                        date: data.date ?? Date(),
                        color: day.color,
                        percentage: data.dailyUsedData.toGB()
                            .toPercentage(with: dataLimitPerDay),
                        usageType: usageType,
                        hasBackground: isFirstPill && showFilledLines,
                        showFillLine: showFilledLines,
                        hasPillOutline: isFirstPill && showFilledLines, /// show for first pill only - Sunday
                        widthScale: 0.65
                    )

                } //: ForEach
                
            } //: Group
            .fillMaxSize(alignment: .center)
            
        } //: VStack
        .accessibilityIdentifier("history")
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct HistoryView_Previews: PreviewProvider {
    static var repo = DataUsageFakeRepository(thisWeeksData: weeksDataSample)
    static var dataLimitPerDay = 2.0
    
    static var previews: some View {
        HistoryView(
            days: dayPills,
            weekData: repo.thisWeeksData,
            dataLimitPerDay: dataLimitPerDay,
            usageType: .daily,
            closeAction: {}
        )
        .previewDisplayName("Filled")
        
        HistoryView(
            days: dayPills,
            weekData: repo.thisWeeksData,
            dataLimitPerDay: dataLimitPerDay,
            usageType: .daily,
            showFilledLines: true,
            closeAction: {}
        )
        .previewDisplayName("Filled Lines")
    }
}

