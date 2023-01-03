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
    
    var todaysDate: Date {
        appViewModel.todaysData.date ?? .init()
    }
    
    var color: Colors {
        let weekday = todaysDate.toDateComp().weekday ?? 1
        return appViewModel.days[weekday - 1].color
    }
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: dimensions.spaceInBetween) {
            
            // MARK: - Row 1: Pill Group
            HStack(
                alignment: .center,
                spacing: dimensions.spaceInBetween
            ) {
                
                // Col 1: DATA PILL
                Button(action: dataPillAction) {
                    PillView(
                        color: color,
                        percentage: appViewModel.dateUsedInPercentage,
                        date: todaysDate,
                        usageType: appViewModel.usageType,
                        customSize: .init(
                            width: dimensions.pillWidth,
                            height: dimensions.pillHeight
                        ),
                        isContentShown: !appViewModel.isHistoryShown
                    )
                }
                .buttonStyle(
                    ScaleButtonStyle(minScale: 0.9)
                )
                .accessibilityIdentifier("pill")
                
                // Col 2: INFO & CONTROLS
                GeometryReader { reader in
                    
                    let cardWidth = reader.size.width - dimensions.horizontalPadding - dimensions.spaceInBetween
                    
                    VStack(spacing: 0) {
                        
                        // USED
                        UsedCardView(
                            usedData: appViewModel.usedData,
                            maxData: appViewModel.maxData,
                            dataUnit: appViewModel.unit,
                            width: cardWidth
                        )
                        
                        Spacer()
                        
                        // USAGE TOGGLE
                        UsageCardView(
                            selectedItem: $appViewModel.usageType,
                            width: cardWidth
                        )
                        
                        Spacer()
                        
                        // AUTO DATA PERIOD TOGGLE
                        AutoPeriodCardView(
                            isAuto: $appViewModel.isPeriodAuto,
                            width: cardWidth
                        )
                        
                    } //: VStack
                    .fillMaxSize()
                    
                } //: GeometryReader

            } //: HStack
            .frame(height: dimensions.maxPillHeight)
            
            // MARK: - Row 2: Data Plan
            DataPlanCardView(
                startDate: appViewModel.startDate,
                endDate: appViewModel.endDate,
                numberOfdays: appViewModel.numOfDaysOfPlan,
                periodAction: planPeriodAction,
                dataAmountAction: planAmountAction,
                startPeriodAction: {},
                endPeriodAction: {},
                isPlanActive: $appViewModel.isPlanActive,
                dataAmountValue: $appViewModel.dataValue,
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
            
            // MARK: - Row 3: Data Limit
            HStack(spacing: dimensions.spaceInBetween) {
                
                DataPlanLimitView(
                    dataLimitValue: $appViewModel.dataLimitValue,
                    dataAmount: appViewModel.dataLimit,
                    isEditing: false,
                    usageType: .plan,
                    editAction: planLimitAction,
                    minusDataAction: {},
                    plusDataAction: {},
                    didChangePlusStepperValue: { _ in },
                    didChangeMinusStepperValue: { _ in }
                )
                
                DataPlanLimitView(
                    dataLimitValue: $appViewModel.dataLimitPerDayValue,
                    dataAmount: appViewModel.dataLimitPerDay,
                    isEditing: false,
                    usageType: .daily,
                    editAction: planLimitPerDayAction,
                    minusDataAction: {},
                    plusDataAction: {},
                    didChangePlusStepperValue: { _ in },
                    didChangeMinusStepperValue: { _ in }
                )
                
            } //: HStack
            .frame(height: dimensions.planLimitCardsHeight)
            
        } //: VStack
        .padding(.horizontal, dimensions.horizontalPadding)
        .padding(.vertical, dimensions.horizontalPadding)
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
    static var previews: some View {
        PillGroupView()
            .previewLayout(.sizeThatFits)
            .environmentObject(AppViewModel())
    }
}
