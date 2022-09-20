//
//  DraggablePillView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct DraggablePillView: View {
    // MARK: - Props
    @State var heightTranslation: CGFloat = .zero
    @State var cardYOffset: CGFloat = .zero
    var date: Date = .init()
    
    // MARK: - UI
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                let newTranslationHeight = value.translation.height
                let amountChange = newTranslationHeight - heightTranslation
                heightTranslation = newTranslationHeight
        
                let newCardYOffset = cardYOffset + amountChange
                guard newCardYOffset < 388 else { return }
                withAnimation() {
                    cardYOffset = newCardYOffset
                }
            }
            .onEnded { _ in
                // reset
                heightTranslation = .zero
                withAnimation(
                    .interactiveSpring(
                        response: 0.1,
                        dampingFraction: 5
                    )
                ) {
                    cardYOffset = .zero
                }
            }
    }
    
    var body: some View {
        ZStack {
            PillView(
                color: .secondaryBlue,
                percentage: 20,
                date: date,
                hasBackground: false
            )
            .padding(.horizontal, 21)
            .offset(y: cardYOffset)
            .gesture(drag)
        }
        
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DraggablePillView_Previews: PreviewProvider {
    static var previews: some View {
        DraggablePillView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
