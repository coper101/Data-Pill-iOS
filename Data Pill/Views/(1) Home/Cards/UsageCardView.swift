//
//  UsageCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import SwiftUI

struct UsageCardView: View {
    // MARK: - Props
    @Binding var selectedItem: Item
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
                title1: "Plan",
                title2: "Daily"
            )
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsageCardView_Previews: PreviewProvider {
    static var previews: some View {
        UsageCardView(
            selectedItem: .constant(.item1),
            width: 150
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
