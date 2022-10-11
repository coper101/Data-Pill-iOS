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
    
    var width: CGFloat {
        Dimensions.Screen.width * 0.45
    }
    
    var height: CGFloat {
        (Dimensions.Screen.width * 0.45) * 2.26
    }
    
    // MARK: - UI
    var body: some View {
        ZStack(alignment: .top) {
            
            // Layer 0: BASIC INFO
            PillGroupView()
                .padding(.top, 12)
                .fillMaxSize(alignment: .top)
                .blur(radius: appViewModel.isBlurShown ? 15 : 0)
                .allowsHitTesting(!appViewModel.isBlurShown)
                .zIndex(0)
            
            // Layer 1: EDIT PLAN
            // another layer of data plan card
            if appViewModel.isDataPlanEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 50
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
            
            // Layer 2: EDIT LIMIT - Data
            if appViewModel.isDataLimitEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 50
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
                .padding(.top, height + 21 * 2)
            }
            
            // Layer 3: EDIT LIMIT - Daily or Plan
            if appViewModel.isDataLimitPerDayEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 50
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
                .padding(.top, height + 21 * 2)
            }
            
            // Layer 4: EDIT PLAN - Period
            if appViewModel.isStartDatePickerShown || appViewModel.isEndDatePickerShown {
                DatePicker(
                    selection: appViewModel.isStartDatePickerShown ?
                        $appViewModel.startDateValue : $appViewModel.endDateValue,
                    displayedComponents: .date,
                    label: {}
                )
                .preferredColorScheme(.light)
                .datePickerStyle(.graphical)
                .transition(.move(edge: .bottom))
                .frame(width: Dimensions.Screen.width * 0.9)
                .scaleEffect(0.9)
                .background(
                    Colors.surface.color
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                )
                .padding(.top, EdgeInsets.insets.top + 14)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
                .zIndex(4)
            }
            
            // Layer 5: OVERVIEW OF USED DATA THIS WEEK
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
            
        } //: ZStack
        .background(Colors.background.color)
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Actions
    func startPeriodAction() {
        withAnimation {
            appViewModel.didTapStartPeriod()
        }
    }
    
    func endPeriodAction() {
        withAnimation {
            appViewModel.didTapEndPeriod()
        }
    }

    func plusLimitAction() {
        appViewModel.didTapPlusLimit()
    }
    
    func minusLimitAction() {
        appViewModel.didTapMinusLimit()
    }
    
    func plusDataAction() {
        appViewModel.didTapPlusData()
    }
    
    func minusDataAction() {
        appViewModel.didTapMinusData()
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
