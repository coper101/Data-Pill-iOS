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
    var editAction: () -> Void
    var minusDataAction: () -> Void
    var plusDataAction: () -> Void
    
    var subtitle: String {
        switch usageType {
        case .plan:
            return !isEditing ?
                "Data Plan\nLimit" :
                "Data Plan Limit"
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
    var editingContent: some View {
        HStack(spacing: 10) {
            StepperButtonView(
                operator: .minus,
                action: minusDataAction
            )
            TextInputView(
                data: $dataLimitValue,
                unit: dataUnit
            )
            StepperButtonView(
                operator: .plus,
                action: plusDataAction
            )
        } //: VStack
        .fillMaxWidth(alignment: .center)
    }
    
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
            
            // Col 2: UNIT
            Text(dataUnit.rawValue)
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 18,
                    lineLimit: 1
                )
                .alignmentGuide(.bottom) { $0.height + 3 }
            
        } //: HStack
        .fillMaxSize()
    }
    
    var body: some View {
        ItemCardView(
            style: .mini2,
            subtitle: subtitle,
            navigateAction: editAction,
            hasBackground: !isEditing,
            hasNavigateIcon: !isEditing,
            textColor: textColor
        ) {
            
            if !isEditing {
                content
            } else {
                editingContent
                    .padding(.bottom, 20)
            }
            
        } //: ItemCardView
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
            plusDataAction: {}
        )
            .frame(width: 175, height: 145)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Info")
            .padding()
        
        DataPlanLimitView(
            dataLimitValue: .constant("9"),
            dataAmount: 9.0,
            isEditing: true,
            usageType: .daily,
            editAction: {},
            minusDataAction: {},
            plusDataAction: {}
        )
            .fillMaxWidth()
            .frame(height: 145)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Edit")
            .padding()
    }
}
