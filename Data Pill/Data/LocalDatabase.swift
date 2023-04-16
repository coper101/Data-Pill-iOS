//
//  LocalDatabase.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData
import OSLog

// MARK: Identifiers
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

// MARK: Types
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

// MARK: Helpers
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

// MARK: Implementation
class LocalDatabase: Database {

    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(container: Containers, appGroup: AppGroup?) {
        self.container = NSPersistentContainer(name: container.name)
        // self.container = NSPersistentCloudKitContainer(name: container.name)
        if
            let appGroup,
            // let cloudKit,
            let storeLocation = URL.storeURL(for: appGroup, of: container)
        {
            let storeDescription = NSPersistentStoreDescription(url: storeLocation)
            // storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKit.containerIdentifier)
            
            // lightweight migration
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
            
            self.container.persistentStoreDescriptions = [storeDescription]
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
