//
//  PlanView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct PlanView: View {
    // MARK: - Props
    var startAction: Action

    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 32
        ) {
            // MARK: DESCRIPTION
            Text(
                "Set the amount of data in your plan and the period it starts and ends.",
                comment: "A guide message to user on how to set the data plan and period"
            )
            .textStyle(
                foregroundColor: .onSecondary,
                font: .semibold,
                size: 20,
                lineLimit: 10,
                lineSpacing: 5
            )
            
            // MARK: ILLUSTRATION
            ZStack(alignment: .top) {
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Colors.shadowDark.color)
                    .fillMaxWidth()
                    .frame(height: 152)
                    .offset(x: 11, y: 12)
                
                DataPlanCardView(
                    editType: nil,
                    startDate: .init(),
                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: .init())!,
                    numberOfdays: 30,
                    periodAction: {},
                    dataAmountAction: {},
                    startPeriodAction: {},
                    endPeriodAction: {},
                    isPlanActive: .constant(true),
                    dataAmountValue: .constant("20"),
                    dataAmount: 20,
                    activeColor: .secondaryGreen,
                    plusDataAction: {},
                    minusDataAction: {},
                    didChangePlusStepperValue: { _ in },
                    didChangeMinusStepperValue: { _ in }
                )
                .disabled(true)
                
            } //: ZStack
            .padding(.top, 16)
            
            // MARK: ACTION
            Spacer()
            
            StartButtonView(action: startAction)
            
        } //: VStack
        .padding(.horizontal, 28)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView(startAction: {})
            .previewLayout(.sizeThatFits)
            .padding(.vertical, 21)
            .background(Colors.secondaryBlue.color)
    }
}
