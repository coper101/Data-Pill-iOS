//
//  LocalStorage.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation

final class LocalStorage {
    
    static func getUserDefaults() -> UserDefaults? {
        .init(suiteName: AppGroup.dataPill.groupIdentifier)
    }
    
    static func setItem(_ value: Any?, forKey key: Keys) {
        guard let defaults = getUserDefaults() else { return }
        defaults.set(value, forKey: key.rawValue)
    }
    
    static func getItem(forKey key: Keys) -> String? {
        guard let defaults = getUserDefaults() else { return nil }
        return defaults.string(forKey: key.rawValue)
    }
    
    static func getAnyItem(forKey key: Keys) -> Any? {
        guard let defaults = getUserDefaults() else { return nil }
        return defaults.object(forKey: key.rawValue)
    }
    
    static func getDateItem(forKey key: Keys) -> Date? {
        guard let defaults = getUserDefaults() else { return nil }
        return defaults.object(forKey: key.rawValue) as? Date
    }

    static func getBoolItem(forKey key: Keys) -> Bool {
        guard let defaults = getUserDefaults() else { return false }
        return defaults.bool(forKey: key.rawValue)
    }

    static func getDoubleItem(forKey key: Keys) -> Double {
        guard let defaults = getUserDefaults() else { return 0 }
        return defaults.double(forKey: key.rawValue)
    }
    
    static func getIntegerItem(forKey key: Keys) -> Int {
        guard let defaults = getUserDefaults() else { return 0 }
        return defaults.integer(forKey: key.rawValue)
    }
}
