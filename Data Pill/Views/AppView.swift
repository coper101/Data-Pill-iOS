//
//  AppView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct AppView: View {
    // MARK: - Props
    @EnvironmentObject var appState: AppState
            
    
    var width: CGFloat {
        Dimensions.Screen.width * 0.45
    }
    
    var height: CGFloat {
        (Dimensions.Screen.width * 0.45) * 2.26
    }
    
    // MARK: - UI
    var body: some View {
        ZStack(alignment: .top) {
            
            // Layer 1:
            BasicInfoView()
                .fillMaxSize(alignment: .top)
                .background(Colors.background.color)
                .blur(radius: appState.isBlurShown ? 15 : 0)
                .allowsHitTesting(!appState.isBlurShown)
                .zIndex(0)
            
            // Layer 2:
            if appState.isDataPlanEditing {
                VStack(alignment: .trailing, spacing: 50) {
                    DataPlanCardView(
                        editType: appState.editDataPlanType,
                        startDate: appState.startDate,
                        endDate: appState.endDate,
                        numberOfdays: appState.numOfDaysOfPlan,
                        periodAction: {},
                        dataAmountAction: {}
                    )
                    SaveButtonView(action: didTapSave)
                        .alignmentGuide(.trailing) { $0.width + 10 }
                }
                .zIndex(1)
                .padding(.horizontal, 21)
                .padding(.top, height + 21 * 2)
            }
            
//            // Layer 3:
//            if appState.isDatePickerShownPlan {
//                DatePicker(
//                    selection: .constant(appState.startDate),
//                    displayedComponents: .date,
//                    label: {}
//                )
//                .labelsHidden()
//                .padding()
//                .frame(width: Dimensions.Screen.width * 0.85)
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .datePickerStyle(.graphical)
//                .zIndex(3)
//            }
//
//            // Layer 4:
//            if appState.isDatePickerShownDataPlan {
//                DatePicker(
//                    selection: .constant(appState.startDate),
//                    displayedComponents: .date,
//                    label: {}
//                )
//                .labelsHidden()
//                .padding()
//                .frame(width: Dimensions.Screen.width * 0.85)
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .datePickerStyle(.graphical)
//                .zIndex(4)
//            }
//
            
            // Layer 5:
            if appState.isHistoryShown {
                HistoryView(
                    days: appState.days,
                    weekData: appState.weeksData,
                    dataLimitPerDay: appState.dataLimitPerDay,
                    closeAction: didTapClose
                )
                .zIndex(1)
            }
            
        } //: ZStack
    }
    
    // MARK: - Actions
    func didTapClose() {
        withAnimation {
            appState.isBlurShown = false
            appState.isHistoryShown = false
        }
    }
    
    func didTapSave() {
        withAnimation {
            appState.isBlurShown = false
            appState.isDataPlanEditing = false
        }
    }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .previewLayout(.sizeThatFits)
            .environmentObject(AppState())
    }
}
