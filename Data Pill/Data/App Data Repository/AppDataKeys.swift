//
//  AppDataKeys.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

enum Keys: String {
    
    /// Guide Screen
    case wasGuideShown = "Was_Guide_Shown"
    
    /// Plan
    case isPlanActive = "Is_Plan_Active"
    case usageType = "Usage_Type"
    case autoPeriod = "Auto_Period"
    case startDatePlan = "Start_Data_Plan"
    case endDatePlan = "End_Data_Plan"
    case dataAmount = "Data_Amount"
    case dailyDataLimit = "Daily_Data_Limit"
    case totalDataLimit = "Total_Data_Limit"
    
    /// Stepper
    case dataPlusStepperValue = "Data_Plus_Stepper_Value"
    case dataMinusStepperValue = "Data_Minus_Stepper_Value"
    
    case dataLimitPerDayPlusStepperValue = "Data_Plus_Daily_Limit_Stepper_Value"
    case dataLimitPerDayMinusStepperValue = "Data_Minus_Daily_Limit_Stepper_Value"
    
    case dataLimitPlusStepperValue = "Data_Plus_Total_Limit_Stepper_Value"
    case dataLimitMinusStepperValue = "Data_Minus_Total_Limit_Stepper_Value"
    
    /// Local - Remote Synchronization
    case lastSyncToRemoteDate = "Last_Synced_To_Remote_Date"
    
    /// Settings
    /// - Appearance
    case isDarkMode = "Is_Dark_Mode"
    case fillUsageType = "Fill_Usage_Type"
    case hasLabelInDaily = "Has_Labels_In_Daily"
    case hasLabelInWeekly = "Has_Labels_In_Weekly"
    case dayColors = "Day_Colors"

    /// - Notification
    case hasDailyNotification = "Has_Daily_Notification"
    case hasPlanNotification = "Has_Plan_Notification"
    case todaysLastNotificationDate = "Todays_Last_Notification_Date"
    case planLastNotificationDate = "Plan_Last_Notification_Date"
    
}
