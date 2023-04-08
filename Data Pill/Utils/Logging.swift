//
//  Logging.swift
//  Data Pill
//
//  Created by Wind Versi on 25/12/22.
//

import OSLog

extension Logger {
    
    enum Category: String {
        case appDelegate = "appdelegate"
        case appModel = "appmodel"
        case localDatabase = "localdatabase"
        case remoteDatabase = "remotedatabase"
        case networkRepository = "networkrepository"
        case dataUsageRemoteRepository = "datausageremoterespository"
        case widgetProvider = "widgetprovider"
    }
    
    // App
    static let appDelegate = createLogger(of: .appDelegate)
    static let appModel = createLogger(of: .appModel)
    static let networkRepository = createLogger(of: .networkRepository)
    static let dataUsageRemoteRepository = createLogger(of: .dataUsageRemoteRepository)
    static let database = createLogger(of: .localDatabase)
    static let remoteDatabase = createLogger(of: .remoteDatabase)
    
    // Widget Extension
    static let widgetProvider = createLogger(of: .widgetProvider)
            
    // Helpers
    static func createLogger(of category: Category) -> Logger {
        let subsystem = Bundle.main.bundleIdentifier!
        return .init(subsystem: subsystem, category: category.rawValue)
    }
}
