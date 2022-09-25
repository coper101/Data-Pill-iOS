//
//  AppState.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation

class AppState: ObservableObject, CustomDebugStringConvertible {
    
    // MARK: - UI
    /// Usage - Plan or Daily
    @Published var selectedItem: Item = .item2
    /// Notification
    @Published var isNotifOn = false
    @Published var isHistoryShown = false
    @Published var isBlurVisibleHistory = false
    @Published var isBlurVisibleDataPlan = false
    
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
    /// Data plan
    @Published var startDate = "2022-09-12T10:44:00+0000".toDate()
    @Published var endDate = "2022-10-12T10:44:00+0000".toDate()
    @Published var dataAmount = 10.0 /// in GB
    @Published var dataLimit = 0.0
    
    var numOfDaysOfPlan: Int {
        startDate.toNumOfDays(to: endDate)
    }
    
    /// Daily data plan
    @Published var dataLimitPerDay = 0.0 /// in GB
    
    /// Data usage per day
    @Published var data: [Data] = [
        // Sun to Sat 11-17 sep
        .init(
            date: "2022-09-11T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-12T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-13T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-14T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-15T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-16T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-17T10:44:00+0000".toDate()
        ),
        // Sun to Sat 18-24 sep
        .init(
            date: "2022-09-18T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-19T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-20T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-21T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-22T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-23T10:44:00+0000".toDate()
        ),
        .init(
            date: "2022-09-24T10:44:00+0000".toDate()
        ),
        // Sun to Sat 25 Sep 1 Oct
        .init(
            date: "2022-09-25T10:44:00+0000".toDate(),
            dataUsed: 0.07
        )
    ]
    
    var todaysData: Data {
        let data = data.first { data in
            data.date.isToday()
        }
        return data ?? Data(date: Date())
    }
    
    var weeksData: [Data] {
        weekData(data)
    }
    
    // MARK: Init
    init() {
        dataLimitPerDay = dataAmount / Double(numOfDaysOfPlan)
        dataLimit = dataAmount - 1
    }
    
    var debugDescription: String {
        """
            selectedItem: \(selectedItem)
            dataAmount: \(dataAmount)
            dataLimitPerDay: \(dataLimitPerDay)
            dataLimit: \(dataLimit)
            todaysData: \(todaysData)
            weeksData: \(weeksData)
            """
    }
}
