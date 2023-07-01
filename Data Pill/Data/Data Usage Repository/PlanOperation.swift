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

extension DataUsageRepository {
    
    // MARK: - Read
    /// Returns the existing ``Plan`` record from ``Database``.
    /// It creates a new one if it doesn't exists.
    func getPlan() -> Plan? {
        do {
            /// 1A. Retrieve Plan
            guard let plan = try getAllPlan().first else {
                Logger.database.debug("getPlan - not found, creating")
                
                /// 1B. Create Plan
                addPlan(
                    startDate: Calendar.current.startOfDay(for: .init()),
                    endDate: Calendar.current.startOfDay(for: .init()),
                    dataAmount: 0,
                    dailyLimit: 0,
                    planLimit: 0
                )
                
                /// 1A. Retrieve Plan
                return try getAllPlan().first
            }
            return plan
        } catch let error {
            dataError = DatabaseError.gettingAll(error.localizedDescription)
            Logger.database.error("failed to get all plan: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns  all ``Plan`` records  from ``Database``.
    func getAllPlan() throws -> [Plan] {
        database.context.refreshAllObjects()
        
        /// 1. Request
        let request = NSFetchRequest<Plan>(entityName: Entities.plan.name)
        
        /// 2. Execute
        let result = try database.context.fetch(request)
        
        return result
    }

    
    // MARK: - Add
    /// Save a new ``Plan``record into Database.
    func addPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) {
        do {
            /// 1. Create Plan
            let plan = Plan(context: database.context)
            plan.startDate = startDate
            plan.endDate = endDate
            plan.dataAmount = dataAmount
            plan.dailyLimit = dailyLimit
            plan.planLimit = planLimit
            
            /// 2. Save Plan
            let _ = try database.context.saveIfNeeded()
            
        } catch let error {
            dataError = DatabaseError.addingPlan(error.localizedDescription)
            Logger.database.error("failed to add plan: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Update
    /// Save the existing ``Plan`` record into ``Database``.
    ///
    /// - Parameters:
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
            /// 1A. Retrieve Plan
            guard let plan = getPlan() else {
                Logger.database.error("no plan found despite creating one in update plan block")
                return
            }
            
            /// 1B. Modify Plan
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
            
            /// 2. Save Plan
            let isUpdated = try database.context.saveIfNeeded()
            
            /// 3. Update Store
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

    
    // MARK: - Delete
    /// Removes all ``Plan`` from ``Database``
    /// and publishes whether it was successul or not
    func deleteAllPlan() -> AnyPublisher<Bool, Never> {
        Future { promise in
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            /// 1. Batch Request
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.plan.name)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            backgroundContext.performAndWait {
                do {
                    /// 2. Execute Batch Request
                    let _ = try backgroundContext.execute(batchRequest)
                    
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
