//
//  AppStore.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation

enum Keys: String {
    case usageType = "Usage_Type"
    case notification = "Notification"
    case startDatePlan = "Start_Data_Plan"
    case endDatePlan = "End_Data_Plan"
    case dataAmount = "Data_Amount"
    case dailyDataLimit = "Daily_Data_Limit"
    case totalDataLimit = "Total_Data_Limit"
}

class AppStorage {
    
    // MARK: Setters
    static func setItem(
        _ value: Any?,
        forKey key: Keys
    ) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }
    
    // MARK: Getters
    static func getItem(forKey key: Keys) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key.rawValue)
    }
    
    static func getDateItem(forKey key: Keys) -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key.rawValue) as? Date
    }
    
    static func getBoolItem(forKey key: Keys) -> Bool? {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key.rawValue)
    }
    
    static func getDoubleItem(forKey key: Keys) -> Double? {
        let defaults = UserDefaults.standard
        return defaults.double(forKey: key.rawValue)
    }

}
