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
    var title: LocalizedStringKey
    var disabled: Bool = false
    var hasOutline: Bool = false
    var id: String
    var action: Action
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            ZStack {
                
                Text(
                    title,
                    comment: "Button title for User Guide"
                )
                .textStyle(
                    foregroundColor: .onSecondary,
                    font: .semibold,
                    size: 22
                )
                .id(id)
                
            } //: ZStack
            .frame(height: 118)
            .fillMaxWidth()
            .background(Color.white.opacity(0.1))
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        Colors.onSecondary.color, 
                        lineWidth: hasOutline ? 2 : 0
                    )
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
        Group {
            
            LargeButtonView(
                title: "Title",
                id: "Title",
                action: {}
            )
            .previewDisplayName("w/o outline")
            
            LargeButtonView(
                title: "Title",
                hasOutline: true,
                id: "Title",
                action: {}
            )
            .previewDisplayName("w/ outline")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Colors.secondaryBlue.color)
    }
}
