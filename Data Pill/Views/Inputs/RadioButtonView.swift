//
//  RadioButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

struct RadioButtonView: View {
    // MARK: - Props
    var isSelected: Bool
    var action: Action
    
    // MARK: - UI
    var content: some View {
        ZStack {
            
            if isSelected {
                
                Circle()
                    .fill(Colors.secondaryBlue.color)
                
            } else {
                
                Circle()
                    .stroke(
                        Colors.onSurfaceLight.color,
                        lineWidth: 0.5
                    )
                
            } //: if-else
             
            if isSelected {
                
                Circle()
                    .fill(Colors.background.color)
                    .padding(8)
                
            } //: if
            
        } //: ZStack
        .frame(width: 30, height: 30)
    }
    
    var body: some View {
        Button(action: action) {
            
           content
            
        } //: Button
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct RadioButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            RadioButtonView(
                isSelected: true,
                action: {}
            )
            .previewDisplayName("Selected")
            
            RadioButtonView(
                isSelected: false,
                action: {}
            )
            .previewDisplayName("Not Selected")

        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
