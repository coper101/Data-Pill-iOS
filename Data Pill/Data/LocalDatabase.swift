//
//  LocalDatabase.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData

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
            print("Failed to get file container")
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
    associatedtype Entity: NSManagedObject
    var container: NSPersistentContainer { get }
    var entityName: String { get }
    var context: NSManagedObjectContext { get }
    
    init(
        container: Containers,
        entity: Entities,
        appGroup: AppGroup?
    )
    
    func loadContainer(onError: @escaping (Error) -> Void, onSuccess: @escaping () -> Void) -> Void
    func getAllItems() throws -> [Entity]
    func getItemsWith(format: String, _ args: CVarArg..., sortDescriptors: [NSSortDescriptor]) throws -> [Entity]
    func addItem(_ creator: @escaping (inout Entity) -> Void) throws -> Bool
    func updateItem(_ item: Entity) throws -> Bool
    func deleteItem(_ item: Entity) throws -> Bool
}

extension Database where Entity: NSManagedObject {
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
    
    func getAllItems() throws -> [Data] {
        let request = NSFetchRequest<Data>(entityName: entityName)
        return try context.fetch(request)
    }
    
    func getItemsWith(
        format: String,
        _ args: CVarArg...,
        sortDescriptors: [NSSortDescriptor] = []
    ) throws -> [Data] {
        let request = NSFetchRequest<Data>(entityName: entityName)
        request.sortDescriptors = sortDescriptors
        request.predicate = .init(format: format, args)
        return try context.fetch(request)
    }
    
    func addItem(_ creator: @escaping (inout Data) -> Void) throws -> Bool {
        var newItem = Data.init(context: context)
        creator(&newItem)
        return try context.saveIfNeeded()
    }
    
    func updateItem(_ item: Data) throws -> Bool {
        return try context.saveIfNeeded()
    }
    
    func deleteItem(_ item: Data) throws -> Bool {
        context.delete(item)
        return try context.saveIfNeeded()
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
    let entityName: String
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(
        container: Containers,
        entity: Entities,
        appGroup: AppGroup?
    ) {
        self.container = NSPersistentContainer(name: container.name)
        if
            let appGroup = appGroup,
            let storeURL = URL.storeURL(for: appGroup, of: container)
        {
            let description = NSPersistentStoreDescription(url: storeURL)
            self.container.persistentStoreDescriptions = [description]
            print("persistent descriptions: ", self.container.persistentStoreDescriptions)
        }
        entityName = entity.name
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
}

class InMemoryLocalDatabase: Database {

    let container: NSPersistentContainer
    let entityName: String
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(
        container: Containers,
        entity: Entities,
        appGroup: AppGroup?
    ) {
        entityName = entity.name
        self.container = NSPersistentContainer(name: container.name)
        if let storeDescription = self.container.persistentStoreDescriptions.first {
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }
    }
    
}
