//
//  DataInfo.swift
//  Data Pill
//
//  Created by Wind Versi on 8/10/22.
//

import Foundation

struct UsedDataInfo {
    var wifiReceived: UInt64 = 0
    var wifiSent: UInt64 = 0
    var wirelessWanDataReceived: UInt64 = 0
    var wirelessWanDataSent: UInt64 = 0

    mutating func updateInfoByAdding(_ info: Self) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}

extension UsedDataInfo: Equatable {
    
    static func == (lhs: UsedDataInfo, rhs: UsedDataInfo) -> Bool {
        return
            (lhs.wifiReceived == rhs.wifiReceived) &&
            (lhs.wifiSent == rhs.wifiSent) &&
            (lhs.wirelessWanDataReceived == rhs.wirelessWanDataReceived) &&
            (lhs.wirelessWanDataSent == rhs.wirelessWanDataSent)
    }
    
}
