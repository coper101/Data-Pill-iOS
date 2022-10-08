//
//  HistoryView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct HistoryView: View {
    // MARK: - Props
    var paddingHorizontal: CGFloat = 21
    var days: [DayPill]
    var weekData: [Data]
    var dataLimitPerDay: Double
    var usageType: ToggleItem
    var closeAction: () -> Void

    // MARK: - UI
    var body: some View {
        VStack(spacing: 0) {
            
            // Row 1:
            HStack(spacing: 0) {
                
                // TITLE
                Text("This Week")
                    .textStyle(
                        foregroundColor: .onBackground,
                        font: .semibold,
                        size: 30,
                        maxWidth: .infinity,
                        lineLimit: 1
                    )
                
                // CLOSE
                CloseIconView(action: closeAction)
                
            } //: HStack
            .padding(.horizontal, 35)
            .padding(.bottom, 17)
            .padding(.top, 17)
            
            
            // Row 2: WEEKDAYS
            ZStack {
                
                ForEach(weekData) { weekdayData in
                    
                    DraggablePillView(
                        date: weekdayData.date ?? Date(),
                        color: days[dayPillIndex(weekdayData)].color,
                        percentage: weekdayData.dailyUsedData.toPercentage(with: dataLimitPerDay),
                        usageType: usageType,
                        widthScale: 0.75
                    )
                    
                } //: ForEach
                
            } //: Group
            .padding(.bottom, 40)
            .fillMaxSize(alignment: .bottom)
            
        } //: VStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct HistoryView_Previews: PreviewProvider {
    static var appState = AppState()
    
    static var previews: some View {
        HistoryView(
            days: appState.days,
            weekData: appState.thisWeeksData,
            dataLimitPerDay: appState.dataLimitPerDay,
            usageType: .daily,
            closeAction: {}
        )
            .previewLayout(.sizeThatFits)
    }
}
