//
//  DataUsageRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation
import CoreData
import OSLog

enum DatabaseError: Error, Equatable {
    
    /// Database
    case loadingContainer(String = "Sorry, the data can’t be loaded from the Storage.")
    
    /// [1] Data
    case loadingAll(String)
    case adding(String)
    case updatingData(String)
    case gettingAll(String)
    case gettingTodaysData(String)
    case filteringData(String)
    
    /// [2] Plan
    case gettingPlan(String)
    case addingPlan(String)
    case updatingPlan(String)
    
    var id: String {
        switch self {
        case .loadingContainer(_):
            return "LoadingContainer"
        case .loadingAll(_):
            return "LoadingAll"
        case .adding(_):
            return "Adding"
        case .updatingData(_):
            return "UpdatingData"
        case .gettingAll(_):
            return "GettingAll"
        case .gettingTodaysData(_):
            return "GettingTodaysData"
        case .filteringData(_):
            return "FilteringData"
        case .gettingPlan(_):
            return "GettingPlan"
        case .addingPlan(_):
            return "AddingPlan"
        case .updatingPlan(_):
            return "UpdatingPlan"
        }
    }
    
    static func == (lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        lhs.id == rhs.id
    }
}
    
private enum DataAttribute: String {
    case date
    case dailyUsedData
    case totalUsedData
    case hasLastTotal
}



// MARK: - Protocol
protocol DataUsageRepositoryProtocol {
    var database: any Database { get }
    
    /// [1] Data
    var todaysData: Data? { get set }
    var todaysDataPublisher: Published<Data?>.Publisher { get }
    
    var thisWeeksData: [Data] { get set }
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { get }
    
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool
    ) -> Void
    func addData(_ remoteData: [RemoteData]) -> Void
    func updateData(_ data: Data) -> Void
    func getAllData() -> [Data]
    func getDataWith(
        format: String,
        _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [Data]
    func getTodaysData() -> Data?
    func getDataWithHasTotal() -> Data?
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double
    func getThisWeeksData(from todaysData: Data?) -> [Data]
    func updateToLatestData() -> Void
    
    /// [2] Plan
    var plan: Plan? { get set }
    var planPublisher: Published<Plan?>.Publisher { get }
    
    func addPlan(startDate: Date, endDate: Date, dataAmount: Double, dailyLimit: Double, planLimit: Double) -> Void
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?,
        updateToLatestPlanAfterwards: Bool
    ) -> Void
    func getAllPlan() throws -> [Plan]
    func getPlan() -> Plan?
    func updateToLatestPlan() -> Void
    
    /// [3] Error
    var dataError: DatabaseError? { get set }
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { get }
    func clearDataError()
}



// MARK: - App Implementation
final class DataUsageRepository: ObservableObject, DataUsageRepositoryProtocol {

    let database: Database
    
    /// [1A] Data
    @Published var todaysData: Data?
    var todaysDataPublisher: Published<Data?>.Publisher { $todaysData }
    
    @Published var thisWeeksData: [Data] = .init()
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    /// [2A] Plan
    @Published var plan: Plan?
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
            guard let self = self else {
                return
            }
            Logger.database.debug("successfully loaded DataUsage container")
            self.database.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.updateToLatestData()
            self.updateToLatestPlan()
        }
    }

}

// MARK: [1B] Data
extension DataUsageRepository {
    
    /// add a new Data Usage record into Database
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool
    ) {
        do {
            let data = Data(context: database.context)
            data.date = date
            data.totalUsedData = totalUsedData
            data.dailyUsedData = dailyUsedData
            data.hasLastTotal = hasLastTotal
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
    
    /// add multiple data
    func addData(_ remoteData: [RemoteData]) {
        database.container.performBackgroundTask { [weak self] taskContext in
            guard let self else {
                return
            }
            
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            // let batchInsert = NSBatchInsertRequest(entityName: Entities.data.name, objects: objects)
            let batchInsert = self.newBatchInsertRequest(remoteData)
            
            do {
                try taskContext.execute(batchInsert)
                Logger.database.error("successful adding batch data")
            } catch let error {
                Logger.database.error("failed to add batch data: \(error.localizedDescription)")
            }
            
        }
    }
    
    private func newBatchInsertRequest(_ remoteDataList: [RemoteData]) -> NSBatchInsertRequest {
        var index = 0
        let totalCount = remoteDataList.count
        
        let batchInsert = NSBatchInsertRequest(entityName: Entities.data.rawValue) { (managedObject: NSManagedObject) -> Bool in
            guard index < totalCount else {
                return true // done inserting all
            }
            
            if let data = managedObject as? Data {
                let remoteData = remoteDataList[index]
                data.date = remoteData.date
                data.totalUsedData = 0.0
                data.dailyUsedData = remoteData.dailyUsedData
                data.hasLastTotal = true
            }
            
            index += 1
            return false // call the closure again
        }
        return batchInsert
    }
    
    /// updates an existing Data from the Database
    func updateData(_ data: Data) {
        print("updating data in \(database.container.persistentStoreDescriptions), with \(data)")
        do {
            let isUpdated = try database.context.saveIfNeeded()
            if isUpdated {
                updateToLatestData()
            }
        } catch let error {
            dataError = DatabaseError.updatingData(error.localizedDescription)
            Logger.database.error("failed to update data: \(error.localizedDescription)")
        }
    }
    
    /// fetch all Data Usage records from Database
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
    
    /// fetch filtered Data Usage from Database
    func getDataWith(
        format: String,
        _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor] = []
    ) throws -> [Data] {
        let request = NSFetchRequest<Data>(entityName: Entities.data.name)
        request.sortDescriptors = sortDescriptors
        request.predicate = .init(format: format, args)
        return try database.context.fetch(request)
    }
    
    /// gets Data with todays Date from Database
    func getTodaysData() -> Data? {
        do {
            let todaysDate = Calendar.current.startOfDay(for: .init()) // time starts at 00:00
            let dateAttribute = DataAttribute.date.rawValue
            let dataItems = try getDataWith(
                format: "\(dateAttribute) == %@",
                todaysDate as NSDate
            )
            return dataItems.first
        } catch let error {
            dataError = DatabaseError.gettingTodaysData(error.localizedDescription)
            Logger.database.error("failed to get today's data: \(error.localizedDescription)")
            return nil
        }
    }
        
    /// gets the recent Data that has a value set for Total Used Data
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
    
    /// gets all the Data for this Week from Sunday to Saturday with index from 1 to 7
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
            return thisWeeksData
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            Logger.database.error("failed to get weeks data: \(error.localizedDescription)")
            return []
        }
    }
    
    /// gets the total used Data from start date period to end date period
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
    
    func updateToLatestData() {
        thisWeeksData = getThisWeeksData(from: getTodaysData())
        todaysData = getTodaysData()
    }

}

