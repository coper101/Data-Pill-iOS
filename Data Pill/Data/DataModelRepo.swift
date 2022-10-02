//
//  DataModelRepo.swift
//  Data Pill
//
//  Created by Wind Versi on 3/10/22.
//

import Foundation

class DataModelRepository: ObservableObject {
    
    private let database: AppDatabase<Data> = .init(container: .dataUsage, entity: .data)
    @Published var data: [Data] = .init()
    
    /// loads Data from Database and stores them in one container: data
    func loadData() {
        do {
            data = try database.getAllItems()
        } catch let error {
            print("load data error: ", error.localizedDescription)
        }
    }
    
    /// add a new Data into Database
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
            loadData()
            
        } catch let error {
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
            loadData()
            
        } catch let error {
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
            loadData()
            
        } catch let error {
            print("remove data error: ", error.localizedDescription)
        }
    }
    
}
