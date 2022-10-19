//
//  ButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 26/9/22.
//

import SwiftUI

enum ButtonType: String, Identifiable, CaseIterable {
    case save = "Save"
    case done = "Done"
    var id: String {
        self.rawValue
    }
}

struct ButtonView: View {
    // MARK: - Props
    var type: ButtonType
    var action: (ButtonType) -> Void
    
    // MARK: - UI
    var body: some View {
        Button(action: { action(type) }) {
            ZStack {
                
                Text(type.rawValue)
                    .textStyle(
                        foregroundColor: .onTertiary,
                        font: .semibold,
                        size: 20
                    )
                    .id(type.rawValue)
                    .transition(.opacity.animation(.linear.delay(0.2)))
                
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
struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(ButtonType.allCases) { type in
            ButtonView(type: type, action: { _ in })
                .previewLayout(.sizeThatFits)
                .previewDisplayName(type.rawValue)
                .padding()
        }
        
    }
}
