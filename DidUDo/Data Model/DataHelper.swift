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
            os_log("Data saved successfully!", log: log, type: .info)
        } catch {
            os_log("Error saving context: %@", log: log, type: .error, error.localizedDescription)
        }
    }

    // Generic fetch function for any Core Data entity
    static func fetchEntities<T: NSManagedObject>(
        entity: T.Type,
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext
    ) -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate

        do {
            return try context.fetch(request) as? [T] ?? []
        } catch {
            os_log("Error fetching %@: %@", log: log, type: .error, String(describing: T.self), error.localizedDescription)
            return []
        }
    }

    // Deletes an entity from both Core Data and the provided array
    static func deleteEntity<T: NSManagedObject>(_ entity: T, from array: inout [T], at index: Int, using context: NSManagedObjectContext) {
        guard index < array.count else {
            os_log("Index out of range – skipping removal.", log: log, type: .error)
            return
        }

        let entityToDelete = array.remove(at: index)  // Remove from array
        context.delete(entityToDelete)  // Delete from Core Data

        do {
            try context.save()
            os_log("Entity deleted successfully!", log: log, type: .info)
        } catch {
            os_log("Error deleting entity: %@", log: log, type: .error, error.localizedDescription)
        }
    }
}

