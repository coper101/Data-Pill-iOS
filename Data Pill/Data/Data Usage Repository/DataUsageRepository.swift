//
//  DataUsageRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation
import Combine
import CoreData
import OSLog

// MARK: - Protocol
protocol DataUsageRepositoryProtocol {
    
    // MARK: - Dependencies
    var database: any Database { get }
    
    // MARK: - Data
    /// - Store
    var todaysData: Data? { get set }
    var todaysDataPublisher: Published<Data?>.Publisher { get }
    
    var thisWeeksData: [Data] { get set }
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { get }
    
    /// - Read
    func getAllData() -> [Data]
    
    func getDataWith(format: String, _ args: CVarArg..., sortDescriptors: [NSSortDescriptor]) throws -> [Data]
    
    func getTodaysData() -> Data?
    
    func getDataWithHasTotal() -> Data?
    
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double
    
    func getThisWeeksData(from todaysData: Data?) -> [Data]
    
    /// - Add
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool,
        isSyncedToRemote: Bool,
        lastSyncedToRemoteDate: Date?
    ) -> Void
    
    func addData(_ remoteData: [RemoteData], isSyncedToRemote: Bool) -> AnyPublisher<Bool, Never>
    
    /// - Update
    func updateTodaysData(
        date: Date?,
        totalUsedData: Double?,
        dailyUsedData: Double?,
        hasLastTotal: Bool?,
        isSyncedToRemote: Bool?,
        lastSyncedToRemoteDate: Date?
    ) -> Void
    
    func updateData(_ remoteData: [RemoteData]) -> AnyPublisher<Bool, Never>
    
    func updateToLatestData() -> Void
    
    /// - Delete
    func deleteAllData() -> AnyPublisher<Bool, Never>

            
    // MARK: - Plan
    /// - Store
    var plan: Plan? { get set }
    var planPublisher: Published<Plan?>.Publisher { get }
    
    /// - Read
    func getPlan() -> Plan?
    
    func getAllPlan() throws -> [Plan]
    
    /// - Add
    func addPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> Void
    
    /// - Update
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?,
        updateToLatestPlanAfterwards: Bool
    ) -> Void
    
    func updateToLatestPlan() -> Void
    
    /// - Delete
    func deleteAllPlan() -> AnyPublisher<Bool, Never>
    
    
    // MARK: - Error
    /// - Store
    var dataError: DatabaseError? { get set }
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { get }
    
    func clearDataError()
}



// MARK: - App Implementation
final class DataUsageRepository: ObservableObject, DataUsageRepositoryProtocol {

    // MARK: - Dependencies
    let database: Database
    
    
    // MARK: - Data
    @Published var todaysData: Data?
    var todaysDataPublisher: Published<Data?>.Publisher { $todaysData }
    
    @Published var thisWeeksData: [Data] = .init()
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    
    // MARK: - Plan
    @Published var plan: Plan?
    var planPublisher: Published<Plan?>.Publisher { $plan }
    
    
    // MARK: - Error
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
    
    
    // MARK: - Initializer
    init(database: Database) {
        self.database = database
        database.loadContainer { [weak self] (error: Error) in
            guard let error = error as NSError? else {
                return
            }
            self?.dataError = DatabaseError.loadingContainer()
            Logger.database.error("failed to load container: \(error.debugDescription)")

        } onSuccess: { [weak self] in
            guard let self = self else {
                return
            }
            Logger.database.debug("successfully loaded DataUsage container")
            self.database.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.database.context.automaticallyMergesChangesFromParent = true
            self.updateToLatestData()
            self.updateToLatestPlan()
        }
    }
}
