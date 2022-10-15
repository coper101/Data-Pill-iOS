//
//  AppView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct AppView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.edgeInsets) var insets: EdgeInset
    @Environment(\.dimensions) var dimensions: Dimensions
    
    var width: CGFloat {
        dimensions.screen.width * 0.45
    }
    
    var height: CGFloat {
        (dimensions.screen.width * 0.45) * 2.26
    }

    // MARK: - UI
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: Layer 0: Basic Info
            PillGroupView()
                .padding(.top, !appViewModel.isBlurShown ? insets.top : 0)
                .fillMaxSize(alignment: .top)
                .blur(radius: appViewModel.isBlurShown ? 15 : 0)
                .allowsHitTesting(!appViewModel.isBlurShown)
                .zIndex(0)
            
            // MARK: Layer 1: Edit Plan
            // another layer of data plan card
            if appViewModel.isDataPlanEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 20
                ) {
                    // Edit Cards
                    DataPlanCardView(
                        editType: appViewModel.editDataPlanType,
                        startDate: appViewModel.startDateValue,
                        endDate: appViewModel.endDateValue,
                        numberOfdays: appViewModel.numOfDaysOfPlanValue,
                        periodAction: {},
                        dataAmountAction: {},
                        startPeriodAction: startPeriodAction,
                        endPeriodAction: endPeriodAction,
                        dataAmountValue: $appViewModel.dataValue,
                        plusDataAction: plusDataAction,
                        minusDataAction: minusDataAction
                    )
                                        
                    // Save Button
                    SaveButtonView(action: saveAction)
                        .alignmentGuide(.trailing) { $0.width + 21 }
                    
                } //: VStack
                .zIndex(1)
                .padding(.horizontal, 21)
                .padding(.top, height + 21 * 2)
            }
            
            // MARK: Layer 2: Edit Limit - Plan
            if appViewModel.isDataLimitEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 20
                ) {
                    // Edit Card
                    DataPlanLimitView(
                        dataLimitValue: $appViewModel.dataLimitValue,
                        dataAmount: appViewModel.dataAmount,
                        isEditing: true,
                        usageType: .plan,
                        editAction: {},
                        minusDataAction: minusLimitAction,
                        plusDataAction: plusLimitAction
                    )
                    .padding(.horizontal, 21)
                    .frame(height: 145)
                    .zIndex(2)
                    
                    // Save Button
                    SaveButtonView(action: saveAction)
                        .alignmentGuide(.trailing) { $0.width + 21 }
                    
                } //: VStack
                .padding(.horizontal, 21)
                .padding(.top, height + 21 * 2)
            }
            
            // MARK: Layer 3: Edit Limit - Daily
            if appViewModel.isDataLimitPerDayEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 20
                ) {
                    // Edit Card
                    DataPlanLimitView(
                        dataLimitValue: $appViewModel.dataLimitPerDayValue,
                        dataAmount: appViewModel.dataLimitPerDay,
                        isEditing: true,
                        usageType: .daily,
                        editAction: {},
                        minusDataAction: minusLimitAction,
                        plusDataAction: plusLimitAction
                    )
                    .padding(.horizontal, 21)
                    .frame(height: 145)
                    .zIndex(3)
                    
                    // Save Button
                    SaveButtonView(action: saveAction)
                        .alignmentGuide(.trailing) { $0.width + 21 }
                    
                } //: VStack
                .padding(.horizontal, 21)
                .padding(.top, height + 21 * 2)
            }
            
            // MARK: Layer 4: Edit Plan - Period
            if appViewModel.isStartDatePickerShown || appViewModel.isEndDatePickerShown {
                Group {
                    
                    if appViewModel.isStartDatePickerShown {
                        
                        DateRangeInputView(
                            selectionDate: $appViewModel.startDateValue,
                            toDateRange: appViewModel.startDateValue.toDateRange()
                        )
                        
                    } else {
                        
                        DateRangeInputView(
                            selectionDate: $appViewModel.endDateValue,
                            fromDateRange: appViewModel.endDateValue.fromDateRange()
                        )
                       
                    } //: if-else
                    
                } //: Group
                .zIndex(4)
                .popBounceEffect(maxOffsetY: 100)
            }
            
            // MARK: Layer 5: OVERVIEW OF USED DATA THIS WEEK
            if appViewModel.isHistoryShown {
                HistoryView(
                    days: appViewModel.days,
                    weekData: appViewModel.thisWeeksData,
                    dataLimitPerDay: appViewModel.dataLimitPerDay,
                    usageType: appViewModel.usageType,
                    closeAction: closeAction
                )
                .zIndex(5)
            }
            
            // MARK: Layer 6: Status Bar Background
            if !appViewModel.isBlurShown {
                Rectangle()
                    .fill(Colors.background.color)
                    .fillMaxWidth()
                    .frame(height: insets.top)
                    .zIndex(6)
            }

        } //: ZStack
        .background(Colors.background.color)
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Actions
    func startPeriodAction() {
        withAnimation(.easeInOut) {
            appViewModel.didTapStartPeriod()
        }
    }
    
    func endPeriodAction() {
        withAnimation(.easeInOut) {
            appViewModel.didTapEndPeriod()
        }
    }

    func plusLimitAction() {
        withAnimation {
            appViewModel.didTapPlusLimit()
        }
    }
    
    func minusLimitAction() {
        withAnimation {
            appViewModel.didTapMinusLimit()
        }
    }
    
    func plusDataAction() {
        withAnimation {
            appViewModel.didTapPlusData()
        }
    }
    
    func minusDataAction() {
        withAnimation {
            appViewModel.didTapMinusData()
        }
    }
    
    func saveAction() {
        withAnimation {
            appViewModel.didTapSave()
        }
    }
    
    func closeAction() {
        withAnimation {
            appViewModel.didTapCloseHistory()
        }
    }

}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .previewLayout(.sizeThatFits)
            .environmentObject(AppViewModel())
    }
}
