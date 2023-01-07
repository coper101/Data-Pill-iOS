//
//  DataPlanLimitView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

struct DataPlanLimitView: View {
    // MARK: - Props
    @Binding var dataLimitValue: String
    var dataAmount: Double
    var dataUnit: Unit = .gb
    var isEditing: Bool
    var usageType: ToggleItem
    var editAction: Action
    
    var minusDataAction: Action
    var plusDataAction: Action
    var didChangePlusStepperValue: StepperValueAction
    var didChangeMinusStepperValue: StepperValueAction
    
    var subtitle: String {
        switch usageType {
        case .plan:
            return !isEditing ?
                "Plan\nLimit" :
                "Plan Limit"
        case .daily:
            return !isEditing ?
                "Daily\nLimit" :
                "Daily Limit"
        }
    }
    
    var textColor: Colors {
        !isEditing ?
            .onSurfaceLight2 :
            .onBackground
    }
    
    // MARK: - UI
    var content: some View {
        HStack(
            alignment: .bottom,
            spacing: 2
        ) {
            // Col 1: AMOUNT
            Text(dataAmount.toIntOrDp())
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 30,
                    lineLimit: 1
                )
                .accessibilityLabel("limitAmount")
            
            // Col 2: UNIT
            Text(dataUnit.rawValue)
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 18,
                    lineLimit: 1
                )
                .alignmentGuide(.bottom) { $0.height + 3 }
                .accessibilityLabel("limitUnit")
            
        } //: HStack
        .fillMaxSize()
    }
    
    var body: some View {
        ItemCardView(
            style: .mini2,
            subtitle: subtitle,
            navigateAction: editAction,
            hasBackground: true,
            hasBlur: false,
            backgroundColor: isEditing ? .background : .surface,
            isToggleOn: .constant(false),
            hasNavigateIcon: !isEditing,
            textColor: textColor
        ) {
            
            if !isEditing {
                content
            } else {
                StepperView(
                    value: $dataLimitValue,
                    unit: .gb,
                    minusAction: minusDataAction,
                    plusAction: plusDataAction,
                    plusStepperValueAction: didChangePlusStepperValue,
                    minusStepperValueAction: didChangeMinusStepperValue
                )
                .fillMaxWidth()
                .padding(.bottom, 34)
                .padding(.top, 16)
            }
            
        } //: ItemCardView
        .accessibilityIdentifier(usageType == .plan ? "planLimit" : "dailyLimit")
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DataPlanLimitView_Previews: PreviewProvider {
    static var previews: some View {
        DataPlanLimitView(
            dataLimitValue: .constant("9"),
            dataAmount: 9.0,
            isEditing: false,
            usageType: .daily,
            editAction: {},
            minusDataAction: {},
            plusDataAction: {},
            didChangePlusStepperValue: { _ in },
            didChangeMinusStepperValue: { _ in }
        )
            .frame(width: 175, height: 145)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Info")
            .padding()
            .background(Color.green)
        
        DataPlanLimitView(
            dataLimitValue: .constant("9"),
            dataAmount: 9.0,
            isEditing: true,
            usageType: .daily,
            editAction: {},
            minusDataAction: {},
            plusDataAction: {},
            didChangePlusStepperValue: { _ in },
            didChangeMinusStepperValue: { _ in }
        )
            .fillMaxWidth()
            .frame(height: 145)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Edit")
            .padding()
            .background(Color.green)
    }
}