// MARK: [2B] Plan
extension DataUsageRepository {
    
    /// add a new Data Plan record into Database
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
    
    /// update the Data Plan from Database
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
    
    /// fetch all Data Plan records from Database
    func getAllPlan() throws -> [Plan] {
        database.context.refreshAllObjects()
        let request = NSFetchRequest<Plan>(entityName: Entities.plan.name)
        return try database.context.fetch(request)
    }
    
    /// gets the Plan record from the database
    /// creates a new one if none
    func getPlan() -> Plan? {
        do {
            guard let plan = try getAllPlan().first else {
                addPlan(
                    startDate: Calendar.current.startOfDay(for: .init()),
                    endDate: Calendar.current.startOfDay(for: .init()),
                    dataAmount: 0,
                    dailyLimit: 0,
                    planLimit: 0
                )
                return try getAllPlan().first!
            }
            return plan
        } catch let error {
            dataError = DatabaseError.gettingAll(error.localizedDescription)
            Logger.database.error("failed to get all plan: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateToLatestPlan() {
        plan = getPlan()
    }
    
}

// MARK: [3B] Error
extension DataUsageRepository {
    
    func clearDataError() {
        dataError = nil
    }
}



// MARK: - Test Implementation
// Used for Swift UI Preview
class DataUsageFakeRepository: ObservableObject, DataUsageRepositoryProtocol {

    let database: Database = InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
    
    /// [1A] Data
    @Published var todaysData: Data?
    var todaysDataPublisher: Published<Data?>.Publisher { $todaysData }
    
    @Published var thisWeeksData: [Data] = []
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
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
            Logger.database.error("failed to load container: \(error.localizedDescription)")
        } onSuccess: { [weak self] in
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
        hasLastTotal: Bool
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
        thisWeeksData.append(uninsertedData)
    }
    
    func addData(_ remoteData: [RemoteData]) {
        
    }
    
    func updateData(_ item: Data) {

    }
    
    func getAllData() -> [Data] {
        []
    }
    
    func getDataWith(
        format: String, _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [Data] {
        []
    }
    
    func getTodaysData() -> Data? {
        if let data = thisWeeksData.first {
            return data
        }
        addData(
            date: todaysDataSample.date,
            totalUsedData: todaysDataSample.totalUsedData,
            dailyUsedData: todaysDataSample.dailyUsedData,
            hasLastTotal: todaysDataSample.hasLastTotal
        )
        return thisWeeksData.first!
    }
    
    func getDataWithHasTotal() -> Data? {
        getTodaysData()
    }
    
    func getTotalUsedData(
        from startDate: Date,
        to endDate: Date
    ) -> Double {
        100
    }
    
    func getThisWeeksData(from todaysData: Data?) -> [Data] {
        []
    }
    
    func loadThisWeeksData(_ dataTests: [DataTest]) {
        dataTests.forEach { data in
            addData(
                date: data.date,
                totalUsedData: data.totalUsedData,
                dailyUsedData: data.dailyUsedData,
                hasLastTotal: data.hasLastTotal
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
    
    /// [3B] Error
    func clearDataError() {}
    
}

class MockErrorDataUsageRepository: DataUsageRepositoryProtocol {
   
    let database: Database
    
    /// [1A] Data
    @Published var todaysData: Data?
    var todaysDataPublisher: Published<Data?>.Publisher { $todaysData }
    
    @Published var thisWeeksData: [Data] = []
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
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
        hasLastTotal: Bool
    ) {
        dataError = DatabaseError.adding("Adding Data Error")
    }
        
    func addData(_ remoteData: [RemoteData]) {
        
    }
    
    func updateData(_ data: Data) {
        dataError = DatabaseError.updatingData("Updating Data Error")
    }
    
    func getAllData() -> [Data] {
        dataError = DatabaseError.gettingAll("Getting All Data Error")
        return []
    }
    
    func getDataWith(
        format: String, _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [Data] {
        []
    }
    
    func getTodaysData() -> Data? {
        dataError = DatabaseError.gettingTodaysData("Get Today's Date Error")
        return nil
    }
    
    func getDataWithHasTotal() -> Data? {
        dataError = DatabaseError.filteringData("Filtering Data Error")
        return nil
    }
    
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        dataError = DatabaseError.filteringData("Filtering Data Error")
        return 0
    }
    
    func getThisWeeksData(from todaysData: Data?) -> [Data] {
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
