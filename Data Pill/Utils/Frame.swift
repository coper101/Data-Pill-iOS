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
