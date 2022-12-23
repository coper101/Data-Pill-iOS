//
//  EditItemCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 23/12/22.
//

import SwiftUI

struct EditItemCardView<Content>: View where Content: View {
    // MARK: - Props
    var buttonType: ButtonType
    var buttonAction: (ButtonType) -> Void
    var buttonDisabled = false
    var spaceBetween: CGFloat
    var isCardShown = true
    @ViewBuilder var content: () -> Content
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .trailing,
            spacing: 0
        ) {
            
            // Row 1: CARD
            content()
                .opacity(isCardShown ? 1 : 0)
                .animation(nil, value: isCardShown)
            
            // Row 2: ACTION BUTTON
            ButtonView(
                type: buttonType,
                disabled: buttonDisabled,
                action: buttonAction
            )
            .offset(y: spaceBetween)
            
        } //: VStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct EditItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            EditItemCardView(
                buttonType: .save,
                buttonAction: { _ in },
                spaceBetween: 30
            ) {
                ItemCardView(
                    style: .wide,
                    subtitle: "Card",
                    content: {}
                )
            }
                .previewDisplayName("Save")
            
            EditItemCardView(
                buttonType: .done,
                buttonAction: { _ in },
                spaceBetween: 30
            ) {
                ItemCardView(
                    style: .wide,
                    subtitle: "Card",
                    content: {}
                )
            }
                .previewDisplayName("Done")
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white)
    }
}
