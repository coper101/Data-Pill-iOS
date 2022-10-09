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
        ScrollView {
            
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
                            percentage: appState.dateUsedInPercentage,
                            date: appState.todaysData.date ?? Date(),
                            usageType: appState.usageType
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
                                usedData: appState.usedData,
                                maxData: appState.maxData,
                                dataUnit: appState.unit,
                                width: cardWidth,
                                height: 0.34 * cardHeight
                            )
                            
                            // USAGE TOGGLE
                            UsageCardView(
                                selectedItem: $appState.usageType,
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
                    dataAmountAction: didTapPlanAmount,
                    startPeriodAction: {},
                    endPeriodAction: {},
                    dataAmountValue: $appState.dataValue,
                    plusDataAction: {},
                    minusDataAction: {}
                )
                
                // DATA LIMIT
                HStack(spacing: 21) {
                    
                    DataPlanLimitView(
                        dataLimitValue: $appState.dataLimitValue,
                        dataAmount: appState.dataLimit,
                        isEditing: false,
                        usageType: .plan,
                        editAction: didTapLimit,
                        minusDataAction: {},
                        plusDataAction: {}
                    )
                    
                    DataPlanLimitView(
                        dataLimitValue: $appState.dataLimitPerDayValue,
                        dataAmount: appState.dataLimitPerDay,
                        isEditing: false,
                        usageType: .daily,
                        editAction: didTapLimitPerDay,
                        minusDataAction: {},
                        plusDataAction: {}
                    )
                    
                } //: HStack
                .frame(height: 145)
                
            } //: VStack
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingHorizontal)
            
        }
    }
    
    // MARK: - Actions
    // Show History
    func didTapDataPill() {
        withAnimation {
            appState.isBlurShown = true
            appState.isHistoryShown = true
        }
    }
    
    // Edit Data Plan
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
    
    // Edit Data Limit
    func didTapLimit() {
        withAnimation {
            appState.isBlurShown = true
            appState.isDataLimitEditing = true
        }
    }
    
    func didTapLimitPerDay() {
        withAnimation {
            appState.isBlurShown = true
            appState.isDataLimitPerDayEditing = true
        }
    }
    
}

// MARK: - Preview
struct BasicInfoView_Previews: PreviewProvider {
    static var appState: AppState {
        let networkDataRepo = NetworkDataFakeRepository(totalUsedData: 1_000)
        let dataUsageRepo = DataUsageFakeRepository(thisWeeksData: weeksDataSample)
        let appDataRepo = AppDataFakeRepository()
        return AppState.init(
//            appDataRepository: appDataRepo,
            dataUsageRepository: dataUsageRepo
//            networkDataRepository: networkDataRepo
        )
    }
    
    static var previews: some View {
        BasicInfoView()
            .previewLayout(.sizeThatFits)
            .environmentObject(appState)
    }
}
