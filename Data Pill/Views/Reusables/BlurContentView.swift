//
//  BlurContentView.swift
//  Data Pill
//
//  Created by Wind Versi on 26/9/22.
//

import SwiftUI

struct BlurContentView<Content>: View where Content: View {
    // MARK: - Props
    var isShown = false
    @ViewBuilder var content: () -> Content

    // MARK: - UI
    var body: some View {
        if isShown {
            // Layer 1:
            VisualEffectView(
                effect: UIBlurEffect(style: .regular)
            )
                .zIndex(1)
            
            // Layer 2:
            content()
                .zIndex(2)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct BlurContentView_Previews: PreviewProvider {
    static var previews: some View {
        BlurContentView(isShown: true) { Text("Content") }
            .previewLayout(.sizeThatFits)
    }
}
