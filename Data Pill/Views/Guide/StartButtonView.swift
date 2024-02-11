//
//  StartButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 11/2/24.
//

import SwiftUI

struct StartButtonView: View {
    // MARK: - Props
    var action: Action
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            
            ZStack {
                
                Color.white.opacity(0.05)
                
                Text("Start")
                    .textStyle(
                        foregroundColor: .onSecondary,
                        font: .semibold,
                        size: 22
                    )
                
            } //: ZStack
            .clipShape(
                RoundedRectangle(cornerRadius: 100)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.white, lineWidth: 2)
            )
            .fillMaxWidth()
            .frame(height: 82)
            
        } //: Button
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct StartButtonView_Previews: PreviewProvider {
    static var previews: some View {
        StartButtonView(action: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Colors.secondaryBlue.color)
    }
}
