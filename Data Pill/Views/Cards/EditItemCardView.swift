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
    
    var toastMessage: String? = nil
    
    @ViewBuilder var content: () -> Content
    
    // MARK: - UI
    var body: some View {
        ZStack {
            
            // Layer 1: Toast
            if let toastMessage {
                ToastView(message: toastMessage)
                    .zIndex(0)
                    .offset(y: -150)
                    .popSlide(endOffsetY: 100)
            }
            
            // Layer 2: Input
            VStack(
                alignment: .trailing,
                spacing: 0
            ) {
            
                // Row 2: CARD
                content()
                    .opacity(isCardShown ? 1 : 0)
                    .animation(nil, value: isCardShown)
                
                // Row 3: ACTION BUTTON
                ButtonView(
                    type: buttonType,
                    disabled: buttonDisabled,
                    action: buttonAction
                )
                .offset(y: spaceBetween)
                
            } //: VStack
            .zIndex(1)
            
        } //: ZStack
        .fixedSize()
        .animation(.easeIn, value: toastMessage)

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
                spaceBetween: 30,
                toastMessage: "Exceeds maximum data amount"
            ) {
                ItemCardView(
                    style: .wide,
                    subtitle: "Card",
                    backgroundColor: .background,
                    isToggleOn: .constant(false),
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
                    backgroundColor: .background,
                    isToggleOn: .constant(false),
                    content: {}
                )
            }
                .previewDisplayName("Done")
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .frame(height: 300)
        .background(Color.green)
    }
}
