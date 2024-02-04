//
//  Modifier.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

extension View {
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        _ transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a light shadow to a view
    /// Mainly used for a `Item Card View`
    /// - Returns: The `View` with applied shadow
    func cardShadow(
        radius: CGFloat = 10,
        y: CGFloat = 2,
        opacity: Double = 0.1,
        scheme: ColorScheme
    ) -> some View {
        let color: Color = (scheme == .light) ? .black : .white
        return self
            .shadow(
                color: color.opacity(opacity),
                radius: radius,
                y: y
            )
    }
    
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}
