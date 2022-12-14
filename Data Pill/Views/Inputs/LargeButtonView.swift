//
//  LargeButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct LargeButtonView: View {
    // MARK: - Props
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var title: String
    var disabled: Bool = false
    var action: Action
    
    var backgroundColor: Colors {
        (colorScheme == .light) ? .surface : .tertiary
    }
    
    var color: Colors {
        (colorScheme == .light) ? .onBackground : .onTertiary
    }
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            ZStack {
                
                Text(title)
                    .textStyle(
                        foregroundColor: color,
                        font: .semibold,
                        size: 20
                    )
                    .id(title)
                
            } //: ZStack
            .frame(height: 118)
            .fillMaxWidth()
            .background(backgroundColor.color)
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
        } //: Button
        .buttonStyle(ScaleButtonStyle())
        .disabled(disabled)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct LargeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LargeButtonView(
            title: "Title",
            action: {}
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
