// Copyright (c) 2025 Nadezhda Kolesnikova
// DataHelper.swift

import Foundation
import CoreData
import os

// Provides helper functions for Core Data operations
class DataHelper {
    
    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreData")

    // Saves changes to the Core Data context
    static func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            os_log("✅ Data saved successfully!", log: log, type: .info)
        } catch {
            os_log("❌ Error saving context: %@", log: log, type: .error, error.localizedDescription)
        }
    }

    // Fetches entities from Core Data based on the given request
    static func loadEntities<T: NSManagedObject>(with request: NSFetchRequest<T>, using context: NSManagedObjectContext) -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            os_log("❌ Error fetching data: %@", log: log, type: .error, error.localizedDescription)
            return []
        }
    }

    // Deletes an entity from both Core Data and the provided array
    static func deleteEntity<T: NSManagedObject>(_ entity: T, from array: inout [T], at index: Int, using context: NSManagedObjectContext) {
        guard index < array.count else {
            os_log("⚠️ Index out of range – skipping removal.", log: log, type: .error)
            return
        }

        let entityToDelete = array.remove(at: index) // Remove from array
        context.delete(entityToDelete) // Delete from Core Data

        do {
            try context.save()
            os_log("✅ Entity deleted successfully!", log: log, type: .info)
        } catch {
            os_log("❌ Error deleting entity: %@", log: log, type: .error, error.localizedDescription)
        }
    }
}
