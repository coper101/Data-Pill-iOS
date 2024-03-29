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
    var isPlanActive: Bool
    
    var title1: LocalizedStringKey {
        isPlanActive ? "Plan" : "NA"
    }
    
    var title2: LocalizedStringKey {
        "Daily"
    }

    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "USAGE",
            verticalSpacing: 5,
            isToggleOn: .constant(false),
            width: width
        ) {
            
            ToggleView(
                selectedItem: $selectedItem,
                title1: title1,
                title2: title2
            )
            .padding(.bottom, 5)
            
        } //: ItemCardView
        .accessibilityIdentifier("usage")
        .disabled(!isPlanActive)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct UsageCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            UsageCardView(
                selectedItem: .constant(.plan),
                width: 150,
                isPlanActive: true
            )
            .previewDisplayName("Plan / Plan")
            
            UsageCardView(
                selectedItem: .constant(.daily),
                width: 150,
                isPlanActive: true
            )
            .previewDisplayName("Plan / Daily")
            
            UsageCardView(
                selectedItem: .constant(.daily),
                width: 150,
                isPlanActive: false
            )
            .previewDisplayName("Non-Plan")
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
