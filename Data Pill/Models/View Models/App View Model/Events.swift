//
//  Events.swift
//  Data Pill
//
//  Created by Wind Versi on 24/6/23.
//

import SwiftUI
import WidgetKit
import OSLog

extension AppViewModel {
    
    // MARK: - Mobile Data
    /// Updates the amount used `Data` today
    func refreshUsedDataToday(_ totalUsedData: Double) {
        /// ignore initial value which is exactly zero
        if totalUsedData == 0 {
            return
        }
        /// calculate new amount used data
        var amountUsed = 0.0
        if let recentDataWithHasTotal = dataUsageRepository.getDataWithHasTotal() {
            let recentTotalUsedData = recentDataWithHasTotal.totalUsedData
            amountUsed = totalUsedData - recentTotalUsedData
        }
        
        /// new amount can't be calculated since device was restarted
        if amountUsed < 0 {
            amountUsed = 0
        }
                
        guard let todaysData = dataUsageRepository.getTodaysData() else {
            Logger.appModel.debug("- MOBILE DATA: 📲 Refreshing | 😭 ERROR: Today's Data is Nil")
            return
        }
        
        let dailyUsedData = todaysData.dailyUsedData + amountUsed
                
        updateTodaysData(
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: true
        )
        Logger.appModel.debug("- MOBILE DATA: 📲 Refreshing | ✅ Today's Data Updated, Total Used Data: \(totalUsedData)")
        Logger.appModel.debug("- MOBILE DATA: 📲 Refreshing | ✅ Today's Data Updated, Daily Used Data: \(dailyUsedData)")
    }
    
    // MARK: - Data Plan
    func didTapStartPlan() {
        closeGuide()
        appDataRepository.setIsPlanActive(true)
        dataUsageRepository.updateToLatestPlan()
    }
    
    func didTapStartNonPlan() {
        closeGuide()
        appDataRepository.setIsPlanActive(false)
        dataUsageRepository.updateToLatestPlan()
    }
    
    func didChangeIsPlanActive(_ isActive: Bool) {
        if !isActive && (usageType == .plan) {
            appDataRepository.setUsageType(ToggleItem.daily.rawValue)
        }
        
        /// update daily limit if it exceeds max data amount
        /// when `Plan` becomes active
        if isActive && (dataLimitPerDay > dataAmount) {
            dataLimitPerDay = dataAmount
            dataLimitPerDayValue = "\(dataAmount)"
        }
    }
    
    // MARK: - Edit Data Plan
    /// Initial Values
    func setInputValues() {
        dataValue = "\(dataAmount)"
        startDateValue = startDate
        endDateValue = endDate
        dataLimitValue = "\(dataLimit)"
        dataLimitPerDayValue = "\(dataLimitPerDay)"
    }
    
    /// Period
    func didTapPeriod() {
        isBlurShown = true
        isDataPlanEditing = true
        editDataPlanType = .dataPlan
    }
    
    func didTapStartPeriod() {
        isEndDatePickerShown = false
        isStartDatePickerShown = true
    }
    
    func didTapEndPeriod() {
        isStartDatePickerShown = false
        isEndDatePickerShown = true
    }
    
    func updatePlanPeriod() {
        guard let todaysData = dataUsageRepository.todaysData else {
            Logger.appModel.debug("updatePlanPeriod - error: today's data is nil")
            return
        }
        guard
            isPeriodAuto,
            let todaysDate = todaysData.date,
            !todaysDate.isDateInRange(from: startDate, to: endDate),
            let newStartDate = startDate.addDay(value: numOfDaysOfPlan),
            let newEndDate = newStartDate.addDay(value: numOfDaysOfPlan - 1)
        else {
            return
        }
        updatePlan(startDate: newStartDate, endDate: newEndDate)
        Logger.appModel.debug("updatePlanPeriod - updated with date from: \(newStartDate) to \(newEndDate)")
    }
    
    func updatePlan(
        startDate: Date? = nil,
        endDate: Date? = nil,
        dataAmount: Double? = nil,
        dailyLimit: Double? = nil,
        planLimit: Double? = nil
    ) {
        dataUsageRepository.updatePlan(
            startDate: startDate,
            endDate: endDate,
            dataAmount: dataAmount,
            dailyLimit: dailyLimit,
            planLimit: planLimit,
            updateToLatestPlanAfterwards: true
        )
    }
    
