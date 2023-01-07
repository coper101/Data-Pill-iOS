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
    case start = "Start"
    var id: String {
        self.rawValue
    }
}

struct ButtonView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions: Dimensions
    var type: ButtonType
    var disabled = false
    var fullWidth = false
    var action: (ButtonType) -> Void
    
    var backgroundColor: Colors {
        !disabled ? Colors.tertiary : Colors.tertiaryDisabled
    }
    
    var color: Colors {
        !disabled ? Colors.onTertiary : Colors.onTertiaryDisabled
    }
    
    var height: CGFloat {
        (type == .start ) ?
        dimensions.buttonHeightTall : dimensions.buttonHeight
    }
    
    // MARK: - UI
    var body: some View {
        Button(action: { action(type) }) {
            ZStack {
                
                Text(type.rawValue)
                    .textStyle(
                        foregroundColor: color,
                        font: .semibold,
                        size: 20
                    )
                    .id(type.rawValue)
                    .transition(.opacity.animation(.linear.delay(0.2)))
                
            } //: ZStack
            .frame(height: height)
            .`if`(fullWidth) { view in
                view.fillMaxWidth()
            }
            .`if`(!fullWidth) { view in
                view.padding(.horizontal, 38)
            }
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
struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(ButtonType.allCases) { type in
            ButtonView(
                type: type,
                disabled: true,
                action: { _ in }
            )
                .previewLayout(.sizeThatFits)
                .previewDisplayName(type.rawValue)
                .padding()
        }
        
    }
}
