//
//  DataPlanCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct DataPlanCardView: View {
    // MARK: - Props
    var startDate: Date
    var endDate: Date
    var dataAmount: Double
    
    var numberOfdays: Int {
        Calendar.current
            .daysBetween(
                start: startDate,
                end: endDate
            )
    }
    
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .wide,
            subtitle: "Data Plan"
        ) {
            
            // Row 1: PERIOD
            NavRowView(
                title: "\(startDate.toDayMonthFormat().uppercased()) - \(endDate.toDayMonthFormat().uppercased())",
                subtitle: "\(numberOfdays) Days",
                action: {}
            )
            .padding(.top, 10)
            DividerView()
                .padding(.vertical, 5)
            
            // Row 2: DATA AMOUNT
            NavRowView(
                title: "10 GB",
                subtitle: "",
                action: {}
            )
            
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DataPlanCardView_Previews: PreviewProvider {
    static var previews: some View {
        DataPlanCardView(
            startDate: "2022-09-12T10:44:00+0000".toDate(),
            endDate: "2022-10-12T10:44:00+0000".toDate(),
            dataAmount: 10.0
        )
            .previewLayout(.sizeThatFits)
            .padding()
            // .background(Colors.Background)
    }
}
