//
//  AppState.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation

class AppState: ObservableObject {
    
    @Published var selectedItem: Item = .item1
    @Published var isTurnedOn = false
    
    @Published var days: [DayPill] = [
        .init(color: .secondaryBlue, day: .sunday),
        .init(color: .secondaryPurple, day: .monday),
        .init(color: .secondaryGreen, day: .tuesday),
        .init(color: .secondaryRed, day: .wednesday),
        .init(color: .secondaryOrange, day: .thursday),
        .init(color: .secondaryPurple, day: .friday),
        .init(color: .secondaryBlue, day: .saturday)
    ]
        
    @Published var data: [Data] = [
//        .init(
//            date: "2020-09-11T10:44:00+0000".toDate(),
//            percentageUsed: 100
//        ),
        .init(
            date: "2022-09-12T10:44:00+0000".toDate(),
            percentageUsed: 80
        ),
        .init(
            date: "2022-09-13T10:44:00+0000".toDate(),
            percentageUsed: 42
        ),
        .init(
            date: "2022-09-14T10:44:00+0000".toDate(),
            percentageUsed: 45
        ),
        .init(
            date: "2022-09-15T10:44:00+0000".toDate(),
            percentageUsed: 50
        ),
        .init(
            date: "2022-09-16T10:44:00+0000".toDate(),
            percentageUsed: 42
        ),
        .init(
            date: "2022-09-17T10:44:00+0000".toDate(),
            percentageUsed: 20
        ),
        .init(
            date: "2022-09-18T10:44:00+0000".toDate(),
            percentageUsed: 34
        )
    ]
    
}
