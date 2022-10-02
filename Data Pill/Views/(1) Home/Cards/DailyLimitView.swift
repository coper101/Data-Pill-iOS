//
//  DailyLimitView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct DailyLimitView: View {
    // MARK: - Props
    var dataLimitAmount: Double
    
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini2,
            subtitle: "Daily\nLimit"
        ) {
            HStack(
                alignment: .bottom,
                spacing: 2
            ) {
                
                // Col 1: AMOUNT
                Text(dataLimitAmount.toDp())
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 30,
                        lineLimit: 1
                    )
                
                // Col 2: UNIT
                Text("GB")
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 18,
                        lineLimit: 1
                    )
                    .alignmentGuide(.bottom) { $0.height + 3 }
                
            } //: HStack
            .fillMaxSize()

        } //: ItemCardView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DailyLimitView_Previews: PreviewProvider {
    static var previews: some View {
        DailyLimitView(dataLimitAmount: 300)
            .frame(width: 175, height: 145)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
