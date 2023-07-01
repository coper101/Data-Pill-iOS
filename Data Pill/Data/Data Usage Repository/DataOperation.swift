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

// MARK: - Add
extension DataUsageRepository {
        
    /// Add a new `Data` into `Database`.
    ///
    /// - Parameters:
    ///  - date:
    ///  - totalUsedDate:
    ///  - dailyUsedData:
    ///  - hasLastTotal:
    ///  - isSyncedToRemote:
    ///  - lastSyncedToRemoteDate:
    ///
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool,
        isSyncedToRemote: Bool,
        lastSyncedToRemoteDate: Date?
    ) {
        do {
            let data = Data(context: database.context)
            data.date = date
            data.totalUsedData = totalUsedData
            data.dailyUsedData = dailyUsedData
            data.hasLastTotal = hasLastTotal
            if data.isSyncedToRemote != isSyncedToRemote {
                data.isSyncedToRemote = isSyncedToRemote
            }
            if data.lastSyncedToRemoteDate != lastSyncedToRemoteDate {
                data.lastSyncedToRemoteDate = lastSyncedToRemoteDate
            }
            let isAdded = try database.context.saveIfNeeded()
            guard isAdded else {
                return
            }
            updateToLatestData()
        } catch let error {
            dataError = DatabaseError.adding(error.localizedDescription)
            Logger.database.error("failed to add data: \(error.localizedDescription)")
        }
    }
    
    /// Adds multiple `Data` into `Database`.
    ///
    /// - Parameters:
    ///  - remoteData:
    ///  - isSyncedToRemote:
    ///
    func addData(_ remoteData: [RemoteData], isSyncedToRemote: Bool) -> AnyPublisher<Bool, Never> {
        Future { promise in
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            backgroundContext.performAndWait {
                let request = self.newBatchInsertRequest(remoteData, isSyncedToRemote: isSyncedToRemote)
                
                do {
                    let batchInsertResult = try backgroundContext.execute(request) as! NSBatchInsertResult
                    let addedIDs = batchInsertResult.result as! [NSManagedObjectID]
                    // let changes = [NSUpdatedObjectsKey: addedIDs]
                    
                    Logger.database.debug("successful adding batch data result count: \(addedIDs.count)")
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
    
    /// Creates a batch request for adding multiple `Data`.
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
}


// MARK: - Update
extension DataUsageRepository {
        
    /// Update Today's `Data` from `Database`.
    ///
    /// - Parameters:
    ///  - date:
    ///  - totalUsedDate:
    ///  - dailyUsedData:
    ///  - hasLastTotal:
    ///  - isSyncedToRemote:
    ///  - lastSyncedToRemoteDate:
    ///
    func updateTodaysData(
        date: Date?,
        totalUsedData: Double?,
        dailyUsedData: Double?,
        hasLastTotal: Bool?,
        isSyncedToRemote: Bool?,
        lastSyncedToRemoteDate: Date?
    ) {
        do {
            guard let todaysData = getTodaysData() else {
                Logger.database.error("no today's data found despite creating one in update today's data block")
                return
            }
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
            let isUpdated = try database.context.saveIfNeeded()
            if isUpdated {
                updateToLatestData()
            }
        } catch let error {
            dataError = DatabaseError.updatingData(error.localizedDescription)
            Logger.database.error("failed to update today's data: \(error.localizedDescription)")
        }
    }
    
    /// Updates existing multiple `Data` from `Database`.
    ///
    /// - Parameter remoteData: The Data to be updated.
    ///
    func updateData(_ remoteData: [RemoteData]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            let dataDatesToUpdate = remoteData.compactMap { $0.date }
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            backgroundContext.performAndWait {
                let request = self.newBatchUpdateRequest(dataDatesToUpdate)
                
                do {
                    let batchUpdateResult = try backgroundContext.execute(request) as! NSBatchUpdateResult
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
    
    /// Creates a batch request for updating multiple `Data`.
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
    /// Triggers republishers if this a depedency.
    func updateToLatestData() {
        thisWeeksData = getThisWeeksData(from: getTodaysData())
        todaysData = getTodaysData()
    }
}


// MARK: - Delete
extension DataUsageRepository {
        
    /// Deletes multiple `Data` from `Database`.
    func deleteAllData() -> AnyPublisher<Bool, Never> {
        Future { promise in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.data.name)
            let batchRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            let backgroundContext = self.database.container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            backgroundContext.performAndWait {
                do {
                    try backgroundContext.execute(batchRequest)
                    
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


// MARK: - Read
extension DataUsageRepository {
    
    /// Retrieves all `Data` from `Database`.
    func getAllData() -> [Data] {
        do {
            let request = NSFetchRequest<Data>(entityName: Entities.data.name)
            return try database.context.fetch(request)
        } catch let error {
            dataError = DatabaseError.gettingAll(error.localizedDescription)
            Logger.database.error("failed to get all data: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Retrieve the filtered `Data` from `Database`.
    ///
    /// - Parameters:
    ///  - format:
    ///  - args:
    ///  - sortDescriptors:
    ///
    func getDataWith(format: String, _ args: CVarArg..., sortDescriptors: [NSSortDescriptor] = []) throws -> [Data] {
        let request = NSFetchRequest<Data>(entityName: Entities.data.name)
        request.sortDescriptors = sortDescriptors
        request.predicate = .init(format: format, args)
        return try database.context.fetch(request)
    }
    
    /// Retrieve the `Data` with Today's Date from `Database`
    /// and Creates a new one if it doesn't exists.
    func getTodaysData() -> Data? {
        do {
            let todaysDate = Calendar.current.startOfDay(for: .init())
            
            let dateAttribute = DataAttribute.date.rawValue
            var dataItems = try getDataWith(format: "\(dateAttribute) == %@", todaysDate as NSDate)
            
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
                dataItems = try getDataWith(format: "\(dateAttribute) == %@", todaysDate as NSDate)
            }
            
            let todaysData = dataItems.first
            Logger.database.debug("getTodaysData - data found: \(todaysData)")
            
            return todaysData
            
        } catch let error {
            dataError = DatabaseError.gettingTodaysData(error.localizedDescription)
            Logger.database.error("failed to get today's data: \(error.localizedDescription)")
            return nil
        }
    }
        
    /// Retrieves the recent `Data` that has a value set for Total Used Data from `Database`.
    func getDataWithHasTotal() -> Data? {
        do {
            let hasLastTotalAttribute = DataAttribute.hasLastTotal.rawValue
            let dateAttribute = DataAttribute.date.rawValue
            let data: [Data] = try getDataWith(
                format: "\(hasLastTotalAttribute) == %@",
                true as NSNumber,
                sortDescriptors: [
                    .init(key: dateAttribute, ascending: false)
                ]
            )
            return data.first
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            Logger.database.error("failed to filter data with has total: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Retrieves all the `Data` for this Week from Sunday to Saturday with index from 1 to 7 from `Database`.
    func getThisWeeksData(from todaysData: Data?) -> [Data] {
        // let todaysDate = "2022-10-31T10:44:00+0000".toDate() // Sunday
        guard
            let todaysData = todaysData,
            let todaysDate = todaysData.date,
            let todaysWeek = todaysDate.toDateComp().weekday
        else {
            return []
        }
        
        // if Sunday, dont get previous days as week has began
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
        
        do {
            let dateAttribute = DataAttribute.date.rawValue
            let thisWeeksData = try getDataWith(
                format: "(\(dateAttribute) >= %@) AND (\(dateAttribute) < %@)",
                Calendar.current.startOfDay(for: firstDayOfWeekDate) as NSDate,
                Calendar.current.startOfDay(for: tomorrowsDate) as NSDate
            )
            Logger.database.debug("this weeks data: \(thisWeeksData)")
            return thisWeeksData
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            Logger.database.error("failed to get weeks data: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Retrieves the total used `Data` from `startDate`  to `endDate` period from `Database`.
    ///
    /// - Parameters:
    ///  - startDate:
    ///  - endDate:
    ///
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        do {
            let dateAttribute = DataAttribute.date.rawValue
            let currentPlanDataItems = try getDataWith(
                format: "(\(dateAttribute) >= %@) AND (\(dateAttribute) <= %@)",
                startDate as NSDate,
                endDate as NSDate
            )
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
}
