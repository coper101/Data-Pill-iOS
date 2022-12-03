//
//  AppView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI
import WidgetKit

struct AppView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    @Environment(\.scenePhase) var scenePhase
    
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
    
    var additionalPadding: CGFloat {
        (appViewModel.isDataLimitPerDayEditing
         || appViewModel.isDataLimitEditing) ?
            30 :
            0
    }
    
    var contentHeight: CGFloat {
        height + 152 + dimensions.cardHeight + (dimensions.spaceInBetween * 2) + (dimensions.horizontalPadding * 2)
    }
    
    var canFitContent: Bool {
        contentHeight <= dimensions.screen.height
    }
    
    var contentSpacing: CGFloat {
        let space = (contentHeight - dimensions.screen.height) / 2
        if space < 0 {
            return 0
        }
        return space
    }

    // MARK: - UI
    var body: some View {
        ZStack {

            // MARK: Layer 0: Today's Data Pill
            PillGroupView()
                .fillMaxHeight(alignment: .top)
                .padding(.top, dimensions.insets.top)
                .position(
                    x: dimensions.screen.width * 0.5,
                    y: (dimensions.screen.height * 0.5) + contentSpacing
                )
                .`if`(!canFitContent) { view in
                    view.scrollSnap(
                        contentHeight: contentHeight,
                        screenHeight: dimensions.screen.height
                    )
                }
                .blur(radius: appViewModel.isBlurShown ? 15 : 0)
                .allowsHitTesting(!appViewModel.isBlurShown)
                .zIndex(0)
            
            if
                appViewModel.isBlurShown &&
                !appViewModel.isHistoryShown
            {
                VStack {}
                    .fillMaxSize()
                    .contentShape(Rectangle())
                    .zIndex(1)
                    .onTapGesture(perform: blurTappedAction)
            }
            
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
                    minusDataAction: minusDataAction,
                    didChangePlusStepperValue: changeStepperPlusDataAction,
                    didChangeMinusStepperValue: changeStepperMinusDatatAction
                )
                .padding(.horizontal, dimensions.horizontalPadding)
                .zIndex(2)
                .popBounceEffect()
                .cardShadow()
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
                    plusDataAction: plusLimitAction,
                    didChangePlusStepperValue: changeStepperPlusLimitAction,
                    didChangeMinusStepperValue: changeStepperMinusLimitAction
                )
                .frame(height: dimensions.cardHeight)
                .padding(.horizontal, dimensions.horizontalPadding + 16)
                .zIndex(3)
                .popBounceEffect()
                .cardShadow()
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
                    plusDataAction: plusLimitAction,
                    didChangePlusStepperValue: changeStepperPlusDailyLimitAction,
                    didChangeMinusStepperValue: changeStepperMinusDailyLimitAction
                )
                .frame(height: dimensions.cardHeight)
                .padding(.horizontal, dimensions.horizontalPadding + 16)
                .zIndex(4)
                .popBounceEffect()
                .cardShadow()
            }

            // MARK: Layer 5: Date Picker
            if
                appViewModel.isStartDatePickerShown ||
                appViewModel.isEndDatePickerShown
            {
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
                .zIndex(5)
                .popBounceEffect()
                .cardShadow()
            }

            // MARK: Layer 6: Save Button when Editing
            if
                appViewModel.isDataPlanEditing ||
                appViewModel.isDataLimitEditing ||
                appViewModel.isDataLimitPerDayEditing
            {
                ButtonView(
                    type: buttonType,
                    action: buttonAction
                )
                .fillMaxWidth(alignment: .trailing)
                .padding(
                    .horizontal,
                    dimensions.horizontalPadding + additionalPadding
                )
                .padding(
                    .top,
                    dimensions.cardHeight + 130 + (buttonType == .done ? 250 : 0)
                )
                .zIndex(6)
                .popBounceEffect()
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
                .padding(.top, 4)
                .zIndex(7)
                .popBounceEffect()
            }
            
            // MARK: Layer 8: Error
            if
                let error = appViewModel.dataError,
                error == .loadingContainer(),
                case .loadingContainer(let message) = error
            {
                Text(message)
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 18,
                        lineLimit: 5,
                        lineSpacing: 2,
                        textAlignment: .center
                    )
                    .opacity(0.28)
                    .padding(.horizontal, 35)
                    .fillMaxSize(alignment: .center)
            }
            
            // MARK: Layer 9: Status Bar Background
            Rectangle()
                .fill(Colors.background.color)
                .fillMaxWidth()
                .frame(height: dimensions.insets.top)
                .fillMaxSize(alignment: .top)
                .zIndex(8)

        } //: ZStack
        .ignoresSafeArea(.container, edges: .vertical)
        .fillMaxSize(alignment: .center)
        .background(Colors.background.color)
        .onChange(
            of: scenePhase,
            perform: didChangeScenePhase
        )
        .onOpenURL(perform: appViewModel.didOpenURL)
    }
    
    // MARK: - Actions
    /// Period
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

    /// Limit
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
    
    /// Limit Plan
    func changeStepperPlusLimitAction(value: Double) {
        appViewModel.didChangePlusStepperValue(
            value: value,
            type: .planLimit
        )
    }
    
    func changeStepperMinusLimitAction(value: Double) {
        appViewModel.didChangeMinusStepperValue(
            value: value,
            type: .planLimit
        )
    }
    
    /// Limit Daily
    func changeStepperPlusDailyLimitAction(value: Double) {
        appViewModel.didChangePlusStepperValue(
            value: value,
            type: .dailyLimit
        )
    }
    
    func changeStepperMinusDailyLimitAction(value: Double) {
        appViewModel.didChangeMinusStepperValue(
            value: value,
            type: .dailyLimit
        )
    }
    
    
    /// Data
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
    
    func changeStepperPlusDataAction(value: Double) {
        appViewModel.didChangePlusStepperValue(
            value: value,
            type: .data
        )
    }
    
    func changeStepperMinusDatatAction(value: Double) {
        appViewModel.didChangeMinusStepperValue(
            value: value,
            type: .data
        )
    }
    
    /// UI
    func buttonAction(type: ButtonType) {
        withAnimation {
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
    
    func blurTappedAction() {
        withAnimation {
            appViewModel.didTapOutside()
        }
    }
    
    func didChangeScenePhase(phase: ScenePhase) {
        if phase == .active {
            appViewModel.updatePlanPeriod()
        } else if phase == .background {
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.main.rawValue)
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
