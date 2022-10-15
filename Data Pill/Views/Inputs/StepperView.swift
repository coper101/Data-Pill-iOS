//
//  StepperView.swift
//  Data Pill
//
//  Created by Wind Versi on 15/10/22.
//

import SwiftUI

typealias Action = () -> Void

struct StepperView: View {
    // MARK: - Props
    @Binding var value: String
    var unit: Unit
    var minusAction: Action
    var plusAction: Action
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 10) {
            
            // Col 1: Minus
            StepperButtonView(
                operator: .minus,
                action: minusAction
            )
            
            // Col 2: Value
            TextInputView(
                value: $value,
                unit: unit
            )
            
            // Col 3: Add
            StepperButtonView(
                operator: .plus,
                action: plusAction
            )
            
        } //: HStack
        .fillMaxWidth(alignment: .center)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct StepperView_Previews: PreviewProvider {
    static var previews: some View {
        StepperView(
            value: .constant("100"),
            unit: .gb,
            minusAction: {},
            plusAction: {}
        )
            .previewLayout(.sizeThatFits)
            .padding()
            // .background(Colors.Background)
    }
}
