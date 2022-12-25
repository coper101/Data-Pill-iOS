//
//  Logging.swift
//  Data Pill
//
//  Created by Wind Versi on 25/12/22.
//

import OSLog

extension Logger {
    
    enum Category: String {
        case localDatabase = "localdatabase"
        case widgetProvider = "widgetprovider"
        case networkRepository = "networkrepository"
    }
    
    static let database = createLogger(of: .localDatabase)
    static let widgetProvider = createLogger(of: .widgetProvider)
    static let networkRepository = createLogger(of: .networkRepository)
    
    static func createLogger(of category: Category) -> Logger {
        let subsystem = Bundle.main.bundleIdentifier!
        return .init(subsystem: subsystem, category: category.rawValue)
    }
}
