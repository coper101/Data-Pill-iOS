//
//  Animation.swift
//  Data Pill
//
//  Created by Wind Versi on 15/10/22.
//

import SwiftUI

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
                withAnimation(
                    .spring(
                        response: 0.45,
                        dampingFraction: 0.7
                    )
                ) {
                    offsetY = 0
                }
            } //: onAppear
            .onDisappear {
                withAnimation(.spring()) {
                    offsetY = maxOffsetY
                }
            } //: onDisappear
    }
}

extension View {
    
    /// Applies a bounce animatio when the View becomes visible
    /// - Parameter maxOffsetY : the initial offset in y axis before it animates to the original position
    func popBounceEffect(maxOffsetY: CGFloat) -> some View {
        modifier(PopBounce(maxOffsetY: maxOffsetY))
    }
    
}
