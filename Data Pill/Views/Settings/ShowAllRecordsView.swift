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
    
    func displayedDate(_ localeIdentifier: String) -> String {
        date.toDayMonthFormat(
            locale: localeIdentifier,
            format: "d MMM YYY"
        )
    }
    
    var displayedAmount: String {
        let amountInMB = usedAmount.toMB()
        let amountInGB = usedAmount.toGB()
        if amountInMB >= 1_000_000 {
            return "\(amountInGB.toDp()) GB"
        }
        return "\(amountInMB.toDp()) MB"
    }
}

struct ShowAllRecordsView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    @Environment(\.locale) var locale: Locale

    var records: [DataRecord] {
        appViewModel.allData.compactMap { data in
            guard let date = data.date else {
                return nil
            }
            return .init(
                date: date,
                usedAmount: data.dailyUsedData
            )
        }
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
                        title: record.displayedAmount,
                        icon: .pillIcon,
                        iconColor: .secondaryGreen,
                        hasDivider: hasDivider
                    ) {
                        Text(record.displayedDate(locale.identifier))
                            .textStyle(
                                foregroundColor: .onSurfaceLight,
                                size: 16
                            )
                            .padding(.vertical, 4)
                    }
                    
                } //: ForEach
                
            } //: VStack
            .rowSection(title: "\(records.count) Items")
            .padding(.horizontal, dimensions.horizontalPadding)
            .padding(.top, 21)
             
        } //: ScrollView
        .onAppear(perform: appViewModel.loadAllRecords)
        .onDisappear(perform: appViewModel.clearRecords)
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
