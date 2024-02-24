//
//  TestData.swift
//  Data Pill
//
//  Created by Wind Versi on 13/3/23.
//

import CloudKit

class TestData {
    
    // MARK: - Dependencies
    static func createAppViewModel(
        activeSettingsScreen: SettingsScreen? = nil,
        wasGuideShown: Bool = true
    ) -> AppViewModel {
        let database = InMemoryLocalDatabase(container: .dataUsage, appGroup: .dataPill)
        let dataRepo = DataUsageRepository(database: database)
        let todaysDate = Date()
        
        /// Today's Data
        dataRepo.addData(
            date: Calendar.current.startOfDay(for: .init()),
            totalUsedData: 0,
            dailyUsedData: 0,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        
        /// 3 Days Ago
        dataRepo.addData(
            date: Calendar.current.date(
                byAdding: .day, value: -3, to: todaysDate)!,
            totalUsedData: 0,
            dailyUsedData: 1_500,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// 2 Days Ago
        dataRepo.addData(
            date: Calendar.current.date(
                byAdding: .day, value: -2, to: todaysDate)!,
            totalUsedData: 0,
            dailyUsedData: 5_000,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
        /// Yesterday
        dataRepo.addData(
            date: Calendar.current.date(
                byAdding: .day, value: -1, to: todaysDate)!,
            totalUsedData: 0,
            dailyUsedData: 2_100,
            hasLastTotal: true,
            isSyncedToRemote: false,
            lastSyncedToRemoteDate: nil
        )
       
        /// Update Database
        dataRepo.updatePlan(
            startDate: Calendar.current.date(
                byAdding: .day, value: -3, to: todaysDate)!,
            endDate: Calendar.current.date(
                byAdding: .day, value: 0, to: todaysDate)!,
            dataAmount: 10,
            dailyLimit: 4,
            planLimit: 9,
            updateToLatestPlanAfterwards: true
        )
        
        let appDataRepository = AppDataRepository()
        appDataRepository.setWasGuideShown(wasGuideShown)
        
        let viewModel = AppViewModel(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataRepo,
            dataUsageRemoteRepository: MockSuccessDataUsageRemoteRepository()
        )
                
        viewModel.activeSettingsScreen = activeSettingsScreen
        
        /// Update created Today's Data (added automatically by app)
        viewModel.refreshUsedDataToday(1000)
        
        return viewModel
    }
    
    // MARK: - Local
    static func createLocalData(completion: @escaping (Data?) -> Void)  {
        let database = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        database.loadContainer { _ in
            completion(nil)
        } onSuccess: {
            do {
                let data = Data(context: database.context)
                data.date = Calendar.current.startOfDay(for: .init())
                data.totalUsedData = 0
                data.dailyUsedData = 0
                data.hasLastTotal = true
                try database.context.saveIfNeeded()
                completion(data)
            } catch {
                completion(nil)
            }
        }
    }
    
    // MARK: - Remote
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
    
    // MARK: - CloudKit Record
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
    
    // MARK: - Date
    static func createDate(offset: Int, secondsOffset: Int = 0, from date: Date) -> Date {
        var date = Calendar.current.date(byAdding: .day, value: offset, to: date)!
        date = Calendar.current.date(byAdding: .second, value: secondsOffset, to: date)!
        return Calendar.current.startOfDay(for: date)
    }
    
    // MARK: - Local Data (Test)
    static let weeksDataSample: [DataTest] = [
        .init(
            date: "2022-10-09T10:44:00+0000".toDate(),
            dailyUsedData: 2_500
        ),
        .init(
            date: "2022-10-10T10:44:00+0000".toDate(),
            dailyUsedData: 1_480
        ),
        .init(
            date: "2022-10-11T10:44:00+0000".toDate(),
            dailyUsedData: 1_000
        ),
        .init(
            date: "2022-10-12T10:44:00+0000".toDate(),
            dailyUsedData: 800
        ),
        .init(
            date: "2022-10-13T10:44:00+0000".toDate(),
            dailyUsedData: 500
        ),
        .init(
            date: "2022-10-14T10:44:00+0000".toDate(),
            dailyUsedData: 250
        ),
        .init(
            date: "2022-10-15T10:44:00+0000".toDate(),
            dailyUsedData: 50
        )
    ]
    
    static let weeksDataWithMissingDaysSample: [DataTest] = [
        .init(
            date: "2022-10-10T10:44:00+0000".toDate(),
            dailyUsedData: 1_480
        ),
        .init(
            date: "2022-10-12T10:44:00+0000".toDate(),
            dailyUsedData: 800
        ),
        .init(
            date: "2022-10-14T10:44:00+0000".toDate(),
            dailyUsedData: 250
        )
    ]
    
    static let todaysDataSample = DataTest()
}
