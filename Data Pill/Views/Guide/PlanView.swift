//
//  PlanView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct PlanView: View {
    // MARK: - Props
    @State private var titleOpacity = 0.2
    @State private var descriptionOpacity = 0.2
    @State private var buttonOpacity = 0.5
    @State private var planCardOpacity = 0.2
    
    var startAction: Action

    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 28
        ) {
            
            // Row 1: TITLE SELECTION
            Text(
                "Yep.",
                comment: "Title to indicate the user does have a Data Plan"
            )
                .textStyle(
                    foregroundColor: .onBackground,
                    font: .semibold,
                    size: 20
                )
                .opacity(titleOpacity)
            
            // Row 2: DESCRIPTION
            Text(
                "Set the amount of data in your plan and the period it starts and ends.",
                comment: "A guide message to user on how to set the data plan and period"
            )
            .textStyle(
                foregroundColor: .onBackground,
                font: .semibold,
                size: 20,
                lineLimit: 10,
                lineSpacing: 3
            )
            .opacity(descriptionOpacity)
            
            // Row 3: VISUAL GUIDE
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
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
            .disabled(true)
            .cardShadow(scheme: .light)
            .padding(.top, 16)
            .opacity(planCardOpacity)
            
            // Row 4: ACTION
            Spacer()
            
            ButtonView(
                type: .start,
                fullWidth: true
            ) { _ in
                startAction()
            }
            .fillMaxWidth()
            .opacity(buttonOpacity)
            
        } //: VStack
        .onAppear {
            titleOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    descriptionOpacity = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    planCardOpacity = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.easeIn(duration: 1.0)) {
                    buttonOpacity = 1.0
                }
            }
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView(startAction: {})
            .previewLayout(.sizeThatFits)
    }
}
