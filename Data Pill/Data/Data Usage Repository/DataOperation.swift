//
//  DataOperation.swift
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
    /// Returns all ``Data`` from ``Database``.
    func getAllData() -> [Data] {
        do {
            /// 1. Request
            let request = NSFetchRequest<Data>(entityName: Entities.data.name)
            
            /// 2. Execute
            let result = try database.context.fetch(request)
            
            return result
            
        } catch let error {
            dataError = DatabaseError.gettingAll(error.localizedDescription)
            Logger.database.error("failed to get all data: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Returns the filtered ``Data`` from ``Database`` using the specified criteria.
    func getDataWith(format: String, _ args: CVarArg..., sortDescriptors: [NSSortDescriptor] = []) throws -> [Data] {
        /// 1. Request
        let request = NSFetchRequest<Data>(entityName: Entities.data.name)
        request.sortDescriptors = sortDescriptors
        request.predicate = .init(format: format, args)
        
        /// 2. Execute
        let result = try database.context.fetch(request)
        
        return result
    }
    
    /// Returns the ``Data`` with Today's Date from ``Database``
    /// and creates a new one if it doesn't exists.
    func getTodaysData() -> Data? {
        do {
            /// 1A. Retrieve Data
            let todaysDate = Calendar.current.startOfDay(for: .init())
            
            let dateAttribute = DataAttribute.date.rawValue
            var dataItems = try getDataWith(format: "\(dateAttribute) == %@", todaysDate as NSDate)
            
            /// 1B. Create if Non-existent
            if dataItems.isEmpty {
                Logger.database.debug("getTodaysData - not found, creating")
                addData(
                    date: Calendar.current.startOfDay(for: .init()),
                    totalUsedData: 0,
                    dailyUsedData: 0,
                    hasLastTotal: false,
                    isSyncedToRemote: false,
                    lastSyncedToRemoteDate: nil
                )
                /// 1A. Retrieve Data
                dataItems = try getDataWith(format: "\(dateAttribute) == %@", todaysDate as NSDate)
            }
            
            /// 2.
            let todaysData = dataItems.first
            Logger.database.debug("getTodaysData - data found: \(todaysData)")
            
            return todaysData
            
        } catch let error {
            dataError = DatabaseError.gettingTodaysData(error.localizedDescription)
            Logger.database.error("failed to get today's data: \(error.localizedDescription)")
            return nil
        }
    }
        
    /// Returns the recent ``Data`` that has a value set for `totalUsedData` from ``Database``.
    func getDataWithHasTotal() -> Data? {
        do {
            /// 1. Retrieve Data
            let hasLastTotalAttribute = DataAttribute.hasLastTotal.rawValue
            let dateAttribute = DataAttribute.date.rawValue
            let data: [Data] = try getDataWith(
                format: "\(hasLastTotalAttribute) == %@",
                true as NSNumber,
                sortDescriptors: [ .init(key: dateAttribute, ascending: false) ]
            )
            
            /// 2.
            let recentData = data.first
            
            return recentData
            
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            Logger.database.error("failed to filter data with has total: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns all ``Data`` for this Week from Sunday to Saturday with index from 1 to 7 from ``Database``.
    func getThisWeeksData(from todaysData: Data?) -> [Data] {
        
        /// 1A. Empty
        guard
            let todaysData = todaysData,
            let todaysDate = todaysData.date,
            let todaysWeek = todaysDate.toDateComp().weekday
        else {
            return []
        }
        
        /// 1B. Week Has Just Started
        guard todaysWeek > 1 else {
            return [todaysData]
        }
        
        let prevDaysOfWeekCount = todaysWeek - 1
        
        guard
            let firstDayOfWeekDate =
                Calendar.current.date(
                    byAdding: .day,
                    value: -prevDaysOfWeekCount,
                    to: todaysDate
                ),
            let tomorrowsDate = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: todaysDate
            )
        else {
            return [todaysData]
        }
        
        /// 1C. Filter to Get Weeks Data
        do {
            let dateAttribute = DataAttribute.date.rawValue
            let startDate = Calendar.current.startOfDay(for: firstDayOfWeekDate) as NSDate
            let endDate = Calendar.current.startOfDay(for: tomorrowsDate) as NSDate
            
            let thisWeeksData = try getDataWith(
                format: "(\(dateAttribute) >= %@) AND (\(dateAttribute) < %@)",
                startDate,
                endDate
            )
            
            Logger.database.debug("this weeks data dates: \(thisWeeksData.compactMap(\.date))")
            return thisWeeksData
            
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            Logger.database.error("failed to get weeks data: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Returns the total used ``Data`` from `startDate`  to `endDate` period from ``Database``.
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        do {
            /// 1. Filter Data
            let dateAttribute = DataAttribute.date.rawValue
            let currentPlanDataItems = try getDataWith(
                format: "(\(dateAttribute) >= %@) AND (\(dateAttribute) <= %@)",
                startDate as NSDate,
                endDate as NSDate
            )
            
            /// 2. Calculate Total Used Data
            let totalUsedData = currentPlanDataItems.reduce(0) { (acc, data) in
                return acc + data.dailyUsedData
            }
            
            return totalUsedData
            
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            Logger.database.error("failed to get total used data: \(error.localizedDescription)")
            return 0
        }
    }
    
    
    // MARK: - Add
    /// Saves a new ``Data``record  into ``Database``.
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool,
        isSyncedToRemote: Bool,
        lastSyncedToRemoteDate: Date?
    ) {
        do {
            /// 1A. Create Data
            let data = Data(context: database.context)
            data.date = date
            data.totalUsedData = totalUsedData
            data.dailyUsedData = dailyUsedData
            data.hasLastTotal = hasLastTotal
            
            /// 1B. Prevent from Setting Again
            if data.isSyncedToRemote != isSyncedToRemote {
                data.isSyncedToRemote = isSyncedToRemote
            }
            if data.lastSyncedToRemoteDate != lastSyncedToRemoteDate {
                data.lastSyncedToRemoteDate = lastSyncedToRemoteDate
            }
            
            /// 2. Save Data
            let isAdded = try database.context.saveIfNeeded()
            guard isAdded else {
                return
            }
            
            /// 3. Update Store
            updateToLatestData()
            
        } catch let error {
            dataError = DatabaseError.adding(error.localizedDescription)
            Logger.database.error("failed to add data: \(error.localizedDescription)")
        }
    }
    
    /// Saves multiple ``Data``records into ``Database`` efficiently
    /// and publishes whether it was successful or not.
    func addData(_ remoteData: [RemoteData], isSyncedToRemote: Bool) -> AnyPublisher<Bool, Never> {
        Future { promise in
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            backgroundContext.performAndWait {
                /// 1. New Batch Request
                let request = self.newBatchInsertRequest(remoteData, isSyncedToRemote: isSyncedToRemote)
                
                do {
                    /// 2. Execute Batch Request
                    let batchInsertResult = try backgroundContext.execute(request) as! NSBatchInsertResult
                    let addedIDs = batchInsertResult.result as! [NSManagedObjectID]
                    
                    Logger.database.debug("successful adding batch data result count: \(addedIDs.count)")
                    
                    /// 3. Update Store
                    self.updateToLatestData()
                    promise(.success(true))
                    
                } catch let error {
                    Logger.database.error("failed to add batch data: \(error.localizedDescription)")
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func newBatchInsertRequest(_ remoteDataList: [RemoteData], isSyncedToRemote: Bool) -> NSBatchInsertRequest {
        var index = 0
        let totalCount = remoteDataList.count
        
        let batchInsert = NSBatchInsertRequest(entityName: Entities.data.rawValue) { (managedObject: NSManagedObject) -> Bool in
            guard index < totalCount else {
                return true /// done inserting all
            }
            
            if let data = managedObject as? Data {
                let remoteData = remoteDataList[index]
                data.date = remoteData.date
                data.totalUsedData = 0.0
                data.dailyUsedData = remoteData.dailyUsedData
                data.hasLastTotal = true
                data.isSyncedToRemote = isSyncedToRemote
            }
            
            index += 1
            return false /// call the closure again
        }
        batchInsert.resultType = .objectIDs
        return batchInsert
    }
    
    
    // MARK: - Update
    /// Saves the existing Today's ``Data`` using the values specified into ``Database``.
    func updateTodaysData(
        date: Date?,
        totalUsedData: Double?,
        dailyUsedData: Double?,
        hasLastTotal: Bool?,
        isSyncedToRemote: Bool?,
        lastSyncedToRemoteDate: Date?
    ) {
        do {
            /// 1A. Retrieve Data
            guard let todaysData = getTodaysData() else {
                Logger.database.error("no today's data found despite creating one in update today's data block")
                return
            }
            
            /// 1B. Modify Data
            if let date {
                todaysData.date = date
            }
            if let totalUsedData {
                todaysData.totalUsedData = totalUsedData
            }
            if let dailyUsedData {
                todaysData.dailyUsedData = dailyUsedData
            }
            if let hasLastTotal {
                todaysData.hasLastTotal = hasLastTotal
            }
            if let isSyncedToRemote {
                todaysData.isSyncedToRemote = isSyncedToRemote
            }
            if let lastSyncedToRemoteDate {
                todaysData.lastSyncedToRemoteDate = lastSyncedToRemoteDate
            }
            
            /// 3. Save Data
            let isUpdated = try database.context.saveIfNeeded()
            
            /// 4. Update Store
            if isUpdated {
                updateToLatestData()
            }
            
        } catch let error {
            dataError = DatabaseError.updatingData(error.localizedDescription)
            Logger.database.error("failed to update today's data: \(error.localizedDescription)")
        }
    }
    
    /// Saves the existing multiple ``Data`` into ``Database``
    /// with the updated sync attributes `isSyncedToRemote` and `lastSyncedToRemoteDate`
    /// and publishes whether it was successful or not.
    ///
    /// - Parameter remoteData: The list of data to be updated.
    ///
    func updateData(_ remoteData: [RemoteData]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            let dataDatesToUpdate = remoteData.compactMap { $0.date }
            
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            backgroundContext.performAndWait {
                /// 1. Batch Request
                let request = self.newBatchUpdateRequest(dataDatesToUpdate)
                
                do {
                    /// 2. Execute Batch Request
                    let batchUpdateResult = try backgroundContext.execute(request) as! NSBatchUpdateResult
                    
                    /// 3. Update Changes
                    /// - this ensures the main context gets updated with our new changes
                    let updatedIDs = batchUpdateResult.result as! [NSManagedObjectID]
                    let changes = [NSUpdatedObjectsKey: updatedIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.database.context])
                    
                    Logger.database.debug("successful updating batch data result count: \(updatedIDs.count)")
                    promise(.success(true))
                    
                } catch let error {
                    Logger.database.error("failed to update batch data: \(error.localizedDescription)")
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func newBatchUpdateRequest(_ dates: [Date]) -> NSBatchUpdateRequest {
        let isSyncedToRemoteAttribute = "isSyncedToRemote"
        let lastSyncedToRemoteDateAttribute = "lastSyncedToRemoteDate"
        
        let batchUpdate = NSBatchUpdateRequest(entityName: Entities.data.rawValue)
        batchUpdate.propertiesToUpdate = [
            isSyncedToRemoteAttribute: true,
            lastSyncedToRemoteDateAttribute: Date()
        ]
        batchUpdate.predicate = NSPredicate(format: "ANY %K IN %@", #keyPath(Data.date), dates as [NSDate])
        batchUpdate.resultType = .updatedObjectIDsResultType
        return batchUpdate
    }
    
    /// Updates the Stores `thisWeeksData` and `todaysData`.
    /// This triggers republishers if this a depedency.
    func updateToLatestData() {
        thisWeeksData = getThisWeeksData(from: getTodaysData())
        todaysData = getTodaysData()
    }
    
    
    // MARK: - Delete
    /// Remotes all ``Data`` from ``Database``
    /// and publishes whether it was successful or not.
    func deleteAllData() -> AnyPublisher<Bool, Never> {
        Future { promise in
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            /// 1. Batch Request
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.data.name)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            backgroundContext.performAndWait {
                do {
                    /// 2. Execute Batch Request
                    let _ = try backgroundContext.execute(batchRequest)
                    
                    Logger.database.debug("successful deleting batch data")
                    promise(.success(true))
                    
                } catch let error {
                    Logger.database.error("failed to delete batch data: \(error.localizedDescription)")
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
