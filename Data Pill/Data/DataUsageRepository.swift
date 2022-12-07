//
//  DataUsageRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation
import CoreData

enum DatabaseError: Error, Equatable {
    case loadingContainer(String = "Sorry, the data can’t be loaded from the Storage.\n\nTry reinstalling the app")
    case loadingAll(String)
    case adding(String)
    case gettingAll(String)
    case updating(String)
    case removing(String)
    case gettingTodaysData(String)
    case filteringData(String)
    
    var id: String {
        switch self {
        case .loadingContainer(_):
            return "LoadingContainer"
        case .loadingAll(_):
            return "LoadingAll"
        case .adding(_):
            return "Adding"
        case .gettingAll(_):
            return "GettingAll"
        case .updating(_):
            return "Updating"
        case .removing(_):
            return "Removing"
        case .gettingTodaysData(_):
            return "GettingTodaysData"
        case .filteringData(_):
            return "FilteringData"
        }
    }
    static func == (lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        lhs.id == rhs.id
    }
}

private enum DataAttribute: String {
    case date
    case hasLastTotal
}

// MARK: - Protocol
protocol DataUsageRepositoryProtocol {
    var database: any Database { get }
    
    /// Data
    var thisWeeksData: [Data] { get set }
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { get }
    
    func addData(date: Date, totalUsedData: Double, dailyUsedData: Double, hasLastTotal: Bool) -> Void
    func updateData(_ data: Data) -> Void
    func getAllData() -> [Data]
    func getDataWith(format: String, _ args: CVarArg..., sortDescriptors: [NSSortDescriptor]) throws -> [Data]
    func getTodaysData() -> Data?
    func getDataWithHasTotal() -> Data?
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double
    func getThisWeeksData(from todaysData: Data?) -> [Data]
    
    /// Plan
    var plan: Plan? { get set }
    var planPublisher: Published<Plan?>.Publisher { get }
    
    func addPlan(startDate: Date, endDate: Date, dataAmount: Double, dailyLimit: Double, planLimit: Double) -> Void
    func getAllPlan() throws -> [Plan]
    func getPlan() -> Plan?
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?
    ) -> Void
    
    /// Error
    var dataError: DatabaseError? { get set }
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { get }
    func clearDataError()
}

extension DataUsageRepositoryProtocol {
    
    func updateData(_ data: Data) {
        
    }
    
    func addPlan(
        startDate: Date,
        endDate: Date, dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) {
        
    }
    
    func getDataWith(
        format: String,
        _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor]
    ) throws -> [Data] {
        []
    }
    
    func getTodaysData() -> Data? { nil }

    func getDataWithHasTotal() -> Data? { nil }

    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        0
    }

    func getThisWeeksData(from todaysData: Data?) -> [Data] {
        []
    }
    
    func getAllPlan() throws -> [Plan] {
        []
    }
    
    func getPlan() -> Plan? {
        nil
    }
    
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?
    ) {
    }

    func clearDataError() {}
    
}


// MARK: - App Implementation
final class DataUsageRepository: ObservableObject, DataUsageRepositoryProtocol {

    let database: Database
    
    /// Data
    @Published var thisWeeksData: [Data] = .init()
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    /// Plan
    @Published var plan: Plan?
    var planPublisher: Published<Plan?>.Publisher { $plan }
    
    /// Error
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
    
    init(database: Database) {
        self.database = database
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer()
            print("database error", error.localizedDescription)
        } onSuccess: { [weak self] in
            guard let self = self else {
                return
            }
            self.updateToLatestData()
            self.updateToLatestPlan()
        }
    }
    
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
            print("add data error: ", error.localizedDescription)
        }
    }
    
    /// updates an existing Data from the Database
    func updateData(_ data: Data) {
        do {
            let isUpdated = try database.context.saveIfNeeded()
            if isUpdated {
                updateToLatestData()
            }
        } catch let error {
            dataError = DatabaseError.updating(error.localizedDescription)
            print("update data error: ", error.localizedDescription)
        }
    }
    
    /// fetch all Data Usage records from Database
    func getAllData() -> [Data] {
        do {
            let request = NSFetchRequest<Data>(entityName: Entities.data.name)
            return try database.context.fetch(request)
        } catch let error {
            dataError = DatabaseError.gettingAll(error.localizedDescription)
            print("getting all data error: ", error.localizedDescription)
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
            dataError = DatabaseError.adding(error.localizedDescription)
            print("add plan error: ", error.localizedDescription)
        }
    }
    
    /// fetch all Data Plan records from Database
    func getAllPlan() throws -> [Plan] {
        let request = NSFetchRequest<Plan>(entityName: Entities.plan.name)
        return try database.context.fetch(request)
    }
    
    /// update the Data Plan from Database
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?
    ) {
        do {
            guard let plan = getPlan() else {
                print("no plan found despite creating one")
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
            try database.context.saveIfNeeded()
        } catch let error {
            dataError = DatabaseError.updating(error.localizedDescription)
            print("update plan error: ", error.localizedDescription)
        }
    }

}

extension DataUsageRepository {
    
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
            print("get todays data error: ", error.localizedDescription)
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
            print("filter data with has total data error: ", error.localizedDescription)
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
            print("get weeks data error: ", error.localizedDescription)
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
            print("getTotalUsedData error: ", error.localizedDescription)
            return 0
        }
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
            print("getting all plan error: ", error.localizedDescription)
            return nil
        }
    }
    
    func updateToLatestData() {
        thisWeeksData = getThisWeeksData(from: getTodaysData())
    }
    
    func updateToLatestPlan() {
        plan = getPlan()
    }
    
    func clearDataError() {
        dataError = nil
    }

}

// MARK: - Test Implementation
class DataUsageFakeRepository: ObservableObject, DataUsageRepositoryProtocol {

    let database: Database = LocalDatabase(container: .dataUsage, appGroup: nil)
    
    /// Data
    @Published var thisWeeksData: [Data] = []
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    /// Plan
    @Published var plan: Plan? = .init()
    var planPublisher: Published<Plan?>.Publisher { $plan }
    
    /// Error
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
        
    init(
        thisWeeksData: [DataTest] = [],
        dataError: DatabaseError? = nil
    ) {
        self.dataError = dataError
        
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer()
            print(error.localizedDescription)
        } onSuccess: { [weak self] in
            guard let self = self else {
                return
            }
            self.loadThisWeeksData(thisWeeksData)
        }
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
    
    func updateData(item: Data) {
        
    }
    
    func getAllData() -> [Data] {
        []
    }
    
    func removeData(item: Data)  {
        
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
    
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        100
    }
    
}

class MockErrorDataUsageRepository: DataUsageRepositoryProtocol {

    let database: Database
    
    /// Data
    @Published var thisWeeksData: [Data] = []
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    /// Plan
    @Published var plan: Plan? = .init()
    var planPublisher: Published<Plan?>.Publisher { $plan }
    
    /// Error
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
    
    init(database: Database) {
        self.database = database
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer()
            print("database error: ", error.localizedDescription)
        } onSuccess: { [weak self] in
            guard let _ = self else {
                return
            }
        }
    }
    
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool
    ) {
        dataError = DatabaseError.adding("Adding Error")
    }
    
    func getAllData() -> [Data] {
        dataError = DatabaseError.gettingAll("Get All Error")
        return []
    }
    
    func updateData(_ data: Data) {
        dataError = DatabaseError.updating("Update Error")
    }
    
    func clearDataError() {
        dataError = nil
    }

}
