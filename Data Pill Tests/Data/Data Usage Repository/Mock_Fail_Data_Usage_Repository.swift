//
//  Mock_Fail_Data_Usage_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CoreData
import OSLog

final class MockErrorDataUsageRepository: DataUsageRepositoryProtocol {
   
    let database: Database
    
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
    
    init(database: Database) {
        self.database = database
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer()
            Logger.database.error("failed to load container: \(error.localizedDescription)")
        } onSuccess: { [weak self] in
            guard let _ = self else {
                return
            }
        }
    }
    
    /// [1B] Data
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool,
        isSyncedToRemote: Bool,
        lastSyncedToRemoteDate: Date?
    ) {
        dataError = DatabaseError.adding("Adding Data Error")
    }
        
    func addData(_ remoteData: [RemoteData], isSyncedToRemote: Bool) -> AnyPublisher<Bool, Never>{
        Just(false).eraseToAnyPublisher()
    }
    
    func updateData(_ data: Data_Pill.Data) {
        dataError = DatabaseError.updatingData("Updating Data Error")
    }
    
    func updateData(_ remoteData: [RemoteData]) -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
    
    func getAllData() -> [Data_Pill.Data] {
        dataError = DatabaseError.gettingAll("Getting All Data Error")
        return []
    }
    
    func getDataWith(
        format: String, _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [Data_Pill.Data] {
        []
    }
    
    func getTodaysData() -> Data_Pill.Data? {
        dataError = DatabaseError.gettingTodaysData("Get Today's Date Error")
        return nil
    }
    
    func getDataWithHasTotal() -> Data_Pill.Data? {
        dataError = DatabaseError.filteringData("Filtering Data Error")
        return nil
    }
    
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        dataError = DatabaseError.filteringData("Filtering Data Error")
        return 0
    }
    
    func getThisWeeksData(from todaysData: Data_Pill.Data?) -> [Data_Pill.Data] {
        dataError = DatabaseError.filteringData("Filtering Data Error")
        return []
    }
    
    func updateToLatestData() {}
    
    /// [2B] Plan
    func getPlan() -> Plan? {
        dataError = DatabaseError.gettingPlan("Getting Plan Error")
        return nil
    }
    
    func addPlan(startDate: Date, endDate: Date, dataAmount: Double, dailyLimit: Double, planLimit: Double) {
        dataError = DatabaseError.addingPlan("Adding Plan Error")
    }
    
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?,
        updateToLatestPlanAfterwards: Bool
    ) {
        dataError = DatabaseError.updatingPlan("Updating Plan Error")
    }
    
    func getAllPlan() throws -> [Plan] {
        []
    }
    
    func updateToLatestPlan() {}
    
    /// [3B] Error
    func clearDataError() {
        dataError = nil
    }

}
