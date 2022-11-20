//
//  DividerView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct DividerView: View {
    // MARK: - Props
    var color: Colors = .onSurfaceDark2
    
    // MARK: - UI
    var body: some View {
        Rectangle()
            .fillMaxWidth()
            .frame(height: 1)
            .foregroundColor(color.color)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DividerView_Previews: PreviewProvider {
    static var previews: some View {
        DividerView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