    /// Data Amount
    func didTapAmount() {
        isBlurShown = true
        isDataPlanEditing = true
        editDataPlanType = .data
    }
    
    func didTapPlusData() {
        dataValue = Stepper.plus(
            value: dataValue,
            max: 100,
            by: dataPlusStepperValue
        )
    }
    
    func didTapMinusData() {
        dataValue = Stepper.minus(
            value: dataValue,
            by: dataMinusStepperValue
        )
    }
    
    func didChangePlusStepperValue(value: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            appDataRepository.setPlusStepperValue(value, type: .planLimit)
            didTapPlusLimit()
        case .dailyLimit:
            appDataRepository.setPlusStepperValue(value, type: .dailyLimit)
            didTapPlusLimit()
        case .data:
            appDataRepository.setPlusStepperValue(value, type: .data)
            didTapPlusData()
        }
    }
    
    func didChangeMinusStepperValue(value: Double, type: StepperValueType) {
        switch type {
        case .planLimit:
            appDataRepository.setMinusStepperValue(value, type: .planLimit)
            didTapMinusLimit()
        case .dailyLimit:
            appDataRepository.setMinusStepperValue(value, type: .dailyLimit)
            didTapMinusLimit()
        case .data:
            appDataRepository.setMinusStepperValue(value, type: .data)
            didTapMinusData()
        }
    }
    
    func didChangeIsDataPlanEditing(_ isEditing: Bool) {
        if toastTimer.timer != nil {
            toastTimer.reset()
        }
        
        guard !isTappedOutside else {
            /// revert to previous values

            /// data plan
            dataValue = "\(dataAmount)"
            dataValue = "\(dataValue)"
            startDateValue = startDate
            endDateValue = endDate
            
            /// edit data limit
            dataLimitValue = "\(dataLimit)"
            dataLimitPerDayValue = "\(dataLimitPerDay)"
            
            isTappedOutside = false
            
            return
        }
        
        switch editDataPlanType {
        case .dataPlan:
            /// update dates
            updatePlan(startDate: startDateValue, endDate: endDateValue)
        case .data:
            /// update data amount only if editing is done
            guard
                let amount = Double(dataValue),
                !isEditing,
                editDataPlanType == .data
            else {
                /// invalid input, revert to previous value
                dataValue = "\(dataAmount)"
                return
            }
            updatePlan(dataAmount: amount)
            /// show proper format  e.g. 0.1 instead of .1
            dataValue = "\(dataAmount)"
            
            /// adjust daily limit
            if dataLimitPerDay > dataAmount {
                updatePlan(dailyLimit: dataAmount)
                dataLimitPerDayValue = "\(dataLimitPerDay)"
            }
            
            /// adjust plan limit
            if dataLimit > dataAmount {
                updatePlan(planLimit: dataAmount)
                dataLimitValue = "\(dataLimit)"
            }
        }
    }
    
    func didChangeIsDataLimitEditing(_ isEditing: Bool) {
        /// update data limit only if editing is done
        guard
            let amount = Double(dataLimitValue),
            !isEditing
        else {
            return
        }
        updatePlan(planLimit: amount)
    }
    
    func didChangeIsDataLimitPerDayEditing(_ isEditing: Bool) {
        /// update data limit per day only if editing is done
        guard
            let amount = Double(dataLimitPerDayValue),
            !isEditing
        else {
            return
        }
        updatePlan(dailyLimit: amount)
    }
    
    // MARK: - Edit Data Limit
    func didTapLimit() {
        isBlurShown = true
        isDataLimitEditing = true
    }
    
    func didTapLimitPerDay() {
        isBlurShown = true
        isDataLimitPerDayEditing = true
    }
    
    func didTapPlusLimit() {
        let value = (isDataLimitEditing) ?
            dataLimitValue :
            dataLimitPerDayValue
        
        let plusValue = (isDataLimitEditing) ?
            dataLimitPlusStepperValue :
            dataLimitPerDayPlusStepperValue
        
        let newValue = Stepper.plus(
            value: value,
            max: maxDataAmountForLimit,
            by: plusValue,
            onExceed: { [weak self] in
                guard let self else {
                    return
                }
                if self.isPlanActive {
                    self.toastTimer.showToast(message: "Exceeds maximum data amount")
                    return
                }
                self.toastTimer.showToast(message: "You have reached the max limit")
            }
        )
        
        if isDataLimitEditing {
            dataLimitValue = newValue
            return
        }
        dataLimitPerDayValue = newValue
    }
    
    func didTapMinusLimit() {
        let value = (isDataLimitEditing) ?
            dataLimitValue :
            dataLimitPerDayValue
        
        let minusValue = (isDataLimitEditing) ?
            dataLimitMinusStepperValue :
            dataLimitPerDayMinusStepperValue
                
        let newValue = Stepper.minus(
            value: value,
            by: minusValue
        )
        
        if isDataLimitEditing {
            dataLimitValue = newValue
            return
        }
        dataLimitPerDayValue = newValue
    }
    
    // MARK: - Today's Data
    func updateTodaysData(
        date: Date? = nil,
        totalUsedData: Double? = nil,
        dailyUsedData: Double? = nil,
        hasLastTotal: Bool? = nil,
        isSyncedToRemote: Bool? = nil,
        lastSyncedToRemoteDate: Date? = nil
    ) {
        dataUsageRepository.updateTodaysData(
            date: date,
            totalUsedData: totalUsedData,
            dailyUsedData: dailyUsedData,
            hasLastTotal: hasLastTotal,
            isSyncedToRemote: isSyncedToRemote,
            lastSyncedToRemoteDate: lastSyncedToRemoteDate
        )
    }
    
    // MARK: - Operations
    func didTapSave() {
        isBlurShown = false
        
        if isDataPlanEditing {
            isDataPlanEditing = false
        }
        
        if isStartDatePickerShown {
            isStartDatePickerShown = false
        }
        
        if isEndDatePickerShown {
            isEndDatePickerShown = false
        }
        
        if isDataLimitEditing {
            isDataLimitEditing = false
        }
        
        if isDataLimitPerDayEditing {
            isDataLimitPerDayEditing = false
        }
    }
    
    func didTapDone() {
        isStartDatePickerShown = false
        isEndDatePickerShown = false
    }
    
    func didTapOutside() {
        isTappedOutside = true
        
        isBlurShown = false
        isDataPlanEditing = false
        
        isStartDatePickerShown = false
        isEndDatePickerShown = false
        
        isDataLimitEditing = false
        isDataLimitPerDayEditing = false
    }
    
    func didLongPressedOutside() {
        isLongPressedOutside = true
    }
    
    func didReleasedLongPressed() {
        isLongPressedOutside = false
    }
    
    // MARK: - History
    func didTapCloseHistory() {
        isBlurShown = false
        isHistoryShown = false
    }
    
    func didTapOpenHistory() {
        guard usageType == .daily else {
            return
        }
        isBlurShown = true
        isHistoryShown = true
    }
    
    // MARK: - Data Error
    func didChangeDataError(_ error: DatabaseError?) {
        guard let error = error, error == .loadingContainer() else {
            return
        }
        isBlurShown = true
    }
    
    // MARK: - Deep Link
    func didOpenURL(url: URL) {
        if url == ToggleItem.plan.url {
            appDataRepository.setUsageType(ToggleItem.plan.rawValue)
        } else if url == ToggleItem.daily.url {
            appDataRepository.setUsageType(ToggleItem.daily.rawValue)
        }
    }
    
    // MARK: - Scene Phase
    func didChangeActiveScenePhase() {
        updatePlanPeriod()
        
        /// Disable iCloud for Now
        // syncPlan()
        // syncTodaysData()
        
        // setupBackgroundTask()
        // syncOldThenRemoteData()
    }

    func didChangeBackgroundScenePhase() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKind.main.name)
    }
    
    // MARK: - Background Task
    func setupBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Sync Old And Remote Data") { [weak self] in
            /// when background task runs out of time (30 sec starting from entering background)
            /// invalidate background task
            self?.endBackgroundTask()
        }
        Logger.appModel.debug("setupBackgroundTask - \(String(describing: self.backgroundTaskID))")
    }
    
    func endBackgroundTask() {
        if let taskID = self.backgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskID)
            backgroundTaskID = .invalid
            Logger.appModel.debug("endBackgroundTask - \(String(describing: self.backgroundTaskID))")
        }
    }
    
    // MARK: - Guide Screen
    func showGuide() {
        isGuideShown = !wasGuideShown
    }
    
    func closeGuide() {
        isGuideShown = false
        appDataRepository.setWasGuideShown(true)
    }
    
    // MARK: - Settings Screen
    func showSettings() {
        isSettingsShown = true
    }
    
    func closeSettings() {
        isSettingsShown = false
    }
    
    func didTapBackSettingsChild() {
        activeSettingsScreen = nil
    }
    
    func didTapSettingsChild(screen: SettingsScreen) {
        activeSettingsScreen = screen
    }
    
    // MARK: Notifications
    func didTapNotification(enabled: Bool) {
        Task {
            if enabled {
                
                /// A. Ask User To Allow Notification
                var (isAllowed, isNotDermined) = await localNotificationManager.status()
                
                if isNotDermined {
                    isAllowed = await localNotificationManager.requestPersmission()
                }
                
                if !isAllowed {
                    
                    await setIsNotificationAlertShown(true)

                } //: if
                
            } else {
                
                /// B. Remove All Notifications
                localNotificationManager.removeAll()
                
            } //: if-else
        }
    }
    
    func notifyExceededUsages() {
        if hasDailyNotification {
            notifyExceededUsage(for: .daily)
        }
        if hasPlanNotification {
            notifyExceededUsage(for: .plan)
        }
    }
    
    func notifyExceededUsage(for type: ToggleItem) {
        Task {
            let (isAllowed, _) = await localNotificationManager.status()
          
            guard isAllowed else {
                return
            }
            
            let dailyLimitMinPercentage = 90 /// fixed for now
            let planLimitMaxPercentage = 100
            var dataUsedInPercentage = 0
            
            switch type {
            case .daily:
                dataUsedInPercentage = todaysData.dailyUsedData
                    .toGB()
                    .toPercentage(with: dataLimitPerDay)
                
                if (dataUsedInPercentage >= dailyLimitMinPercentage) {
                    let hasReceived = await localNotificationManager.hasReceived(notification: .dailyUsage)
                    let hasNotifiedToday = todaysLastNotificationDate?.isToday() ?? false

                    if !hasReceived, !hasNotifiedToday {
                        await self.localNotificationManager.scheduleNow(
                            notification: .dailyUsage,
                            amountUsageInPercentage: dailyLimitMinPercentage
                        )
                        appDataRepository.setTodaysLastNotificationDate(.init())
                        Logger.appModel.debug("🔔 Notification - \(type.rawValue) Notified")
                    } else {
                        Logger.appModel.debug("🔔 Notification - \(type.rawValue) Cancelled")
                    }
                } //: if
            case .plan:
                dataUsedInPercentage = dataUsageRepository.getTotalUsedData(from: startDate, to: endDate)
                    .toGB()
                    .toPercentage(with: dataLimit)
                
                if (dataUsedInPercentage >= planLimitMaxPercentage) {
                    let hasReceived = await localNotificationManager.hasReceived(notification: .planUsage)
                    let hasNotifiedToday = planLastNotificationDate != nil

                    if !hasReceived, !hasNotifiedToday {
                        await self.localNotificationManager.scheduleNow(
                            notification: .planUsage,
                            amountUsageInPercentage: planLimitMaxPercentage
                        )
                        appDataRepository.setPlanLastNotificationDate(.init())
                        Logger.appModel.debug("🔔 Notification - \(type.rawValue) Notified")
                    } else {
                        Logger.appModel.debug("🔔 Notification - \(type.rawValue) Cancelled")
                    }
                } //: if
            } //: switch-case
            
            Logger.appModel.debug("🔔 Notification - Notify \(type.rawValue)?")
        } //: if
    }
    
    @MainActor
    func setIsNotificationAlertShown(_ shown: Bool) {
        isNotificationAlertShown = shown
    }
}
