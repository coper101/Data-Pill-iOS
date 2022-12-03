//
//  TextInputView.swift
//  Data Pill
//
//  Created by Wind Versi on 1/10/22.
//

import SwiftUI

struct TextInputView: View {
    // MARK: - Props
    @Binding var value: String
    var unit: Unit = .gb
    
    var width: CGFloat {
        .init(18 * value.count)
    }
    
    var unitWidth: CGFloat {
        31 + CGFloat((5 * value.count))
    }
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 4) {
            
            // Col 1: INPUT
            TextField("", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: width)
            
            // Col 2: UNIT
            Text(unit.rawValue)
                .frame(
                    width: unitWidth,
                    alignment: .leading
                )
            
        } //: HStack
        .textStyle(
            foregroundColor: .onSurface,
            font: .semibold,
            size: 22
        )
        .frame(height: 53)
        .frame(maxWidth: 120)
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
    static var numbers = [10, 100, 1000]
    
    static var previews: some View {
        ForEach(numbers, id: \.self) { number in
            let numberString = "\(number)"
            TextInputView(value: .constant(numberString))
                .previewLayout(.sizeThatFits)
                .previewDisplayName("\(numberString.count) Digit")
                .padding()
        }
    }
}
