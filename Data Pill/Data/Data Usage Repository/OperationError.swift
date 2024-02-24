//
//  OperationError.swift
//  Data Pill
//
//  Created by Wind Versi on 1/7/23.
//

enum DatabaseError: Error, Equatable {
    
    // MARK: - Database
    case loadingContainer(String = "Sorry, the data can’t be loaded from the Storage.")
    
    // MARK: - Data
    case loadingAll(String)
    case adding(String)
    case updatingData(String)
    case gettingAll(String)
    case gettingTodaysData(String)
    case filteringData(String)
    
    // MARK: - Plan
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
    
enum DataAttribute: String {
    case date
    case dailyUsedData
    case totalUsedData
    case hasLastTotal
}

extension DataUsageRepository {
    
    func clearDataError() {
        dataError = nil
    }
}
