//
//  SelectPlanTypeView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct SelectPlanTypeView: View {
    // MARK: - Props
    @State private var titleOpacity = 0.2
    @State private var descriptionOpacity = 0.2
    @State private var buttonOpacity = 0.5
    
    var planAction: Action
    var nonPlanAction: Action
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 28
        ) {
            
            // Row 1:
            Text("Do you have a Data Plan?")
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
            
            // Row 2:
            Text("A Data Plan is a subscription service where you pay every period to use a fixed amount of mobile data. ")
                .textStyle(
                    foregroundColor: .onBackground,
                    font: .semibold,
                    size: 20,
                    lineLimit: 10,
                    lineSpacing: 3
                )
                .opacity(descriptionOpacity)
                .animation(
                    .easeIn(duration: 0.5),
                    value: descriptionOpacity
                )
            
            // Row 3: SELECTION
            Spacer()
            
            VStack(spacing: 14) {
                
                LargeButtonView(
                    title: "Yep",
                    action: planAction
                )
                
                LargeButtonView(
                    title: "Nope",
                    action: nonPlanAction
                )
                
            } //: VStack
            .fillMaxWidth()
            .opacity(buttonOpacity)
            .animation(
                .easeIn(duration: 0.5),
                value: buttonOpacity
            )
            
        } //: VStack
        .onAppear {
            titleOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                descriptionOpacity = 1.0
                titleOpacity = 0.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                buttonOpacity = 1.0
                descriptionOpacity = 0.2
            }
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SelectPlanTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPlanTypeView(
            planAction: {},
            nonPlanAction: {}
        )
            .previewLayout(.sizeThatFits)
    }
}
