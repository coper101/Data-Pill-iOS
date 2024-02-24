//
//  Mock_Local_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import CoreData
import OSLog

final class InMemoryLocalDatabase: Database {

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
        Logger.database.debug("- LOCAL DATABASE: 💾 ℹ️ Container Persistent Descriptions: \(self.container.persistentStoreDescriptions)")
    }
}
