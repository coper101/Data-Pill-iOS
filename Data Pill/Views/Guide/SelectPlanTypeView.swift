//
//  SelectPlanTypeView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct PlanSample {
    let name: String
    let amount: Int
    let price: Int
    let tint: Colors
}

struct PlanSampleView: View {
    // MARK: - Props
    var plan: PlanSample
    
    // MARK: - UI
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Colors.shadow.color)
                .frame(width: 180, height: 224)
                .offset(x: 13, y: 12)
            
            VStack(spacing: 0) {
                                            
                // MARK: PLAN NAME
                Text(plan.name.uppercased())
                    .textStyle(
                        foregroundColor: plan.tint,
                        font: .bold,
                        size: 16
                    )
                    .padding(.top, 16)
                
                Spacer()
                
                // MARK: AMOUNT
                HStack(alignment: .bottom, spacing: 6) {
                    
                    Text("\(plan.amount)")
                        .textStyle(
                            foregroundColor: plan.tint,
                            font: .bold,
                            size: 38
                        )
                    
                    Text("GB")
                        .textStyle(
                            foregroundColor: plan.tint,
                            font: .bold,
                            size: 28
                        )
                        .alignmentGuide(.bottom) { $0.height + 2}
                    
                } //: HStack
                
                // MARK: PRICE
                Text("$\(plan.price) / month")
                    .textStyle(
                        foregroundColor: plan.tint,
                        font: .semibold,
                        size: 18
                    )
                    .padding(.top, 16)
                
                Spacer()
                
            } //: VStack
            .frame(width: 180, height: 218)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
        } //: ZStack
        .frame(width: 180 + 30, height: 224 + 30)
    }
    
    // MARK: - Actions
}


struct SelectPlanTypeView: View {
    // MARK: - Props
    var planAction: Action
    var nonPlanAction: Action
    
    let planSamples: [PlanSample] = [
        .init(
            name: "Basic",
            amount: 10,
            price: 10,
            tint: .secondaryGreen
        ),
        .init(
            name: "Pro",
            amount: 25,
            price: 15,
            tint: .secondaryOrange
        ),
        .init(
            name: "Premium",
            amount: 50,
            price: 25,
            tint: .secondaryBlue
        )
    ]
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 28
        ) {
            
            // MARK: TITLE
            Text(
                "Do you have a Data Plan?",
                comment: "Prompt user to select if they have a data plan in User Guide"
            )
            .textStyle(
                foregroundColor: .onSecondary,
                font: .semibold,
                size: 22
            )
            .padding(.horizontal, 28)
            
            // MARK: ILLUSTRATIONS
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 10) {
                    
                    ForEach(planSamples, id: \.name) { plan in
                        
                        PlanSampleView(plan: plan)
                    }
                    
                } //: HStack
                .padding(.horizontal, 12)
                
            } //: ScrollView
                        
            // MARK: ACTIONS
            Spacer(minLength: 0)
            
            HStack(spacing: 18) {
                
                LargeButtonView(
                    title: "Yep",
                    hasOutline: true,
                    id: "Yep",
                    action: planAction
                )
                
                LargeButtonView(
                    title: "Nope",
                    id: "Nope",
                    action: nonPlanAction
                )

            } //: VStack
            .fillMaxWidth()
            .padding(.horizontal, 28)
            
        } //: VStack
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
        .padding(.vertical, 21)
        .background(Colors.secondaryBlue.color)
    }
}
