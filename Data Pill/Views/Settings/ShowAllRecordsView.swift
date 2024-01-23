//
//  ShowAllRecordsView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

struct DataRecord {
    let date: Date
    let usedAmount: Double /// in MB
}

extension DataRecord: Identifiable {
    var id: Date {
        date
    }
}

struct ShowAllRecordsView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    @Environment(\.locale) var locale: Locale

    var records: [DataRecord] {
        let todaysDate = Date()
        return [
            .init(
                date: Calendar.current.startOfDay(
                    for: Calendar.current.date(
                        byAdding: .day,
                        value: 0,
                        to: todaysDate
                    )!
                ),
                usedAmount: 20
            ),
            .init(
                date: Calendar.current.startOfDay(
                    for: Calendar.current.date(
                        byAdding: .day,
                        value: -1,
                        to: todaysDate
                    )!
                ),
                usedAmount: 20
            ),
            .init(
                date: Calendar.current.startOfDay(
                    for: Calendar.current.date(
                        byAdding: .day,
                        value: -2,
                        to: todaysDate
                    )!
                ),
                usedAmount: 20
            ),
            .init(
                date: Calendar.current.startOfDay(
                    for: Calendar.current.date(
                        byAdding: .day,
                        value: -3,
                        to: todaysDate
                    )!
                ),
                usedAmount: 20
            )
        ]
    }
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                
                ForEach(records) { record in
                    
                    let hasDivider: Bool = {
                        if let lastRecord = records.last {
                            return lastRecord.id != record.id
                        }
                        return true
                    }()
                    
                    SettingsRowView(
                        title: "\(record.usedAmount) MB",
                        icon: .pillIcon,
                        iconColor: .secondaryGreen,
                        hasDivider: hasDivider
                    ) {
                        Text(
                            record.date.toDayMonthFormat(
                                locale: locale.identifier,
                                format: "d MMM YYY"
                            )
                        )
                        .textStyle(
                            foregroundColor: .onSurfaceLight,
                            size: 16
                        )
                        .padding(.vertical, 4)
                    }
                    
                } //: ForEach
                
            } //: VStack
            .rowSection(title: "")
            .padding(.horizontal, dimensions.horizontalPadding)
             
        } //: ScrollView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct ShowAllRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowAllRecordsView()
            .previewLayout(.sizeThatFits)
            .background(Colors.background.color)
            .padding()
            .environmentObject(TestData.createAppViewModel())
    }
}
