//
//  SaveButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 26/9/22.
//

import SwiftUI

struct SaveButtonView: View {
    // MARK: - Props
    var action: () -> Void
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            ZStack {
                
                Text("Save")
                    .textStyle(
                        foregroundColor: .onTertiary,
                        font: .semibold,
                        size: 20
                    )
                
            } //: ZStack
            .frame(height: 53)
            .padding(.horizontal, 38)
            .background(Colors.tertiary.color)
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
        } //: Button
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SaveButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SaveButtonView(action: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
