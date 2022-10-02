//
//  DataStore.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData

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

class AppDatabase<Entity: NSManagedObject> {
    
    private let container: NSPersistentContainer
    private let entityName: String
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init(
        container: Containers,
        entity: Entities
    ) {
        self.container = NSPersistentContainer(name: container.name)
        entityName = entity.name
    }
    
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
    
    func getAllItems() throws -> [Entity] {
        let request = NSFetchRequest<Entity>(entityName: entityName)
        return try context.fetch(request)
    }
    
    func addItem(_ creator: @escaping (inout Entity) -> Void) throws -> Bool {
        var newItem = Entity.init(context: context)
        creator(&newItem)
        return try context.saveIfNeeded()
    }
    
    func updateItem(_ item: Entity) throws -> Bool {
        return try context.saveIfNeeded()
    }
    
    func deleteItem(_ item: Entity) throws -> Bool {
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
