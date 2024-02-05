//
//  DraggablePillView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct DraggablePillView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions: Dimensions
    @State private var translation: CGSize = .zero
    @State private var cardOffset: CGSize = .zero
    
    var date: Date = .init()
    var color: Color
    var percentage: Int
    var usageType: ToggleItem
    
    var hasBackground = false
    var showFillLine = false
    var hasPillOutline = false /// for tracking pill outline
    
    var widthScale: CGFloat = 0.45
    
    // MARK: - UI
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                
                let heightTrans = value.translation.height
                let widthTrans = value.translation.width
                
                let amountChange = CGSize(
                    width: widthTrans - translation.width,
                    height: heightTrans - translation.height
                )
                translation = value.translation
                        
                let newCardOffset = CGSize(
                    width: cardOffset.width + amountChange.width,
                    height: cardOffset.height + amountChange.height
                )
                
                guard newCardOffset.height < 388 else { return }
                withAnimation(
                    .linear(duration: 0.2)
                ) {
                    cardOffset = newCardOffset
                }
            }
            .onEnded { _ in
                // reset
                translation = .zero
                withAnimation(
                    .spring(dampingFraction: 0.6)
                ) {
                    cardOffset = .zero
                }
            }
    }
    
    var body: some View {
        ZStack {
            PillView(
                color: color,
                percentage: percentage,
                date: date,
                hasBackground: hasBackground,
                usageType: usageType,
                widthScale: widthScale,
                showFillLine: showFillLine,
                hasPillOutline: hasPillOutline,
                showPercentage: true
            )
            .padding(.horizontal, dimensions.horizontalPadding)
            .offset(cardOffset)
            .`if`(!showFillLine) { view in
                view.gesture(drag)
            }
        }
        
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DraggablePillView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            DraggablePillView(
                color: Colors.secondaryBlue.color,
                percentage: 20,
                usageType: .daily
            )
            .previewDisplayName("Filled")
            
            DraggablePillView(
                color: Colors.secondaryBlue.color,
                percentage: 20,
                usageType: .daily,
                showFillLine: true
            )
            .previewDisplayName("Fill Line")
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
