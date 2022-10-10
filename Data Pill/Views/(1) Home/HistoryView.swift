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
    var paddingHorizontal: CGFloat = 21
    var days: [DayPill]
    var weekData: [Data]
    var dataLimitPerDay: Double
    var usageType: ToggleItem
    var closeAction: () -> Void
    
    var descendingWeeksData: [Data] {
        weekData.sorted {
            guard
                let date1 = $0.date,
                let date2 = $1.date
            else {
                return false
            }
            return date1 > date2
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
            .padding(.leading, 16)
            .padding(.trailing, 20)
            .padding(.bottom, 17)
            .padding(.top, EdgeInsets.insets.top + 4)
            
            // MARK: - Row 2: Days of Week
            ZStack {
                
                ForEach(Array(descendingWeeksData.enumerated()), id: \.element) { index, element in
                    DraggablePillView(
                        date: element.date ?? Date(),
                        color: days[index].color,
                        percentage: element.dailyUsedData.toGB().toPercentage(with: dataLimitPerDay),
                        usageType: usageType,
                        widthScale: 0.65
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
            .previewLayout(.sizeThatFits)
    }
}

