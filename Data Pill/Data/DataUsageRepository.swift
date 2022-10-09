//
//  DataUsageRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation
import CoreData

enum DatabaseError: Error, Equatable {
    case loadingContainer(String)
    case loadingAll(String)
    case adding(String)
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
    var thisWeeksData: [Data] { get set }
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { get }
    
    var dataError: DatabaseError? { get set }
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { get }
    
    func addData(
        date: Date,
        totalUsedData: Double,
        dailyUsedData: Double,
        hasLastTotal: Bool
    ) -> Void
    func updateData(item: Data) -> Void
    
    func getTodaysData() -> Data?
    func getDataWithHasTotal() -> Data?
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double
}


// MARK: - App Implementation
class DataUsageRepository: ObservableObject, DataUsageRepositoryProtocol {
    
    let database: LocalDatabase<Data> = .init(container: .dataUsage, entity: .data)
    
    @Published var thisWeeksData: [Data] = .init()
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
    
    init() {
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer(error.localizedDescription)
            print(error.localizedDescription)
        } onSuccess: { [weak self] in
            guard let self = self else {
                return
            }
            self.updateToLatestData()
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
            let isAdded = try database.addItem { data in
                data.date = date
                data.totalUsedData = totalUsedData
                data.dailyUsedData = dailyUsedData
                data.hasLastTotal = hasLastTotal
            }
            guard isAdded else {
                return
            }
            updateToLatestData()
            
        } catch let error {
            dataError = DatabaseError.adding(error.localizedDescription)
            print("add data error: ", error.localizedDescription)
        }
    }
    
    /// update an existing Data from Database
    func updateData(item: Data) {
        do {
            let isUpdated = try database.updateItem(item)
            guard isUpdated else {
                return
            }
            updateToLatestData()

        } catch let error {
            dataError = DatabaseError.updating(error.localizedDescription)
            print("update data error: ", error.localizedDescription)
        }
    }
    
    /// remove existing Data from Database
    func removeData(item: Data) {
        do {
            let isRemoved = try database.deleteItem(item)
            guard isRemoved else {
                return
            }
            updateToLatestData()

        } catch let error {
            dataError = DatabaseError.removing(error.localizedDescription)
            print("remove data error: ", error.localizedDescription)
        }
    }

}

extension DataUsageRepository {
    
    /// gets Data with todays Date from Database
    func getTodaysData() -> Data? {
        do {
            let todaysDate = Calendar.current.startOfDay(for: .init()) // time starts at 00:00
            let dateAttribute = DataAttribute.date.rawValue
            let dataItems = try database.getItemsWith(
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
            let data = try database.getItemsWith(
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
    func getThisWeeksData() -> [Data] {
        // let todaysDate = "2022-10-31T10:44:00+0000".toDate() // Sunday
        guard
            let todaysData = getTodaysData(),
            let todaysDate = todaysData.date,
            let todaysWeek = todaysDate.toDateComp().weekday
        else {
            return []
        }
        
        // if Sunday, dont get previous days as week has began
        if todaysWeek > 1 {
            return [todaysData]
        }
        
        let prevDaysOfWeekCount = todaysWeek - 1
        
        guard let firstDayOfWeekDate = Calendar.current.date(
            byAdding: .day,
            value: -prevDaysOfWeekCount,
            to: todaysDate
        ) else {
            return [todaysData]
        }
        
        do {
            let dateAttribute = DataAttribute.date.rawValue
            return try database.getItemsWith(
                format: "(\(dateAttribute) >= %@) AND (\(dateAttribute) <= %@)",
                Calendar.current.startOfDay(for: firstDayOfWeekDate) as NSDate,
                Calendar.current.startOfDay(for: todaysDate) as NSDate
            )
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            print("get weeks data error: ", error.localizedDescription)
            return []
        }
    }
    
    func getTotalUsedData(from startDate: Date, to endDate: Date) -> Double {
        do {
            let dateAttribute = DataAttribute.date.rawValue
            let currentPlanDataItems = try database.getItemsWith(
                format: "(\(dateAttribute) >= %@) AND (\(dateAttribute) <= %@)",
                startDate as NSDate,
                endDate as NSDate
            )
            return currentPlanDataItems
                .reduce(0) { acc, data in acc + data.dailyUsedData }
        } catch let error {
            dataError = DatabaseError.filteringData(error.localizedDescription)
            print("getTotalUsedData error: ", error.localizedDescription)
            return 0
        }
    }
    
    func updateToLatestData() {
        thisWeeksData = getThisWeeksData()
    }
    
}


// MARK: - Test Implementation
class DataUsageFakeRepository: ObservableObject, DataUsageRepositoryProtocol {
    
    // MARK: Data
    let database: LocalDatabase<Data> = .init(container: .dataUsage, entity: .data, storageType: .memory)
    
    @Published var thisWeeksData: [Data] = []
    var thisWeeksDataPublisher: Published<[Data]>.Publisher { $thisWeeksData }
    
    @Published var dataError: DatabaseError?
    var dataErrorPublisher: Published<DatabaseError?>.Publisher { $dataError }
        
    // MARK: Initializer
    init(
        thisWeeksData: [DataTest] = [],
        dataError: DatabaseError? = nil
    ) {
        self.dataError = dataError
        
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer(error.localizedDescription)
            print(error.localizedDescription)
        } onSuccess: { [weak self] in
            guard let self = self else {
                return
            }
            self.loadThisWeeksData(thisWeeksData)
        }
    }
    
    // MARK: Operations
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
