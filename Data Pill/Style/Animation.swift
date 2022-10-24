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

struct ScrollAndSnap: ViewModifier {
    // MARK: - Props
    let contentHeight: CGFloat
    let screenHeight: CGFloat
    @State private var yTranslation: CGFloat = .zero
    @State private var contentYOffset: CGFloat = .zero
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                let heightTrans = value.translation.height
                yTranslation = heightTrans
            }
            .onEnded { _ in
                // scroll up or down
                withAnimation(.popBounce()) {
                    contentYOffset = yTranslation < 0 ?
                        -(contentHeight - screenHeight) :
                        .zero
                }
                // reset
                yTranslation = .zero
            }
    }
    
    // MARK: - UI
    func body(content: Content) -> some View {
        content
            .highPriorityGesture(drag)
            .offset(y: contentYOffset)
    }
}

extension View {
    
    /// Applies a bounce animation when the View becomes visible
    /// - Parameter maxOffsetY : The initial offset in y axis before it animates to the original position
    func popBounceEffect(maxOffsetY: CGFloat = 100) -> some View {
        modifier(PopBounce(maxOffsetY: maxOffsetY))
    }
    
    /// Applies a gesture to scroll the content up and down in a fixed behaviour
    /// - Parameters:
    ///  - contentHeight: The height of the content to scroll
    ///  - screenHeight: The height of the screen
    func scrollSnap(
        contentHeight: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        modifier(
            ScrollAndSnap(
                contentHeight: contentHeight,
                screenHeight: screenHeight
            )
        )
    }
    
}
