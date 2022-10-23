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
    
    func cardShadow() -> some View {
        self.shadow(
            color: .black.opacity(0.02),
            radius: 15,
            y: 5
        )
    }
}


