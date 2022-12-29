//
//  StepperView.swift
//  Data Pill
//
//  Created by Wind Versi on 15/10/22.
//

import SwiftUI

struct StepperView: View {
    // MARK: - Props
    @State private var hasLongPressedPlus: Bool = false
    @State private var hasLongPressedMinus: Bool = false
    @Binding var value: String
    
    var unit: Unit
    var minusAction: Action
    var plusAction: Action
    
    var plusStepperValueAction: StepperValueAction
    var minusStepperValueAction: StepperValueAction
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 10) {
            
            // Col 1: MINUS
            StepperButtonView(
                showStepperValue: hasLongPressedMinus,
                onChangeStepperValue: onChangeMinusStepperValue,
                operator: .minus,
                action: minusAction,
                closeAction: closeAction
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded(longPressedMinusAction)
            )
            
            // Col 2: VALUE
            TextInputView(
                value: $value,
                unit: unit
            )
            .accessibilityLabel("valueInput")
            
            // Col 3: PLUS
            StepperButtonView(
                showStepperValue: hasLongPressedPlus,
                onChangeStepperValue: onChangeAddStepperValue,
                operator: .plus,
                action: plusAction,
                closeAction: closeAction
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded(longPressedPlusAction)
            )
            
        } //: HStack
        .frame(height: 53)
    }
    
    // MARK: - Actions
    
    func closeAction() {
        hasLongPressedPlus = false
        hasLongPressedMinus = false
    }
    
    // MARK: Minus
    func onChangeMinusStepperValue(value: Double) {
        minusStepperValueAction(value)
        hasLongPressedMinus = false
    }
    
    func longPressedMinusAction(value: Bool) {
        if hasLongPressedPlus {
            hasLongPressedPlus = false
        }
        hasLongPressedMinus = true
    }
    
    // MARK: Plus
    func onChangeAddStepperValue(value: Double) {
        plusStepperValueAction(value)
        hasLongPressedPlus = false
    }
    
    func longPressedPlusAction(value: Bool) {
        if hasLongPressedMinus {
            hasLongPressedMinus = false
        }
        hasLongPressedPlus = true
    }
}

// MARK: - Preview
struct StepperView_Previews: PreviewProvider {
    static var previews: some View {
        StepperView(
            value: .constant("100"),
            unit: .gb,
            minusAction: {},
            plusAction: {},
            plusStepperValueAction: { _ in },
            minusStepperValueAction: { _ in }
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
