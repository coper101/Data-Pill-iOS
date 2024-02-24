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
    var height: CGFloat = 1
    
    // MARK: - UI
    var body: some View {
        Rectangle()
            .fillMaxWidth()
            .frame(height: height)
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
