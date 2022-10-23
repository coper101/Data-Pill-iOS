//
//  DataUsagePreview.swift
//  Data Pill
//
//  Created by Wind Versi on 9/10/22.
//

import Foundation

// Weeks Data
let weeksDataSample: [DataTest] = [
    .init(
        date: "2022-10-09T10:44:00+0000".toDate(),
        dailyUsedData: 50
    ),
    .init(
        date: "2022-10-10T10:44:00+0000".toDate(),
        dailyUsedData: 100
    ),
    .init(
        date: "2022-10-11T10:44:00+0000".toDate(),
        dailyUsedData: 300
    ),
    .init(
        date: "2022-10-12T10:44:00+0000".toDate(),
        dailyUsedData: 500
    ),
    .init(
        date: "2022-10-13T10:44:00+0000".toDate(),
        dailyUsedData: 800
    ),
    .init(
        date: "2022-10-14T10:44:00+0000".toDate(),
        dailyUsedData: 1_120
    ),
    .init(
        date: "2022-10-15T10:44:00+0000".toDate(),
        dailyUsedData: 1_500
    )
]

// Todays Data
let todaysDataSample = DataTest()
