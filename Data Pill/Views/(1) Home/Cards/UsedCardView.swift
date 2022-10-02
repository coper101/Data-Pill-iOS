//
//  UsedCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct UsedCardView: View {
    // MARK: - Props
    var usedData: Double
    var maxData: Double
    var dataUnit: Unit
    var width: CGFloat
    var height: CGFloat?
    
    var percentageUsed: Int {
        usedData.toPercentage(with: maxData)
    }
    
    var data: String {
        "\(usedData.toDp(n: 2)) / \(maxData.toDp(n: 2)) \(dataUnit.rawValue)"
    }
        
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "USED",
            verticalSpacing: 5,
            width: width
        ) {
            
            // Row 1: PERCENTAGE USED
            Text("\(percentageUsed) %")
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 32,
                    lineLimit: 1
                )
            
            // Row 2: DATA
            Text(data)
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 14,
                    lineLimit: 1
                )
                .opacity(0.5)
                .padding(.bottom, 10)
            
        } //: ItemCardView
        .frame(height: height)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsedCardView_Previews: PreviewProvider {
    static var appState: AppState = .init()
    
    static var previews: some View {
        UsedCardView(
            usedData: appState.todaysData.dailyUsedData,
            maxData: appState.dataLimitPerDay,
            dataUnit: appState.unit,
            width: 150,
            height: 0.34 * 400
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
