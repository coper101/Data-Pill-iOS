//
//  Button.swift
//  Data Pill
//
//  Created by Wind Versi on 24/10/22.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    // MARK: - Props
    var minScale: CGFloat = 0.8
    @State private var scale: CGFloat = 1
    
    // MARK: - UI
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(scale)
            .onChange(of: configuration.isPressed) { isPresed in
                withAnimation {
                    scale = isPresed ? minScale : 1.0
                }
            }
    }
}
