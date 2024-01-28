//
//  AppView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct AppView: View {
    // MARK: - Props
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dimensions) var dimensions: Dimensions
    @Environment(\.scenePhase) var scenePhase
    
    var spaceBetweenCardButton: CGFloat {
        /// graphical: 130
        30 + (appViewModel.isDatePickerShown ? 60 : 0)
    }

    var contentHeight: CGFloat {
        let planCardHeight = appViewModel.isPlanActive ?
            dimensions.planCardHeight : dimensions.planCardHeightDisabled
        
        return (
            dimensions.horizontalPadding +
            dimensions.topBarHeight +
            dimensions.spaceBottomTopBar +
            dimensions.maxPillHeight +
            dimensions.spaceInBetween +
            planCardHeight +
            dimensions.spaceInBetween +
            dimensions.planLimitCardsHeight +
            dimensions.horizontalPadding +
            dimensions.insets.bottom + 21
        )
    }
    
    var canFitContent: Bool {
        contentHeight <= dimensions.screen.height
    }
    
    var contentSpacing: CGFloat {
        let space = (contentHeight - dimensions.screen.height) * 0.5
        return (space < 0) ? 0 : space
    }

    // MARK: - UI
    var body: some View {
        ZStack {
            
            Colors.background.color

            // MARK: Layer 0: Today's Data Pill
            PillGroupView()
                .fillMaxHeight(alignment: .top)
                .padding(.top, dimensions.insets.top)
                .padding(.bottom, dimensions.insets.bottom + 21)
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
            
            if appViewModel.isBlurShown {
                VStack {}
                    .fillMaxSize()
                    .contentShape(Rectangle())
                    .zIndex(1)
                    .`if`(!appViewModel.isHistoryShown) { view in
                        view
                            .onTapGesture(perform: blurTappedAction)
                    }
                    .`if`(appViewModel.isHistoryShown) { view in
                        view
                            .onLongPressGesture(
                                minimumDuration: 100,
                                pressing: longPressedAction,
                                perform: {}
                            )
                    }
            }
            
            // MARK: Layer 2: Edit Plan - Data Amount & Period
            if appViewModel.isDataPlanEditing {
                
                EditItemCardView(
                    buttonType: appViewModel.buttonType,
                    buttonAction: buttonAction,
                    buttonDisabled: appViewModel.buttonDisabled,
                    spaceBetween: spaceBetweenCardButton,
                    isCardShown: !appViewModel.isDatePickerShown,
                    maxWidth: dimensions.planCardWidth
                ) {
                    DataPlanCardView(
                        editType: appViewModel.editDataPlanType,
                        startDate: appViewModel.startDateValue,
                        endDate: appViewModel.endDateValue,
                        numberOfdays: appViewModel.numOfDaysOfPlanValue,
                        periodAction: {},
                        dataAmountAction: {},
                        startPeriodAction: startPeriodAction,
                        endPeriodAction: endPeriodAction,
                        isPlanActive: .constant(false),
                        dataAmountValue: $appViewModel.dataValue,
                        dataAmount: appViewModel.dataAmount,
                        plusDataAction: plusDataAction,
                        minusDataAction: minusDataAction,
                        didChangePlusStepperValue: changeStepperPlusDataAction,
                        didChangeMinusStepperValue: changeStepperMinusDatatAction
                    )
                    .frame(width: dimensions.planCardWidth)
                }
                .zIndex(2)
                .popBounceEffect()
                .cardShadow(scheme: colorScheme)
            }

            // MARK: Layer 3: Edit Limit - Plan
            if appViewModel.isDataLimitEditing {

                EditItemCardView(
                    buttonType: appViewModel.buttonType,
                    buttonAction: buttonAction,
                    buttonDisabled: appViewModel.buttonDisabledPlanLimit,
                    spaceBetween: spaceBetweenCardButton,
                    toastMessage: appViewModel.toastMessage,
                    maxWidth: dimensions.limitCardWidth
                ) {
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
                    .frame(width: dimensions.limitCardWidth)
                }
                .zIndex(3)
                .popBounceEffect()
                .cardShadow(scheme: colorScheme)
            }

            // MARK: Layer 4: Edit Limit - Daily
            if appViewModel.isDataLimitPerDayEditing {

                EditItemCardView(
                    buttonType: appViewModel.buttonType,
                    buttonAction: buttonAction,
                    buttonDisabled: appViewModel.buttonDisabledDailyLimit,
                    spaceBetween: spaceBetweenCardButton,
                    toastMessage: appViewModel.toastMessage,
                    maxWidth: dimensions.limitCardWidth
                ) {
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
                    .frame(width: dimensions.limitCardWidth)
                }
                .zIndex(4)
                .popBounceEffect()
                .cardShadow(scheme: colorScheme)
            }

            // MARK: Layer 5: Date Picker
            if appViewModel.isDatePickerShown {
                /// NOTE:
                /// `.graphical` Date Picker Style Immediatelly Scrolls to Original Month
                /// When Scrolling to Next or Previous Month
                DatePicker(
                    "",
                    selection: appViewModel.isStartDatePickerShown ?
                        $appViewModel.startDateValue : $appViewModel.endDateValue,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .frame(width: dimensions.calendarWidth)
                .scaleEffect(0.9)
                .background(
                    Colors.background.color
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                )
                .zIndex(5)
                .popBounceEffect()
                .cardShadow(scheme: colorScheme)
            }

            // MARK: Layer 6: Week's History
            if appViewModel.isHistoryShown {
                HistoryView(
                    dayColors: appViewModel.dayColors,
                    weekData: appViewModel.thisWeeksData,
                    dataLimitPerDay: appViewModel.dataLimitPerDay,
                    usageType: appViewModel.usageType,
                    showFilledLines: appViewModel.isLongPressedOutside,
                    closeAction: closeAction
                )
                .padding(.top, 4)
                .zIndex(6)
                .popBounceEffect()
            }
            
            // MARK: Layer 7: Error
            if
                let error = appViewModel.dataError,
                error == .loadingContainer()
            {
                Text(
                    "Sorry, the data can’t be loaded from the Storage.",
                    comment: "Error message when the app can't read the data from the device"
                )
                    .textStyle(
                        foregroundColor: .onBackground,
                        font: .semibold,
                        size: 18,
                        lineLimit: 5,
                        lineSpacing: 2,
                        textAlignment: .center
                    )
                    .opacity(0.5)
                    .padding(.horizontal, 35)
                    .fillMaxSize(alignment: .center)
                    .zIndex(7)
            }
            
            // MARK: Layer 8: Status Bar Background
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
        .onChange(of: scenePhase, perform: didChangeScenePhase)
        .onOpenURL(perform: appViewModel.didOpenURL)
        .environmentObject(appViewModel)
        .background(Colors.background.color)
        .sheet(
            isPresented: $appViewModel.isGuideShown,
            onDismiss: {}
        ) {
            GuideView()
                .environmentObject(appViewModel)
        }
        .fullScreenCover(isPresented: $appViewModel.isSettingsShown) {
            SettingsView()
        }
        .onAppear {
            appViewModel.showGuide()
        }
        .preferredColorScheme(appViewModel.colorScheme)
        .alert(isPresented: $appViewModel.isNotificationAlertShown) {
            Alert(
                title: Text("Notification"),
                message: Text("Please allow notification in settings to get notifications"),
                primaryButton: .default(
                    Text("Ok"),
                    action: dimsmissAlertAction
                ),
                secondaryButton: .default(
                    Text("Settings"),
                    action: settingsAction
                )
            )
        } //: alert
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
            case .start:
                break
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
    
    func longPressedAction(pressed: Bool) {
        withAnimation {
            if pressed {
                appViewModel.didLongPressedOutside()
                return
            }
            appViewModel.didReleasedLongPressed()
        }
    }
    
    func didChangeScenePhase(phase: ScenePhase) {
        switch phase {
        case .background:
            appViewModel.didChangeBackgroundScenePhase()
        case .active:
            appViewModel.didChangeActiveScenePhase()
        default:
            break
        }
    }
    
    /// Notification
    func settingsAction() {
        appViewModel.setIsNotificationAlertShown(false)
    }
    
    func dimsmissAlertAction() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
    static var appViewModelError: AppViewModel {
        let database = InMemoryLocalDatabase(container: .dataUsage, appGroup: .dataPill)
        let dataRepo = DataUsageRepository(database: database)
        dataRepo.dataError = .loadingContainer()
        
        dataRepo.addData(
            date: Calendar.current.startOfDay(for: .init()),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        let viewModel = AppViewModel(dataUsageRepository: dataRepo)
        return viewModel
    }
    
    static var appViewModel = TestData.createAppViewModel()
    
    static var previews: some View {
        AppView()
            .previewLayout(.sizeThatFits)
            .environmentObject(appViewModel)
            .padding(.top, 20)
            .previewDisplayName("Working App")

        AppView()
            .previewLayout(.sizeThatFits)
            .environmentObject(appViewModelError)
            .padding(.top, 20)
            .previewDisplayName("Loading Data Error")
    }
}
