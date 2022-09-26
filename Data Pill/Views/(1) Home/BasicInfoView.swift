//
//  BasicInfoView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct BasicInfoView: View {
    // MARK: - Props
    @EnvironmentObject var appState: AppState
    
    var spaceInBetween: CGFloat = 21
    var paddingHorizontal: CGFloat = 21
    
    var width: CGFloat {
        Dimensions.Screen.width * 0.45
    }
    var height: CGFloat {
        (Dimensions.Screen.width * 0.45) * 2.26
    }
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: spaceInBetween) {
            
            // MARK: - Row 1:
            HStack(
                alignment: .top,
                spacing: spaceInBetween
            ) {
                
                // Col 1: DATA PILL
                Button(action: didTapDataPill) {
                    PillView(
                        color: .secondaryBlue,
                        percentage: appState.todaysData.dataUsed.toPerc(max: appState.dataLimitPerDay),
                        date: appState.todaysData.date
                    )
                }
                .buttonStyle(
                    ScaleButtonStyle(minScale: 0.9)
                )
                
                // Col 2: INFO & CONTROLS
                GeometryReader { reader in
                    
                    let cardWidth = reader.size.width - paddingHorizontal - spaceInBetween
                    let cardHeight = reader.size.height
                    
                    VStack(spacing: 0) {
                        
                        // USED
                        UsedCardView(
                            width: cardWidth,
                            usedData: appState.todaysData.dataUsed,
                            maxData: appState.dataLimitPerDay,
                            height: 0.34 * cardHeight
                        )
                        
                        // USAGE TOGGLE
                        UsageCardView(
                            selectedItem: $appState.selectedItem,
                            width: cardWidth,
                            height: 0.4 * cardHeight
                        )
                        
                        // NOTIF TOGGLE
                        NotifCardView(
                            isTurnedOn: $appState.isNotifOn,
                            width: cardWidth,
                            height: 0.25 * cardHeight
                        )
                        
                    } //: VStack
                    .fillMaxSize()
                    
                } //: GeometryReader

            } //: HStack
            .frame(height: height)
            
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
            
        } //: VStack
        .padding(.horizontal, paddingHorizontal)
        .padding(.vertical, paddingHorizontal)
    }
    
    // MARK: - Actions
    func didTapDataPill() {
        withAnimation {
            appState.isBlurShown = true
            appState.isHistoryShown = true
        }
    }
    
    func didTapPlanPeriod() {
        withAnimation {
            appState.isBlurShown = true
            appState.isDataPlanEditing = true
            appState.editDataPlanType = .dataPlan
        }
    }
    
    func didTapPlanAmount() {
        withAnimation {
            appState.isBlurShown = true
            appState.isDataPlanEditing = true
            appState.editDataPlanType = .data
        }
    }
}

// MARK: - Preview
struct BasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BasicInfoView()
            .previewLayout(.sizeThatFits)
            .environmentObject(AppState())
    }
}
