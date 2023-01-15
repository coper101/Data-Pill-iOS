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
    @State private var yepButtonOpacity = 0.2
    @State private var nopeButtonOpacity = 0.2
    
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
            
            // Row 3: SELECTION
            Spacer()
            
            VStack(spacing: 14) {
                
                LargeButtonView(
                    title: "Yep",
                    id: "Yep",
                    action: planAction
                )
                .opacity(yepButtonOpacity)
                
                LargeButtonView(
                    title: "Nope",
                    id: "Nope",
                    action: nonPlanAction
                )
                .opacity(nopeButtonOpacity)

            } //: VStack
            .fillMaxWidth()
            
        } //: VStack
        .onAppear {
            titleOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    descriptionOpacity = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.easeIn(duration: 0.8)) {
                    yepButtonOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 1.0).delay(0.8)) {
                    nopeButtonOpacity = 1.0
                }
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
