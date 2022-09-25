//
//  AppView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct AppView: View {
    // MARK: - Props
    @EnvironmentObject var appState: AppState
    
    @State var isDatePickerShown = true
    
    var blurRadiusHistory: CGFloat {
        appState.isBlurVisibleHistory ?
            15 : 0
    }
    
    var blurRadiusDataPlan: CGFloat {
        appState.isBlurVisibleDataPlan ?
            15 : 0
    }
    
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
                .background(Colors.background.color)
                .blur(radius: blurRadiusHistory)
                .allowsHitTesting(!appState.isBlurVisibleHistory)
                .zIndex(0)
            
            // Layer 2
            VStack(spacing: 21) {
                
                // DATA PLAN
                DataPlanCardView(
                    startDate: appState.startDate,
                    endDate: appState.endDate,
                    numberOfdays: appState.numOfDaysOfPlan,
                    periodAction: didTapPlanPeriod,
                    dataAmountAction: didTapPlanAmount
                )
                
                // DATA LIMIT
                HStack(spacing: 21) {
                    
                    DataPlanLimitView(
                        dataLimitAmount: appState.dataLimit
                    )
                    
                    DailyLimitView(
                        dataLimitAmount: appState.dataLimitPerDay
                    )
                    
                } //: HStack
                .frame(height: 145)
                
            }
            .padding(.horizontal, 21)
            .padding(.top, height + 21 * 2)
            .blur(radius: blurRadiusDataPlan)
            .zIndex(1)
            
            // Layer 3:
            if appState.isHistoryShown {
                HistoryView(
                    days: appState.days,
                    weekData: appState.weeksData,
                    dataLimitPerDay: appState.dataLimitPerDay,
                    closeAction: didTapClose
                )
                .zIndex(2)
            }
            
            // Layer 4:
            if isDatePickerShown {
                DatePicker(
                    selection: .constant(appState.startDate),
                    displayedComponents: .date,
                    label: {}
                )
                .labelsHidden()
                .padding()
                .frame(width: Dimensions.Screen.width * 0.85)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .datePickerStyle(.graphical)
                .zIndex(3)
            }
            
        } //: ZStack
        .fillMaxSize()
    }
    
    // MARK: - Actions
    func didTapClose() {
        withAnimation {
            appState.isBlurVisibleHistory = false
            appState.isBlurVisibleDataPlan = false
            appState.isHistoryShown = false
        }
    }
    
    func didTapPlanPeriod() {
        withAnimation {
            appState.isBlurVisibleDataPlan = true
        }
    }
    
    func didTapPlanAmount() {
        withAnimation {
            appState.isBlurVisibleDataPlan = true
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
