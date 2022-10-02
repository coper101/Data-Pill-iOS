//
//  DateInputView.swift
//  Data Pill
//
//  Created by Wind Versi on 26/9/22.
//

import SwiftUI

struct DateInputView: View {
    // MARK: - Props
    var date: Date
    var title: String
    var action: () -> Void
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: 10) {
            
            // TITLE
            Text(title)
                .textStyle(
                    foregroundColor: .onSurfaceLight,
                    font: .semibold,
                    size: 18,
                    maxWidth: .infinity
                )
            
            // INPUT
            Button(action: action) {
                
                VStack() {
                    
                    Text("\(date.toDayMonthYearFormat())".uppercased())
                        .textStyle(
                            foregroundColor: .onSurface,
                            font: .semibold,
                            size: 18
                        )
                    
                } //: VStack
                .fillMaxWidth()
                .frame(height: 53)
                .background(Colors.onSurfaceDark.color)
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
                
            } //: Button
            
        } //: VStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DateInputView_Previews: PreviewProvider {
    static var previews: some View {
        DateInputView(
            date: Date(),
            title: "TITLE",
            action: {}
        )
            .previewLayout(.sizeThatFits)
            .padding()
            .frame(width: 184)
    }
}

