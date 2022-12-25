//
//  LocalDatabase.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData
import OSLog

enum AppGroup: String {
    case dataPill = "group.com.penguinworks.Data-Pill"
    var name: String {
        self.rawValue
    }
}

extension URL {
    
    static func storeURL(for appGroup: AppGroup, of container: Containers) -> URL? {
        guard let fileContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup.name
        ) else {
            Logger.database.error("failed to get file container \(container.name)")
            return nil
        }
        return fileContainer.appendingPathComponent("\(container.name).sqlite")
    }
}

enum Containers: String {
    case dataUsage = "DataUsage"
    var name: String {
        return self.rawValue
    }
}

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

// MARK: - Protocol
protocol Database {
    var container: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    
    init(container: Containers, appGroup: AppGroup?)
    
    func loadContainer(
        onError: @escaping (Error) -> Void,
        onSuccess: @escaping () -> Void
    ) -> Void
}

extension Database {
    func loadContainer(
        onError: @escaping (Error) -> Void,
        onSuccess: @escaping () -> Void
    ) {
        container.loadPersistentStores { (description, error) in
            if let error = error {
                onError(error); return
            }
            onSuccess(); return
        }
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

// MARK: Implementation
class LocalDatabase: Database {

    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(container: Containers, appGroup: AppGroup?) {
        self.container = NSPersistentContainer(name: container.name)
        if
            let appGroup = appGroup,
            let storeURL = URL.storeURL(for: appGroup, of: container)
        {
            let description = NSPersistentStoreDescription(url: storeURL)
            self.container.persistentStoreDescriptions = [description]
            Logger.database.debug("container persistent descriptions: \(self.container.persistentStoreDescriptions)")
        }
    }
    
}

class InMemoryLocalDatabase: Database {

    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(container: Containers, appGroup: AppGroup?) {
        self.container = NSPersistentContainer(name: container.name)
        if let storeDescription = self.container.persistentStoreDescriptions.first {
            storeDescription.type = NSInMemoryStoreType
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        Logger.database.debug("container persistent descriptions: \(self.container.persistentStoreDescriptions)")
    }
    
}
