//
//  LocalDatabase.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData
import OSLog

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



// MARK: - App Implementation
final class LocalDatabase: Database {

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
