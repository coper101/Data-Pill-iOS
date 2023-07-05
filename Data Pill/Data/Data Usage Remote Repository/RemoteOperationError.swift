//
//  RemoteOperationError.swift
//  Data Pill
//
//  Created by Wind Versi on 5/7/23.
//

enum DatabaseAccess: String {
    case error = "Error"
    case restricted = "Restricted"
    case noAccount = "No Account"
    case couldNotDetermine = "Could Not Determine"
    case temporarilyUnavailable = "Temporarily Unavailable"
    case unknown = "Unknown"
}

enum RemoteDatabaseError: Error, Equatable {
    case accountError(DatabaseAccess)
    case fetchError(String)
    case saveError(String)
    case nilProp(String)
    
    var description: String {
        switch self {
        case .accountError(let error):
            return "Account: \(error.rawValue)"
        case .fetchError(let message):
            return "Fetch: \(message)"
        case .saveError(let message):
            return "Save: \(message)"
        case .nilProp(let message):
            return "Nil: \(message)"
        }
    }
    
    static func == (lhs: RemoteDatabaseError, rhs: RemoteDatabaseError) -> Bool {
        lhs.description == rhs.description
    }
}
