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
    
    var buttonType: ButtonType {
        (appViewModel.isEndDatePickerShown ||
        appViewModel.isStartDatePickerShown) ?
            .done :
            .save
    }

    // MARK: - UI
    var body: some View {
        ZStack(alignment: .center) {
            
            // MARK: Layer 0: Today's Data Pill
            PillGroupView()
                .padding(.top, insets.top)
                .fillMaxSize(alignment: .top)
                .blur(radius: appViewModel.isBlurShown ? 15 : 0)
                .allowsHitTesting(!appViewModel.isBlurShown)
                .zIndex(0)
            
            // MARK: Layer 2: Edit Plan - Data Amount & Period
            if appViewModel.isDataPlanEditing {

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
                .padding(.horizontal, 21)
                .zIndex(1)
                
            }
            
            // MARK: Layer 3: Edit Limit - Plan
            if appViewModel.isDataLimitEditing {
                
                DataPlanLimitView(
                    dataLimitValue: $appViewModel.dataLimitValue,
                    dataAmount: appViewModel.dataAmount,
                    isEditing: true,
                    usageType: .plan,
                    editAction: {},
                    minusDataAction: minusLimitAction,
                    plusDataAction: plusLimitAction
                )
                .frame(height: 145)
                .padding(.horizontal, 21)
                .zIndex(2)
                
            }
            
            // MARK: Layer 4: Edit Limit - Daily
            if appViewModel.isDataLimitPerDayEditing {
                
                DataPlanLimitView(
                    dataLimitValue: $appViewModel.dataLimitPerDayValue,
                    dataAmount: appViewModel.dataLimitPerDay,
                    isEditing: true,
                    usageType: .daily,
                    editAction: {},
                    minusDataAction: minusLimitAction,
                    plusDataAction: plusLimitAction
                )
                .frame(height: 145)
                .padding(.horizontal, 21)
                .zIndex(3)
            }
            
            
            // MARK: Layer 5: Date Picker
            if appViewModel.isStartDatePickerShown || appViewModel.isEndDatePickerShown {
                Group {
                    
                    if appViewModel.isStartDatePickerShown {
                        
                        DateRangeInputView(
                            selectionDate: $appViewModel.startDateValue,
                            toDateRange: appViewModel.endDateValue.toDateRange()
                        )
                        
                    } else {
                        
                        DateRangeInputView(
                            selectionDate: $appViewModel.endDateValue,
                            fromDateRange: appViewModel.startDateValue.fromDateRange()
                        )
                       
                    } //: if-else
                    
                } //: Group
                .zIndex(4)
                .popBounceEffect(maxOffsetY: 100)
            }
            
            // MARK: Layer 6: Save Button when Editing
            if appViewModel.isDataPlanEditing || appViewModel.isDataLimitEditing || appViewModel.isDataLimitPerDayEditing {
                
                ButtonView(
                    type: buttonType,
                    action: buttonAction
                )
                    .fillMaxWidth(alignment: .trailing)
                    .padding(.horizontal, 38)
                    .padding(.top, 145 + 100 + (buttonType == .done ? 250 : 0))
                    .zIndex(5)
                
            }
            
            // MARK: Layer 7: Week's History
            if appViewModel.isHistoryShown {
                HistoryView(
                    days: appViewModel.days,
                    weekData: appViewModel.thisWeeksData,
                    dataLimitPerDay: appViewModel.dataLimitPerDay,
                    usageType: appViewModel.usageType,
                    closeAction: closeAction
                )
                .zIndex(6)
            }
            
            // MARK: Layer 8: Status Bar Background
            if !appViewModel.isBlurShown {
                Rectangle()
                    .fill(Colors.background.color)
                    .fillMaxWidth()
                    .frame(height: insets.top)
                    .fillMaxSize(alignment: .top)
                    .zIndex(7)
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
    
    func buttonAction(type: ButtonType) {
        withAnimation(.spring()) {
            switch type {
            case .save:
                appViewModel.didTapSave()
            case .done:
                appViewModel.didTapDone()
            }
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
