//
//  NonPlanView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct NonPlanView: View {
    // MARK: - Props
    @State private var titleOpacity = 0.2
    @State private var descriptionOpacity = 0.2
    @State private var buttonOpacity = 0.5
    @State private var planCardOpacity = 0.5
    @State private var isPlanActive = false
    
    var startAction: Action
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 28
        ) {
            
            // Row 1: TITLE SELECTION
            Text("Nope.")
                .textStyle(
                    foregroundColor: .onBackground,
                    font: .semibold,
                    size: 20
                )
                .opacity(titleOpacity)
                .animation(
                    .easeIn(duration: 0.5),
                    value: titleOpacity
                )
            
            // Row 2: DESCRIPTION
            VStack(
                alignment: .leading,
                spacing: 19
            ) {
                
                Text("Data Pill will just monitor and track your daily mobile data.")
                
                Text("If you ever subscribe to a plan in the future, toggle Data Plan.")
                    
            } //: VStack
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
                isPlanActive: $isPlanActive,
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                withAnimation(.easeIn(duration: 1.0)) {
                    planCardOpacity = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
                withAnimation {
                    isPlanActive.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
                withAnimation(.easeIn(duration: 1.5)) {
                    buttonOpacity = 1.0
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
    }
}
