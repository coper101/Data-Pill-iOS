//
//  PlanOperation.swift
//  Data Pill
//
//  Created by Wind Versi on 1/7/23.
//

import Foundation
import Combine
import CoreData
import OSLog

// MARK: - Add
extension DataUsageRepository {
    
    /// Add a new `Plan` into Database.
    ///
    /// - Parameters:
    ///  - startDate:
    ///  - endDate:
    ///  - dataAmount:
    ///  - dailyLimit:
    ///  - planLimit:
    ///
    func addPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) {
        do {
            let plan = Plan(context: database.context)
            plan.startDate = startDate
            plan.endDate = endDate
            plan.dataAmount = dataAmount
            plan.dailyLimit = dailyLimit
            plan.planLimit = planLimit
            try database.context.saveIfNeeded()
        } catch let error {
            dataError = DatabaseError.addingPlan(error.localizedDescription)
            Logger.database.error("failed to add plan: \(error.localizedDescription)")
        }
    }
}


// MARK: - Update
extension DataUsageRepository {
    
    /// Update the existing `Plan` from `Database`.
    ///
    /// - Parameters:
    ///  - startDate:
    ///  - endDate:
    ///  - dataAmount:
    ///  - dailyLimit:
    ///  - planLimit:
    ///  - updateToLatestPlanAfterwards: Calls ``updateToLatestPlan()`` if True
    ///
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?,
        updateToLatestPlanAfterwards: Bool
    ) {
        do {
            guard let plan = getPlan() else {
                Logger.database.error("no plan found despite creating one in update plan block")
                return
            }
            if let startDate {
                plan.startDate = startDate
            }
            if let endDate {
                plan.endDate = endDate
            }
            if let dataAmount {
                plan.dataAmount = dataAmount
            }
            if let dailyLimit {
                plan.dailyLimit = dailyLimit
            }
            if let planLimit {
                plan.planLimit = planLimit
            }
            let isUpdated = try database.context.saveIfNeeded()
            if isUpdated && updateToLatestPlanAfterwards {
                updateToLatestPlan()
            }
        } catch let error {
            dataError = DatabaseError.updatingPlan(error.localizedDescription)
            Logger.database.error("failed to update plan: \(error.localizedDescription)")
        }
    }
    
    /// Updates the Store `plan`.
    /// Triggers republishers if this a depedency.
    func updateToLatestPlan() {
        plan = getPlan()
    }
}


// MARK: - Delete
extension DataUsageRepository {

    /// Deletes all `Plan` from `Database`.
    func deleteAllPlan() -> AnyPublisher<Bool, Never> {
        Future { promise in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.plan.name)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            backgroundContext.performAndWait {
                do {
                    _ = try backgroundContext.execute(batchRequest)
                    
                    Logger.database.debug("successful deleting batch plan")
                    promise(.success(true))
                    
                } catch let error {
                    Logger.database.error("failed to delete batch plan: \(error.localizedDescription)")
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


// MARK: - Read
extension DataUsageRepository {
    
    /// Retrieves all `Plan`  from `Database`.
    func getAllPlan() throws -> [Plan] {
        database.context.refreshAllObjects()
        let request = NSFetchRequest<Plan>(entityName: Entities.plan.name)
        return try database.context.fetch(request)
    }
    
    /// Retrieves the `Plan` from `Database`
    /// and Creates a new one if it doesn't exists.
    func getPlan() -> Plan? {
        do {
            guard let plan = try getAllPlan().first else {
                Logger.database.debug("getPlan - not found, creating")
                addPlan(
                    startDate: Calendar.current.startOfDay(for: .init()),
                    endDate: Calendar.current.startOfDay(for: .init()),
                    dataAmount: 0,
                    dailyLimit: 0,
                    planLimit: 0
                )
                return try getAllPlan().first
            }
            return plan
        } catch let error {
            dataError = DatabaseError.gettingAll(error.localizedDescription)
            Logger.database.error("failed to get all plan: \(error.localizedDescription)")
            return nil
        }
    }
}
