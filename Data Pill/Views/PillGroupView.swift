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
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Row 1: Top Bar
            TopBarView(
                syncStatus: appViewModel.syncStatus,
                settingsAction: settingsAction
            )
            .padding(.bottom, dimensions.spaceBottomTopBar)
            
            // MARK: - Row 2: Pill Group
            HStack(
                alignment: .center,
                spacing: dimensions.spaceInBetween
            ) {
                
                // Col 1: DATA PILL
                Button(action: dataPillAction) {
                    
                    PillView(
                        color: appViewModel.todaysColor,
                        percentage: appViewModel.dataUsedInPercentage,
                        date: todaysDate,
                        hasLabel: appViewModel.labelsInDaily,
                        usageType: appViewModel.usageType,
                        customSize: .init(
                            width: dimensions.pillWidth,
                            height: dimensions.pillHeight
                        ),
                        isContentShown: !appViewModel.isHistoryShown
                    )
                    
                } //: Button
                .buttonStyle(
                    ScaleButtonStyle(minScale: 0.9)
                )
                .accessibilityIdentifier("pill")
                
                // Col 2: INFO & CONTROLS
                GeometryReader { reader in
                    
                    let cardWidth = reader.size.width - dimensions.horizontalPadding - dimensions.spaceInBetween
                    
                    VStack(spacing: 0) {
                        
                        // USED or LEFT
                        UsedCardView(
                            usedData: appViewModel.usedData,
                            maxData: appViewModel.maxData,
                            fillUsageType: appViewModel.fillUsageType,
                            dataUnit: appViewModel.unit,
                            width: cardWidth
                        )
                        
                        Spacer()
                        
                        // USAGE TOGGLE
                        UsageCardView(
                            selectedItem: $appViewModel.usageType,
                            width: cardWidth,
                            isPlanActive: appViewModel.isPlanActive
                        )
                        
                        Spacer()
                        
                        // AUTO DATA PERIOD TOGGLE
                        AutoPeriodCardView(
                            isAuto: $appViewModel.isPeriodAuto,
                            width: cardWidth,
                            isPlanActive: appViewModel.isPlanActive
                        )
                        
                    } //: VStack
                    .fillMaxSize()
                    
                } //: GeometryReader
                
            } //: HStack
            .frame(height: dimensions.maxPillHeight)
            
            // MARK: - Row 3: Data Plan
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
                dataAmount: appViewModel.dataAmount,
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
            .padding(.top, dimensions.spaceInBetween)
            
            // MARK: - Row 4: Data Limit
            HStack(spacing: dimensions.spaceInBetween) {
                
                if appViewModel.isPlanActive {
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
                }
                
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
            .padding(.top, dimensions.spaceInBetween)
            
        } //: VStack
        .padding(.horizontal, dimensions.horizontalPadding)
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
    
    func settingsAction() {
        appViewModel.showSettings()
    }
}

// MARK: - Preview
struct PillGroupView_Previews: PreviewProvider {
    static var appViewModelPlan: AppViewModel {
        let database = InMemoryLocalDatabase(container: .dataUsage, appGroup: .dataPill)
        let dataRepo = DataUsageRepository(database: database)
        dataRepo.addData(
            date: Calendar.current.startOfDay(for: .init()),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        let model = AppViewModel(dataUsageRepository: dataRepo)
        model.isPlanActive = true
        
        return model
    }
    
    static var appViewModelNonPlan: AppViewModel {
        let database = InMemoryLocalDatabase(container: .dataUsage, appGroup: .dataPill)
        let dataRepo = DataUsageRepository(database: database)
        dataRepo.addData(
            date: Calendar.current.startOfDay(for: .init()),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        let model = AppViewModel(dataUsageRepository: dataRepo)
        model.isPlanActive = false
        
        return model
    }
    
    static var previews: some View {
        Group {
            
            PillGroupView()
                .environmentObject(appViewModelPlan)
                .previewDisplayName("Plan")
            
            PillGroupView()
                .environmentObject(appViewModelNonPlan)
                .previewDisplayName("Non-Plan")
            
        }
        .previewLayout(.sizeThatFits)
    }
}
