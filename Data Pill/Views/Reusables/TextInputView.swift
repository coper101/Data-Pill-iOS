//
//  TextInputView.swift
//  Data Pill
//
//  Created by Wind Versi on 1/10/22.
//

import SwiftUI

enum Unit: String {
    case gb = "GB"
    case mb = "MB"
}

struct TextInputView: View {
    // MARK: - Props
    @Binding var data: String
    var unit: Unit = .gb
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 4) {
            
            // Col 1: INPUT
            TextField("", text: $data)
                .multilineTextAlignment(.trailing)
                .frame(width: 46)
            
            // Col 2: UNIT
            Text(unit.rawValue)
                .frame(width: 50, alignment: .leading)
            
        } //: HStack
        .textStyle(
            foregroundColor: .onSurface,
            font: .semibold,
            size: 22
        )
        .frame(height: 53)
        .foregroundColor(Colors.onSurface.color)
        .background(Colors.onSurfaceDark.color)
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct TextInputView_Previews: PreviewProvider {
    static var previews: some View {
        TextInputView(data: .constant("10"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
