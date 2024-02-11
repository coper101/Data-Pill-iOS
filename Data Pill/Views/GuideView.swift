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
    @Environment(\.dimensions) var dimensions: Dimensions
    @State var step = Step.selectPlan
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment:  .leading,
            spacing: 0
        ) {
            
            // MARK: HEADER
            Group {
                
                switch step {
                case .selectPlan:
                    Text(
                        "Get Started",
                        comment: "Header for user guide for first time users"
                    )
                case .plan:
                    Text(
                        "Great!",
                        comment: ""
                    )
                case .nonPlan:
                    Text(
                        "No Worries!",
                        comment: ""
                    )
                }
            }
            .textStyle(
                foregroundColor: Colors.onSecondary,
                font: .bold,
                size: 32
            )        
            .padding(.top, 31)
            .padding(.bottom, 42)
            .padding(.horizontal, 28)
            
            // MARK: CONTENT
            switch step {
            case .selectPlan:
                SelectPlanTypeView(
                    planAction: didTapPlan,
                    nonPlanAction: didTapNonPlan
                )
                .transition(.opacity)
            case .plan:
                PlanView(startAction: didTapStartPlan)
                    .transition(.opacity)
            case .nonPlan:
                NonPlanView(startAction: didTapStartNonPlan)
                    .transition(.opacity)
            }
            
        } //: VStack
        .fillMaxWidth()
        .padding(.bottom, 24 + dimensions.insets.bottom)
        .background(
            ZStack {
                
                Colors.secondaryBlue.color
                
                LinearGradient(
                    colors: [Color.white.opacity(0.1), Color.white.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
            } //: ZStack
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Actions
    func didTapPlan() {
        withAnimation(.linear(duration: 0.2)) {
            step = .plan
        }
    }
    
    func didTapNonPlan() {
        withAnimation(.linear(duration: 0.2)) {
            step = .nonPlan
        }
    }
    
    func didTapStartPlan() {
        appViewModel.didTapStartPlan()
    }
    
    func didTapStartNonPlan() {
        appViewModel.didTapStartNonPlan()
    }
}

// MARK: - Preview
struct GuideView_Previews: PreviewProvider {
    static var previews: some View {
        GuideView()
            .previewLayout(.sizeThatFits)
            .environmentObject(TestData.createAppViewModel())
    }
}
