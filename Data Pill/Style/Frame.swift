//
//  Frame.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct FrameModifier: ViewModifier {
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    var alignment: Alignment
    
    func body(content: Content) -> some View {
        content.frame(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            alignment: alignment
        )
    }
}

extension View {
    
    /// Sets the Height to a fraction of maximum space available in Y axis
    func fillHeightFraction(
        fraction: Double,
        alignment: Alignment = .center
    ) -> some View {
        self.frame(
            height: fraction * UIScreen.main.bounds.size.height,
            alignment: alignment
        )
    }
    
    /// Sets the Width and Height of View
    func size(
        length: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        self.frame(
            width: length,
            height: length,
            alignment: alignment
        )
    }
    
    /// Sets the Height to maximum space available in Y axis
    func fillMaxHeight(
        alignment: Alignment = .center
    ) -> some View {
        modifier(
            FrameModifier(
                maxWidth: nil,
                maxHeight: .infinity,
                alignment: alignment
            )
        )
    }
    
    /// Sets the Width to maximum space available in X axis
    func fillMaxWidth(
        alignment: Alignment = .center
    ) -> some View {
        modifier(
            FrameModifier(
                maxWidth: .infinity,
                maxHeight: nil,
                alignment: alignment
            )
        )
    }
    
    /// Sets the Width and Height to maximum space available in both X and Y axis
    func fillMaxSize(
        alignment: Alignment = .center
    ) -> some View {
        modifier(
            FrameModifier(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: alignment
            )
        )
    }
    
}
