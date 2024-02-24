//
//  KeyboardToolbarView.swift
//  Data Pill
//
//  Created by Wind Versi on 4/2/24.
//

import SwiftUI

struct KeyboardToolbarView: View {
    // MARK: - Props
    var doneAction: Action
    
    // MARK: - UI
    var content: some View {
        HStack(spacing: 0) {
            
            Spacer()
            
            Button(action: doneAction) {
                
                Text("Done")
                    .textStyle(
                        foregroundColor: .secondaryBlue,
                        font: .bold,
                        size: 16,
                        lineLimit: nil
                    )
                
            } //: Button
            .frame(width: 64, height: 48)
            
        } //: HStack
        .background(Colors.background.color)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            DividerView()
            
            content
            
        } //: VStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct KeyboardToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardToolbarView(doneAction: {})
            .previewLayout(.sizeThatFits)
            .background(Colors.background.color)
            .padding()
    }
}
