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
    var dataInMB: Double
    var maxDataInMB: Double
    
    var percentageUsed: Int {
        ((dataInMB / maxDataInMB) * 100).toInt()
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
            Text("\(dataInMB.toInt()) / \(maxDataInMB.toInt()) MB")
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 14,
                    lineLimit: 1
                )
                .opacity(0.5)
                .padding(.bottom, 10)
            
        } //: ItemCardView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsedCardView_Previews: PreviewProvider {
    static var previews: some View {
        UsedCardView(
            width: 150,
            dataInMB: 130,
            maxDataInMB: 300
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
