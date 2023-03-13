//
//  TestData.swift
//  Data Pill
//
//  Created by Wind Versi on 13/3/23.
//

import CloudKit

class TestData {
    
    static func createEmptyRemotePlan() -> RemotePlan {
        RemotePlan(
            startDate: Calendar.current.startOfDay(for: .init()),
            endDate: Calendar.current.startOfDay(for: .init()),
            dataAmount: 0,
            dailyLimit: 0,
            planLimit: 0
        )
    }
    
    static func createEmptyRemoteData() -> RemoteData {
        RemoteData(
            date: Calendar.current.startOfDay(for: .init()),
            dailyUsedData: 0
        )
    }
    
    static func createPlanRecord(
        startDate: Date = Calendar.current.startOfDay(for: .init()),
        endDate: Date = Calendar.current.startOfDay(for: .init()),
        dataAmount: Double = 0,
        dailyLimit: Double = 0,
        planLimit: Double = 0
    ) -> CKRecord {
        let remotePlan = RemotePlan(
            startDate: startDate,
            endDate: endDate,
            dataAmount: dataAmount,
            dailyLimit: dailyLimit,
            planLimit: planLimit
        )
        let planRecord = CKRecord(recordType: RecordType.plan.rawValue)
        planRecord.setValuesForKeys(remotePlan.toDictionary())
        return planRecord
    }
    
    static func createDataRecord(
        date: Date = Calendar.current.startOfDay(for: .init()),
        dailyUsedData: Double = 0
    ) -> CKRecord {
        let remoteData = RemoteData(
            date: date,
            dailyUsedData: dailyUsedData
        )
        let dataRecord = CKRecord(recordType: RecordType.data.rawValue)
        dataRecord.setValuesForKeys(remoteData.toDictionary())
        return dataRecord
    }
}
