//
//  Logging.swift
//  Data Pill
//
//  Created by Wind Versi on 25/12/22.
//

import OSLog

extension Logger {
    
    enum Category: String {
        case appDelegate = "App_Delegate"
        
        case appModel = "App_View_Model"
        case reportABug = "Report_A_Bug_View_Model"
        
        case localDatabase = "Local_Database"
        case remoteDatabase = "Remote_Database"
        case networkRepository = "Network_Repository"
        case dataUsageRemoteRepository = "Data_Usage_Remote_Repository"
        case localNotification = "Local_Notification"
        case widgetProvider = "Widget_Provider"
    }
    
    /// App
    static let appDelegate = createLogger(of: .appDelegate)
    
    static let appModel = createLogger(of: .appModel)
    static let reportABug = createLogger(of: .reportABug)
    
    static let networkRepository = createLogger(of: .networkRepository)
    static let dataUsageRemoteRepository = createLogger(of: .dataUsageRemoteRepository)
    static let database = createLogger(of: .localDatabase)
    static let remoteDatabase = createLogger(of: .remoteDatabase)
    static let localNotification = createLogger(of: .localNotification)
    
    /// Widget Extension
    static let widgetProvider = createLogger(of: .widgetProvider)
            
    /// Helpers
    static func createLogger(of category: Category) -> Logger {
        let subsystem = Bundle.main.bundleIdentifier!
        return .init(subsystem: subsystem, category: category.rawValue)
    }
}
