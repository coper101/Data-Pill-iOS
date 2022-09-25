//
//  UsedCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct UsedCardView: View {
    // MARK: - Props
    var width: CGFloat
    var usedData: Double
    var maxData: Double
    var height: CGFloat?
    
    var percentageUsed: Int {
        ((usedData / maxData) * 100).toInt()
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
            
            // Row 2: DATA in MB
            Text("\(usedData.to1dp()) / \(maxData.to1dp()) GB")
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
            width: 150,
            usedData: appState.todaysData.dataUsed,
            maxData: appState.dataLimitPerDay
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
