//
//  HistoryView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct HistoryView: View {
    // MARK: - Props
    var paddingHorizontal: CGFloat = 21

    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            
            // Row 1: TITLE
            Text("This Week")
                .textStyle(
                    foregroundColor: .onBackground,
                    font: .semibold,
                    size: 30,
                    maxWidth: .infinity,
                    lineLimit: 1
                )
                .padding(.horizontal, paddingHorizontal)
            
            // Row 
            
        } //: VStack
        .fillMaxSize()
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .previewLayout(.sizeThatFits)
    }
}
