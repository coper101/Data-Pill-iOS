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
                action: {},
                closeAction: {}
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.6)
                    .onEnded(longPressedMinusAction)
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded(pressedMinusAction)
            )
            
            // Col 2: VALUE
            TextInputView(
                value: $value,
                unit: unit
            )
            .accessibilityLabel(AccessibilityLabels.valueInput.rawValue)
            
            // Col 3: PLUS
            StepperButtonView(
                showStepperValue: hasLongPressedPlus,
                onChangeStepperValue: onChangeAddStepperValue,
                operator: .plus,
                action: {},
                closeAction: {}
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.6)
                    .onEnded(longPressedPlusAction)
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded(pressedPlusAction)
            )
            
        } //: HStack
        .frame(height: 53)
    }
    
    // MARK: - Actions
    
    // MARK: Minus
    func onChangeMinusStepperValue(value: Double) {
        minusStepperValueAction(value)
        hasLongPressedMinus = false
    }
    
    func pressedMinusAction() {
        if hasLongPressedMinus {
            hasLongPressedMinus = false
            return
        }
        minusAction()
    }
    
    func longPressedMinusAction(value: Bool) {
        hasLongPressedMinus = true
    }
    
    // MARK: Plus
    func onChangeAddStepperValue(value: Double) {
        plusStepperValueAction(value)
        hasLongPressedPlus = false
    }
    
    func pressedPlusAction() {
        if hasLongPressedPlus {
            hasLongPressedPlus = false
            return
        }
        plusAction()
    }
    
    func longPressedPlusAction(value: Bool) {
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
