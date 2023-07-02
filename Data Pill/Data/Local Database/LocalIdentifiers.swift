//
//  LocalDatabaseIdentifier.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import CoreData
import OSLog

// MARK: - Identifiers
enum AppGroup: String {
    case dataPill = "group.com.penguinworks.Data-Pill"
    var groupIdentifier: String {
        self.rawValue
    }
}

enum Containers: String {
    case dataUsage = "DataUsage"
    var name: String {
        return self.rawValue
    }
}



// MARK: - Types
enum Entities: String {
    case data = "Data"
    case plan = "Plan"
    var name: String {
        return self.rawValue
    }
}

enum StorageType {
    case sql
    case memory
}



// MARK: - Helpers
extension URL {
    
    static func storeURL(for appGroup: AppGroup, of container: Containers) -> URL? {
        guard let fileContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup.groupIdentifier
        ) else {
            Logger.database.error("failed to get file container \(container.name)")
            return nil
        }
        return fileContainer.appendingPathComponent("\(container.name).sqlite")
    }
}

extension NSManagedObjectContext {

    /// Only performs a save if there are changes to commit.
    /// - Returns: `true` if a save was needed. Otherwise, `false`.
    @discardableResult public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
}
