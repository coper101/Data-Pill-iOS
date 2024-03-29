//
//  StepperButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 1/10/22.
//

import SwiftUI

enum Operator: String, Identifiable, CaseIterable {
    case minus
    case plus
    var id: String {
        return self.rawValue
    }
}

struct StepperButtonView: View {
    // MARK: - Props
    var showStepperValue: Bool
    var onChangeStepperValue: (Double) -> Void
    var `operator`: Operator
    var action: Action
    var closeAction: Action
    
    var icon: Icons {
        `operator` == .plus ?
            Icons.plusIcon :
            Icons.minusIcon
    }
    
    var stepperValues: [StepperValue] {
        [
            .init(
                title: "1",
                value: 1.0,
                action: {
                    self.onChangeStepperValue(1.0)
                }
            ),
            .init(
                title: "0.1",
                value: 0.1,
                action: {
                    self.onChangeStepperValue(0.1)
                }
            )
        ]
    }
    
    // MARK: - UI
    var body: some View {
        ZStack {
            
            // Layer 1: OPERATOR +, -
            Group {
                
                if showStepperValue {
                    
                    Button(action: closeAction) {
                        
                        Icons.plusIcon.image
                            .resizable()
                            .rotationEffect(.init(degrees: showStepperValue ? 45 : 0))
                            .accessibilityLabel(String("\(`operator`.id) / Rotated Plus Icon"))
                            .transition(.identity)
                        
                    } //: Button
                    
                } else {
                    
                    Button(action: didTapOperator) {
                        
                        icon.image
                            .resizable()
                            .transition(.identity)
                        
                    } //: Button
                    
                } //: if-else
                
            } //: Group
            .padding(15)
            .frame(width: 57, height: 57)
            .foregroundColor(Colors.onSurface.color)
            .background(Colors.onSurfaceDark.color)
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .buttonStyle(ScaleButtonStyle())

            // Layer 2: CUSTOM VALUES +/- 0.1, +/- 1
            if showStepperValue {
                StepperValueView(stepperValues: stepperValues)
                    .offset(y: -95)
                    .popSlide(endOffsetY: 30)
            }
            
        } //: VStack
        .animation(.popBounce(), value: showStepperValue)
    }
    
    // MARK: - Actions
    func didTapOperator() {
        guard !showStepperValue else {
            return
        }
        action()
    }
}

// MARK: - Preview
struct StepperButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(Operator.allCases) { `operator` in
            StepperButtonView(
                showStepperValue: true,
                onChangeStepperValue: { _ in },
                operator: `operator`,
                action: {},
                closeAction: {}
            )
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName(`operator`.rawValue)
        }
    }
}
