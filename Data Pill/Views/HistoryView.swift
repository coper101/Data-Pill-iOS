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
    var dayColors: [Day: Color]
    var weekData: [Data]
    var dataLimitPerDay: Double
    var usageType: ToggleItem
    var fillUsageType: FillUsage
    
    var hasLabel: Bool = true
    var showFilledLines: Bool = false
    var closeAction: () -> Void
    
    var thisWeekData: [Data] {
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
                Text(
                    "This Week",
                    comment: "The title for viewing all the data usage for the week"
                )
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
                    Array(thisWeekData.enumerated()),
                    id: \.element
                ) { index, data in
                    

                    if 
                        let date = data.date,
                        let color = dayColors[date.getWeekday().toDay()]
                    {
                        
                        let isFirstPill = index == 0
                        let percentage = data.dailyUsedData.toGB().displayedUsageInPercentage(
                            maxData: dataLimitPerDay,
                            fillUsageType: fillUsageType
                        )
                        
                        DraggablePillView(
                            date: date,
                            color: color,
                            percentage: percentage,
                            usageType: usageType,
                            hasLabel: hasLabel,
                            hasBackground: isFirstPill && showFilledLines,
                            showFillLine: showFilledLines,
                            hasPillOutline: isFirstPill && showFilledLines, /// show for first pill only - Sunday
                            widthScale: 0.65
                        )
                        
                    } else {
                        
                        EmptyView()
                    }

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
    static func repo(allDays: Bool = true) -> DataUsageFakeRepository {
        .init(thisWeeksData: allDays ? TestData.weeksDataSample : TestData.weeksDataWithMissingDaysSample)
    }
    static var dataLimitPerDay = 2.0
    
    static var previews: some View {
        Group {
            
            HistoryView(
                dayColors: defaultDayColors,
                weekData: repo().thisWeeksData,
                dataLimitPerDay: dataLimitPerDay,
                usageType: .daily,
                fillUsageType: .accumulate,
                closeAction: {}
            )
            .previewDisplayName("All Days / Filled")
            
            HistoryView(
                dayColors: defaultDayColors,
                weekData: repo().thisWeeksData,
                dataLimitPerDay: dataLimitPerDay,
                usageType: .daily,
                fillUsageType: .accumulate,
                showFilledLines: true,
                closeAction: {}
            )
            .previewDisplayName("All Days / Filled Lines")
            
            HistoryView(
                dayColors: defaultDayColors,
                weekData: repo(allDays: false).thisWeeksData,
                dataLimitPerDay: dataLimitPerDay,
                usageType: .daily,
                fillUsageType: .accumulate,
                closeAction: {}
            )
            .previewDisplayName("Missing Days / Filled")
            
            HistoryView(
                dayColors: defaultDayColors,
                weekData: repo(allDays: false).thisWeeksData,
                dataLimitPerDay: dataLimitPerDay,
                usageType: .daily,
                fillUsageType: .accumulate,
                showFilledLines: true,
                closeAction: {}
            )
            .previewDisplayName("Missing Days / Filled Lines")
            
        }
        // .environment(\.locale, .simplifiedChinese)
        // .environment(\.locale, .filipino)
    }
}

