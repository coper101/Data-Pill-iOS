//
//  SlideToggleView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct SlideToggleView: View {
    // MARK: - Props
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let minXOffset: CGFloat = 4
    let maxXOffset: CGFloat = 25
    var activeColor: Colors = .onSurfaceLight
    var inactiveColor: Colors = .onSurfaceLight2
    @Binding var isOn: Bool
    
    var handleXOffset: CGFloat {
        isOn ? maxXOffset : minXOffset
    }
    
    var background: Colors {
        isOn ? activeColor : inactiveColor
    }
    
    // MARK: - UI
    var body: some View {
        Button(action: didTapToggle) {
            
            ZStack(alignment: .leading) {
                
                // Layer 1: BACKGROUND
                background.color
                
                // Layer 2: HANDLE
                Circle()
                    .fill(Colors.surface.color)
                    .frame(width: 21, height: 21)
                    .cardShadow(scheme: colorScheme)
                    .offset(x: handleXOffset)
                
            } //: ZStack
            .frame(width: 52, height: 29)
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            
        } //: Button
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(AccessibilityLabels.slideToggle.rawValue)
    }
    
    // MARK: - Actions
    func didTapToggle() {
        withAnimation(.spring()) {
            isOn.toggle()
        }
    }
}

// MARK: - Preview
struct SlideToggleView_Previews: PreviewProvider {
    static var previews: some View {
        SlideToggleView(isOn: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
