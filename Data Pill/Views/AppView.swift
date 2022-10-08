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
    
    var homeActions: HomeActions {
        .init(appState: appState)
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
            
            // Layer 0: BASIC INFO
            BasicInfoView()
                .fillMaxSize(alignment: .top)
                .background(Colors.background.color)
                .blur(radius: appState.isBlurShown ? 15 : 0)
                .allowsHitTesting(!appState.isBlurShown)
                .zIndex(0)
            
            // Layer 1: EDIT PLAN
            // another layer of data plan card
            if appState.isDataPlanEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 50
                ) {
                    // Edit Cards
                    DataPlanCardView(
                        editType: appState.editDataPlanType,
                        startDate: appState.startDateValue,
                        endDate: appState.endDateValue,
                        numberOfdays: appState.numOfDaysOfPlanValue,
                        periodAction: {},
                        dataAmountAction: {},
                        startPeriodAction: didTapStartPeriod,
                        endPeriodAction: didTapEndPeriod,
                        dataAmountValue: $appState.dataValue,
                        plusDataAction: didTapPlus,
                        minusDataAction: didTapMinus
                    )
                                        
                    // Save Button
                    SaveButtonView(action: didTapSave)
                        .alignmentGuide(.trailing) { $0.width + 21 }
                    
                } //: VStack
                .zIndex(1)
                .padding(.horizontal, 21)
                .padding(.top, height + 21 * 2)
            }
            
            // Layer 2: EDIT LIMIT - 1 Cycle
            if appState.isDataLimitEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 50
                ) {
                    // Edit Card
                    DataPlanLimitView(
                        dataLimitValue: $appState.dataLimitValue,
                        dataAmount: appState.dataLimit,
                        isEditing: true,
                        usageType: .plan,
                        editAction: {},
                        minusDataAction: didTapMinusLimit,
                        plusDataAction: didTapPlusLimit
                    )
                    .padding(.horizontal, 21)
                    .frame(height: 145)
                    .zIndex(2)
                    
                    // Save Button
                    SaveButtonView(action: didTapSave)
                        .alignmentGuide(.trailing) { $0.width + 21 }
                    
                } //: VStack
                .padding(.top, height + 21 * 2)
            }
            
            // Layer 3: EDIT LIMIT - Daily
            if appState.isDataLimitPerDayEditing {
                VStack(
                    alignment: .trailing,
                    spacing: 50
                ) {
                    // Edit Card
                    DataPlanLimitView(
                        dataLimitValue: $appState.dataLimitPerDayValue,
                        dataAmount: appState.dataLimitPerDay,
                        isEditing: true,
                        usageType: .daily,
                        editAction: {},
                        minusDataAction: didTapMinusLimit,
                        plusDataAction: didTapPlusLimit
                    )
                    .padding(.horizontal, 21)
                    .frame(height: 145)
                    .zIndex(3)
                    
                    // Save Button
                    SaveButtonView(action: didTapSave)
                        .alignmentGuide(.trailing) { $0.width + 21 }
                    
                } //: VStack
                .padding(.top, height + 21 * 2)
            }
            
            // Layer 4: EDIT PLAN - Start Date Input
            if appState.isStartDatePickerShown {
                DatePicker(
                    selection: $appState.startDateValue,
                    displayedComponents: .date,
                    label: {}
                )
                .labelsHidden()
                .padding()
                .frame(width: Dimensions.Screen.width * 0.85)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .datePickerStyle(.graphical)
                .transition(.slide)
                .zIndex(4)
            }

            // Layer 5: EDIT PLAN - End Date Input
            if appState.isEndDatePickerShown {
                DatePicker(
                    selection: $appState.endDateValue,
                    displayedComponents: .date,
                    label: {}
                )
                .labelsHidden()
                .padding()
                .frame(width: Dimensions.Screen.width * 0.85)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .datePickerStyle(.graphical)
                .transition(.slide)
                .zIndex(5)
            }
            
            // Layer 6: OVERVIEW OF USED DATA THIS WEEK
            if appState.isHistoryShown {
                HistoryView(
                    days: appState.days,
                    weekData: appState.thisWeeksData,
                    dataLimitPerDay: appState.dataLimitPerDay,
                    usageType: appState.usageType,
                    closeAction: didTapClose
                )
                .zIndex(6)
            }
            
        } //: ZStack
        .onChange(of: appState.isDataPlanEditing) { isEditing in
            switch appState.editDataPlanType {
            case .dataPlan:
                // update dates
                appState.startDate = appState.startDateValue
                appState.endDate = appState.endDateValue
            case .data:
                // update data amount only if editing is done
                guard
                    let amount = Double(appState.dataValue),
                    !isEditing,
                    appState.editDataPlanType == .data
                else { return }
                appState.dataAmount = amount
            }
            print(appState)
        }
        .onChange(of: appState.isDataLimitEditing) { isEditing in
            // update data limit only if editing is done
            guard
                let amount = Double(appState.dataLimitValue),
                !isEditing
            else { return }
            appState.dataLimit = amount
            print(appState)
        }
        .onChange(of: appState.isDataLimitPerDayEditing) { isEditing in
            // update data limit per day only if editing is done
            guard
                let amount = Double(appState.dataLimitPerDayValue),
                !isEditing
            else { return }
            appState.dataLimitPerDay = amount
            print(appState)
        }
    }
    
    // MARK: - Actions
    func didTapClose() {
        withAnimation {
            appState.isBlurShown = false
            appState.isHistoryShown = false
        }
    }
    
    // Edit
    func didTapSave() {
        withAnimation {
            appState.isBlurShown = false
            appState.isDataPlanEditing = false
            
            appState.isStartDatePickerShown = false
            appState.isEndDatePickerShown = false
            
            appState.isDataLimitEditing = false
            appState.isDataLimitPerDayEditing = false
        }
    }
    
    // - Edit Data
    func didTapPlus() {
        guard var doubleValue = Double(appState.dataValue) else {
            return
        }
        doubleValue += 1
        appState.dataValue = "\(doubleValue)"
    }
    
    func didTapMinus() {
        guard
            var doubleValue = Double(appState.dataValue),
            doubleValue > 0
        else {
            return
        }
        doubleValue -= 1
        appState.dataValue = "\(doubleValue)"
    }
    
    // - Edit Data Plan
    func didTapStartPeriod() {
        withAnimation {
            appState.isEndDatePickerShown = false
            appState.isStartDatePickerShown = true
        }
    }
    
    func didTapEndPeriod() {
        withAnimation {
            appState.isStartDatePickerShown = false
            appState.isEndDatePickerShown = true
        }
    }
    
    // - Edit Data Limit
    func didTapMinusLimit() {
        let value = Double(
            appState.isDataLimitEditing ?
                appState.dataLimitValue :
                appState.dataLimitPerDayValue
        )
        guard
            var doubleValue = value,
            doubleValue > 0
        else {
            return
        }
        let newDoubleValue = doubleValue - 1
        doubleValue = newDoubleValue >= 0 ? newDoubleValue : 0
        
        if appState.isDataLimitEditing {
            appState.dataLimitValue = "\(doubleValue)"
        } else {
            appState.dataLimitPerDayValue = "\(doubleValue)"
        }
    }
    
    func didTapPlusLimit() {
        let value = Double(
            appState.isDataLimitEditing ?
                appState.dataLimitValue :
                appState.dataLimitPerDayValue
        )
        guard
            var doubleValue = value,
            doubleValue + 1 <= appState.dataAmount
        else {
            return
        }
        doubleValue += 1
        
        if appState.isDataLimitEditing {
            appState.dataLimitValue = "\(doubleValue)"
        } else {
            appState.dataLimitPerDayValue = "\(doubleValue)"
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
