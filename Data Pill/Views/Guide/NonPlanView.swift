//
//  NonPlanView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct NonPlanView: View {
    // MARK: - Props
    var startAction: Action
    
    @State private var isPlanActive = false
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 38
        ) {
            // MARK: DESCRIPTION
            VStack(
                alignment: .leading,
                spacing: 28
            ) {
                
                Text(
                    "Data Pill will just monitor and track your daily mobile data.",
                    comment: "The description for Non Data Plan selection"
                )
                
                Text(
                    "If you ever subscribe to a plan in the future, toggle Data Plan.",
                    comment: "The description for Non Data Plan selection"
                )
                    
            } //: VStack
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
                    .frame(height: isPlanActive ? 152 : 56)
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
                    isPlanActive: $isPlanActive,
                    dataAmountValue: .constant("20"),
                    dataAmount: 20,
                    activeColor: .secondaryGreen,
                    plusDataAction: {},
                    minusDataAction: {},
                    didChangePlusStepperValue: { _ in },
                    didChangeMinusStepperValue: { _ in }
                )
                .disabled(true)
            }
            .padding(.top, 16)
           
            // MARK: ACTION
            Spacer()

            StartButtonView(action: startAction)
            
        } //: VStack
        .padding(.horizontal, 28)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isPlanActive = true
                }
            }
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct NonPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NonPlanView(startAction: {})
            .previewLayout(.sizeThatFits)
            .padding(.vertical, 21)
            .background(Colors.secondaryBlue.color)
    }
}
