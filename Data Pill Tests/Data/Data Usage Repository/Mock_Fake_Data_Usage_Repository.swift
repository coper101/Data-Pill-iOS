//
//  Mock_Fake_Data_Usage_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

import Foundation
import Combine
import CoreData
import OSLog

final class DataUsageFakeRepository: ObservableObject, DataUsageRepositoryProtocol {

    let database: Database = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
    
    /// [1A] Data
    @Published var todaysData: Data_Pill.Data?
    var todaysDataPublisher: Published<Data_Pill.Data?>.Publisher { $todaysData }
    
    @Published var thisWeeksData: [Data_Pill.Data] = []
    var thisWeeksDataPublisher: Published<[Data_Pill.Data]>.Publisher { $thisWeeksData }
    
    /// [2A] Plan
    @Published var plan: Plan? = .init()
    var planPublisher: Published<Plan?>.Publisher { $plan }
    
    /// [3A] Error
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
        
    init(
        thisWeeksData: [DataTest] = [],
        dataError: DatabaseError? = nil
    ) {
        self.dataError = dataError
        
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer()
            Logger.database.error("- LOCAL DATABASE: 💾 😭 Failed to Load Container, ERROR: \(error.localizedDescription)")
        } onSuccess: { [weak self] in
            Logger.database.debug("- LOCAL DATABASE: 💾 ✅ Successfully Loaded Container")
            guard let self = self else {
                return
            }
            self.database.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.loadThisWeeksData(thisWeeksData)
        }
    }
    
    /// [1A] Data
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool,
        isSyncedToRemote: Bool,
        lastSyncedToRemoteDate: Date?
    ) {
        let dataEntity = NSEntityDescription.entity(
            forEntityName: Entities.data.rawValue,
            in: database.context
        )
        let uninsertedData = Data(entity: dataEntity!, insertInto: nil)
        uninsertedData.date = date
        uninsertedData.totalUsedData = totalUsedData
        uninsertedData.dailyUsedData = dailyUsedData
        uninsertedData.hasLastTotal = hasLastTotal
        uninsertedData.isSyncedToRemote = isSyncedToRemote
        uninsertedData.lastSyncedToRemoteDate = lastSyncedToRemoteDate
        thisWeeksData.append(uninsertedData)
    }
    
    func addData(_ remoteData: [RemoteData], isSyncedToRemote: Bool) -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    func updateTodaysData(
        date: Date?,
        totalUsedData: Double?,
        dailyUsedData: Double?,
        hasLastTotal: Bool?,
        isSyncedToRemote: Bool?,
        lastSyncedToRemoteDate: Date?
    ) {
    }
    
    func updateData(_ remoteData: [RemoteData]) -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    func deleteAllData() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    func getAllData(maxNumber: Int? = nil) -> [Data_Pill.Data] {
        []
    }
    
    func getDataWith(
        format: String, _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [Data_Pill.Data] {
        []
    }
    
    func getTodaysData() -> Data_Pill.Data? {
        if let data = thisWeeksData.first {
            return data
        }
        addData(
            date: TestData.todaysDataSample.date,
            totalUsedData: TestData.todaysDataSample.totalUsedData,
            dailyUsedData: TestData.todaysDataSample.dailyUsedData,
            hasLastTotal: TestData.todaysDataSample.hasLastTotal,
            isSyncedToRemote: TestData.todaysDataSample.isSyncedToRemote,
            lastSyncedToRemoteDate: TestData.todaysDataSample.lastSyncedDateToRemote
        )
        return thisWeeksData.first!
    }
    
    func getDataWithHasTotal() -> Data_Pill.Data? {
        getTodaysData()
    }
    
    func getTotalUsedData(
        from startDate: Date,
        to endDate: Date
    ) -> Double {
        100
    }
    
    func getThisWeeksData(from todaysData: Data_Pill.Data?) -> [Data_Pill.Data] {
        []
    }
    
    func loadThisWeeksData(_ dataTests: [DataTest]) {
        dataTests.forEach { data in
            addData(
                date: data.date,
                totalUsedData: data.totalUsedData,
                dailyUsedData: data.dailyUsedData,
                hasLastTotal: data.hasLastTotal,
                isSyncedToRemote: data.isSyncedToRemote,
                lastSyncedToRemoteDate: data.lastSyncedDateToRemote
            )
        }
    }
    
    func updateToLatestData() {}
        
    /// [2B] Plan
    func addPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) {}
    
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?,
        updateToLatestPlanAfterwards: Bool
    ) {}
    
    func getAllPlan() throws -> [Plan] {
        []
    }
    
    func getPlan() -> Plan? {
        nil
    }
    
    func updateToLatestPlan() {}
    
    func deleteAllPlan() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    /// [3B] Error
    func clearDataError() {}
    
}
