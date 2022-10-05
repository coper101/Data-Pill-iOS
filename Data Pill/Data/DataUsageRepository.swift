//
//  DataUsageRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

protocol DataUsageRepositoryProtocol {
    func loadAllData() -> Void
//    func addData()
}

enum DatabaseError: Error, Equatable {
    case loadingContainer(String)
    case loadingAll(String)
    case adding(String)
    case updating(String)
    case removing(String)
    case gettingTodaysData(String)
    
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
        }
    }
    static func == (lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        lhs.id == rhs.id
    }
}

class DataUsageRepository: ObservableObject, DataUsageRepositoryProtocol {
    
    private let database: LocalDatabase<Data> = .init(container: .dataUsage, entity: .data)
    @Published var data: [Data] = .init()
    @Published var dataError: DatabaseError?
    
    init() {
        database.loadContainer { [weak self] error in
            self?.dataError = DatabaseError.loadingContainer(error.localizedDescription)
            print(error.localizedDescription)
        } onSuccess: { [weak self] in
            self?.loadAllData()
            self?.data.forEach { data in
                print("data: date: ", data.date)
            }
        }
    }
    
    /// loads Data Usage records from Database and stores them to this repository
    func loadAllData() {
        do {
            data = try database.getAllItems()
        } catch let error {
            dataError = DatabaseError.loadingAll(error.localizedDescription)
            print("load data error: ", error.localizedDescription)
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
            loadAllData()
            
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
            loadAllData()
            
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
            loadAllData()
            
        } catch let error {
            dataError = DatabaseError.removing(error.localizedDescription)
            print("remove data error: ", error.localizedDescription)
        }
    }
    
    /// gets Data with todays Date from Database
    func getTodaysData() -> Data? {
        do {
            let dataItems = try database.getItemsWith(format: "date = %@", Date() as NSDate)
            return dataItems.first
        } catch let error {
            dataError = DatabaseError.gettingTodaysData(error.localizedDescription)
            print("get todays data error: ", error.localizedDescription)
            return nil
        }
    }
    
    func totalUsedData() {
        
    }
}
