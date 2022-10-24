//
//  PillGroupView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct PillGroupView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions

    var spaceInBetween: CGFloat = 21
    var paddingHorizontal: CGFloat = 21
    
    var width: CGFloat {
        dimensions.screen.width * 0.45
    }
    var height: CGFloat {
        (dimensions.screen.width * 0.45) * 2.26
    }
    
    var todaysDate: Date {
        appViewModel.todaysData.date ?? .init()
    }
    
    var color: Colors {
        let weekday = todaysDate.toDateComp().weekday ?? 1
        return appViewModel.days[weekday - 1].color
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
                Button(action: dataPillAction) {
                    PillView(
                        color: color,
                        percentage: appViewModel.dateUsedInPercentage,
                        date: todaysDate,
                        usageType: appViewModel.usageType
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
                            usedData: appViewModel.usedData,
                            maxData: appViewModel.maxData,
                            dataUnit: appViewModel.unit,
                            width: cardWidth,
                            height: 0.34 * cardHeight
                        )
                        
                        // USAGE TOGGLE
                        UsageCardView(
                            selectedItem: $appViewModel.usageType,
                            width: cardWidth,
                            height: 0.4 * cardHeight
                        )
                        
                        // NOTIF TOGGLE
                        NotifCardView(
                            isTurnedOn: $appViewModel.isNotifOn,
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
                startDate: appViewModel.startDate,
                endDate: appViewModel.endDate,
                numberOfdays: appViewModel.numOfDaysOfPlan,
                periodAction: planPeriodAction,
                dataAmountAction: planAmountAction,
                startPeriodAction: {},
                endPeriodAction: {},
                dataAmountValue: $appViewModel.dataValue,
                plusDataAction: {},
                minusDataAction: {}
            )
            
            // DATA LIMIT
            HStack(spacing: 21) {
                
                DataPlanLimitView(
                    dataLimitValue: $appViewModel.dataLimitValue,
                    dataAmount: appViewModel.dataLimit,
                    isEditing: false,
                    usageType: .plan,
                    editAction: planLimitAction,
                    minusDataAction: {},
                    plusDataAction: {}
                )
                
                DataPlanLimitView(
                    dataLimitValue: $appViewModel.dataLimitPerDayValue,
                    dataAmount: appViewModel.dataLimitPerDay,
                    isEditing: false,
                    usageType: .daily,
                    editAction: planLimitPerDayAction,
                    minusDataAction: {},
                    plusDataAction: {}
                )
                
            } //: HStack
            .frame(height: 145)
            
        } //: VStack
        .padding(.top, dimensions.topBarHeight)
        .scrollSnap(
            contentHeight: dimensions.topBarHeight + height + 152 + 145 + (spaceInBetween * 2),
            screenHeight: dimensions.screen.height
        )
        .padding(.horizontal, paddingHorizontal)
        .padding(.vertical, paddingHorizontal)
    }
    
    // MARK: - Actions
    func dataPillAction() {
        withAnimation {
            appViewModel.didTapOpenHistory()
        }
    }
    
    func planPeriodAction() {
        withAnimation {
            appViewModel.didTapPeriod()
        }
    }
    
    func planAmountAction() {
        withAnimation {
            appViewModel.didTapAmount()
        }
    }
    
    func planLimitAction() {
        withAnimation {
            appViewModel.didTapLimit()
        }
    }
    
    func planLimitPerDayAction() {
        withAnimation {
            appViewModel.didTapLimitPerDay()
        }
    }
    
}

// MARK: - Preview
struct PillGroupView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel {
        let _ = MockNetworkDataRepository(totalUsedData: 1_000)
        let dataUsageRepo = DataUsageFakeRepository(thisWeeksData: weeksDataSample)
        let _ = MockAppDataRepository()
        return AppViewModel.init(
//            appDataRepository: appDataRepo,
            dataUsageRepository: dataUsageRepo
//            networkDataRepository: networkDataRepo
        )
    }
    
    static var previews: some View {
        PillGroupView()
            .previewLayout(.sizeThatFits)
            .environmentObject(appViewModel)
    }
}
