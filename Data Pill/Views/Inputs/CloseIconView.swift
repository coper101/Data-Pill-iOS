//
//  CloseIconView.swift
//  Data Pill
//
//  Created by Wind Versi on 25/9/22.
//

import SwiftUI

struct CloseIconView: View {
    // MARK: - Props
    var action: () -> Void
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Colors.onBackgroundLight.color)
                .frame(width: 30, height: 30)
                .overlay(
                    Icons.closeIcon.image.resizable()
                        .foregroundColor(Colors.background.color)
                        .frame(width: 20, height: 20)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct CloseIconView_Previews: PreviewProvider {
    static var previews: some View {
        CloseIconView(action: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
