//
//  LocalStorage.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation

class LocalStorage {
    
    static func setItem(
        _ value: Any?,
        forKey key: Keys
    ) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }
    
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
