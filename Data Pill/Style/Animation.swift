//
//  Animation.swift
//  Data Pill
//
//  Created by Wind Versi on 15/10/22.
//

import SwiftUI

extension Animation {
    
    static func popBounce() -> Animation {
       .spring(
            response: 0.4,
            dampingFraction: 0.7
       )
    }
    
}


struct PopBounce: ViewModifier {
    // MARK: - Props
    let maxOffsetY: CGFloat
    @State var offsetY: CGFloat
    
    init(maxOffsetY: CGFloat) {
        self.maxOffsetY = maxOffsetY
        self.offsetY = maxOffsetY
    }
    
    // MARK: - UI
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .scaleEffect(offsetY == 100 ? 0.8 : 1)
            .onAppear {
                withAnimation(.popBounce()) {
                    offsetY = 0
                }
            } //: onAppear
            .transition(
                .asymmetric(
                    insertion: .opacity,
                    removal: .offset(y: 50)
                        .combined(
                            with: .opacity.animation(.easeOut(duration: 0.15))
                        )
                )
            )
    }
}

extension View {
    
    /// Applies a bounce animatio when the View becomes visible
    /// - Parameter maxOffsetY : the initial offset in y axis before it animates to the original position
    func popBounceEffect(maxOffsetY: CGFloat = 100) -> some View {
        modifier(PopBounce(maxOffsetY: maxOffsetY))
    }
    
}
