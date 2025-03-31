// Copyright (c) 2025 Nadezhda Kolesnikova
// PersistenceController.swift

import Foundation
import CoreData
import os

class PersistenceController {
    
    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreData")
    
    static let shared = PersistenceController() // Singleton instance for easy access to Core Data
    
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext } // Core Data context
    
    private init() {
        container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                os_log("Failed to load Core Data: %@", log: PersistenceController.log, type: .error, error.localizedDescription)
            } else { } 
        }
    }
    
}
