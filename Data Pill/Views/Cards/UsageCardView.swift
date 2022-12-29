//
//  UsageCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import SwiftUI

struct UsageCardView: View {
    // MARK: - Props
    @Binding var selectedItem: ToggleItem
    var width: CGFloat

    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "USAGE",
            verticalSpacing: 5,
            width: width
        ) {
            ToggleView(
                selectedItem: $selectedItem,
                title1: ToggleItem.plan.rawValue,
                title2: ToggleItem.daily.rawValue
            )
            .padding(.bottom, 5)
        } //: ItemCardView
        .accessibilityIdentifier("usage")
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsageCardView_Previews: PreviewProvider {
    static var previews: some View {
        UsageCardView(
            selectedItem: .constant(.plan),
            width: 150
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
