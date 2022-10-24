//
//  NavRowView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct NavRowView: View {
    // MARK: - Props
    var title: String
    var subtitle: String
    var action: () -> Void
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                
                // Col 1: TITLE
                Text(title)
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 15,
                        lineLimit: 1
                    )
                
                // Col 2: SUBTITLE
                Text(subtitle)
                    .textStyle(
                        foregroundColor: .onSurfaceLight,
                        font: .semibold,
                        size: 15,
                        lineLimit: 1
                    )
                
                // Col 3: NAV ICON
                Spacer()
                Icons.navigateIcon.image
                    .resizable()
                    .size(length: 26)
                    .foregroundColor(
                        Colors.onSurfaceLight2.color
                    )
                 
            } //: HStack
            .frame(height: 37)
            .contentShape(Rectangle())
            
        } //: Button
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct NavRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavRowView(
            title: "12 SEP - 10 OCT",
            subtitle: "30 Days",
            action: {}
        )
        .background(Colors.surface.color)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
