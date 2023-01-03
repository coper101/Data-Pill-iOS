//
//  GuideView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

enum Step {
    case selectPlan
    case plan
    case nonPlan
}

struct GuideView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @State var step = Step.selectPlan
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment:  .leading,
            spacing: 0
        ) {
            
            Text("Get Started")
                .textStyle(
                    foregroundColor: Colors.onBackground,
                    font: .semibold,
                    size: 28
                )
                .padding(.top, 31)
                .padding(.bottom, 42)
            
            switch step {
            case .selectPlan:
                SelectPlanTypeView(
                    planAction: didTapPlan,
                    nonPlanAction: didTapNonPlan
                )
            case .plan:
                PlanView(startAction: didTapStartPlan)
            case .nonPlan:
                NonPlanView(startAction: didTapStartNonPlan)
            }
            
        } //: VStack
        .padding(.bottom, 24)
        .padding(.horizontal, 28)
        .fillMaxWidth()
    }
    
    // MARK: - Actions
    func didTapPlan() {
        withAnimation {
            step = .plan
        }
    }
    
    func didTapNonPlan() {
        withAnimation {
            step = .nonPlan
        }
    }
    
    func didTapStartPlan() {
        appViewModel.setGuideShown()
        appViewModel.toggleDataPlan(true)
    }
    
    func didTapStartNonPlan() {
        appViewModel.setGuideShown()
        appViewModel.toggleDataPlan(false)
    }
}

// MARK: - Preview
struct GuideView_Previews: PreviewProvider {
    static var previews: some View {
        GuideView()
            .previewLayout(.sizeThatFits)
            .environmentObject(AppViewModel())
    }
}
