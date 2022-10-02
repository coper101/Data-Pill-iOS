//
//  AppState.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation
import Combine

class AppState: ObservableObject, CustomDebugStringConvertible {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    // MARK: - UI
    /// Usage Type - Plan or Daily
    @Published var usageType: ToggleItem = .daily
    
    /// Notification
    @Published var isNotifOn = false
    @Published var isHistoryShown = false
    @Published var isBlurShown = false
    
    /// Edit Data Plan
    @Published var isDataPlanEditing = false
    @Published var editDataPlanType: EditDataPlan = .dataPlan
    @Published var isStartDatePickerShown = false
    @Published var isEndDatePickerShown = false
    
    @Published var dataValue = "0.0"
    @Published var startDateValue: Date = .init()
    @Published var endDateValue: Date = .init()
    
    /// Edit Data Limit
    @Published var isDataLimitEditing = false
    @Published var isDataLimitPerDayEditing = false
    
    @Published var dataLimitValue = "0.0"
    @Published var dataLimitPerDayValue = "0.0"
    
    var numOfDaysOfPlanValue: Int {
        startDateValue.toNumOfDays(to: endDateValue)
    }
    
    /// Weekday color can be customizable in the future
    @Published var days: [DayPill] = [
        .init(color: .secondaryBlue, day: .sunday),
        .init(color: .secondaryPurple, day: .monday),
        .init(color: .secondaryGreen, day: .tuesday),
        .init(color: .secondaryRed, day: .wednesday),
        .init(color: .secondaryOrange, day: .thursday),
        .init(color: .secondaryPurple, day: .friday),
        .init(color: .secondaryBlue, day: .saturday)
    ]
        
    // MARK: - Data
    /// Data Plan
    @Published var startDate = "2022-09-12T10:44:00+0000".toDate()
    @Published var endDate = "2022-10-12T10:44:00+0000".toDate()
    @Published var dataAmount = 0.0
    @Published var dataLimit = 0.0
    @Published var dataLimitPerDay = 0.0
    @Published var unit: Unit = .gb
    
    var numOfDaysOfPlan: Int {
        startDate.toNumOfDays(to: endDate)
    }
    
    /// Data Records
    @Published var data: [Data] = .init()
//    [
//        // Sun to Sat 11-17 sep
//        .init(
//            date: "2022-09-11T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-12T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-13T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-14T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-15T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-16T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-17T10:44:00+0000".toDate()
//        ),
//        // Sun to Sat 18-24 sep
//        .init(
//            date: "2022-09-18T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-19T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-20T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-21T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-22T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-23T10:44:00+0000".toDate()
//        ),
//        .init(
//            date: "2022-09-24T10:44:00+0000".toDate()
//        ),
//        // Sun to Sat 25 Sep 1 Oct
//        .init(
//            date: "2022-09-25T10:44:00+0000".toDate(),
//            dailyUsedData: 0.07
//        )
//    ]
    
    var todaysData: Data {
        guard let today = data.first(
            where: {
                guard let date = $0.date else {
                    return false
                }
                return date.isToday()
            }
        ) else {
            // create new data if today doesn't exist
            let newToday = Data(date: .init())
            data.append(newToday)
            return newToday
        }
        return today
    }
    
    var weeksData: [Data] {
        guard
            let date = todaysData.date,
            let weekday = date.toDateComp().weekday
        else {
            return .init()
        }
        return data.suffix(weekday)
    }
    
    var usedData: Double {
        usageType == .daily ?
            todaysData.dailyUsedData :
            totalUsedData(
                data,
                from: startDate,
                to: endDate
            )
    }
    
    var maxData: Double {
        usageType == .daily ?
            dataLimitPerDay :
            dataLimit
    }
    
    var dateUsedInPercentage: Int {
        return usedData.toPercentage(with: maxData)
    }
    
    // MARK: - Debug
    var debugDescription: String {
        """
            * AppState *
            
            - UI
              selectedItem: \(usageType)
              isNotifOn: \(isNotifOn)
            
            - Data
              dataAmount: \(dataAmount)
              dataLimitPerDay: \(dataLimitPerDay)
              dataLimit: \(dataLimit)

              startDate: \(startDate)
              endDate: \(endDate)
             
              todaysData: \(todaysData)
              weeksData: \(weeksData)
            
            """
    }
}
