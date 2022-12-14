//
//  StepperValueView.swift
//  Data Pill
//
//  Created by Wind Versi on 19/11/22.
//

import SwiftUI

struct StepperValue: Identifiable {
    let title: String
    let value: Double
    let action: Action
    var id: String {
        self.title
    }
}

struct StepperValueView: View {
    // MARK: - Props
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var stepperValues: [StepperValue]
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: 0) {
            
            ForEach(Array(stepperValues.enumerated()), id: \.element.id) { index, element in
                
                Button(action: element.action) {
                    
                    VStack(spacing: 0) {
                        
                        // Row 1: DIVIDER
                        if index > 0  {
                            DividerView(color: .onSurfaceLight2)
                                .padding(.horizontal, 8)
                        }
                        
                        // Row 2: VALUE
                        Text(element.title)
                            .textStyle(
                                foregroundColor: .onSurface,
                                font: .semibold,
                                size: 17
                            )
                            .padding(15)
                        
                    }
                    .frame(width: 57, height: 53)
                    
                } //: Button
                .buttonStyle(ScaleButtonStyle())

            } //: ForEach
            
        } //: VStack
        .background(Colors.onSurfaceDark.color)
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
        .cardShadow(
            radius: 4,
            y: 0,
            opacity: 0.12,
            scheme: colorScheme
        )
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct StepperValueView_Previews: PreviewProvider {
    static var stepperValues: [StepperValue] = [
        .init(
            title: "1",
            value: 1.0,
            action: {}
        ),
        .init(
            title: "0.1",
            value: 0.1,
            action: {}
        )
    ]
    
    static var previews: some View {
        StepperValueView(stepperValues: stepperValues)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
