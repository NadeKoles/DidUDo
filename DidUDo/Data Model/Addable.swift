// Copyright (c) 2025 Nadezhda Kolesnikova
// Addable.swift

import Foundation
import UIKit
import CoreData
import os

// MARK: - Addable Protocol

// Protocol for managing CoreData entities in view controllers
protocol Addable {
    associatedtype Entity: NSManagedObject
    var context: NSManagedObjectContext { get }
    var items: [Entity] { get set }
    func didUpdateItems()
    func saveItems()
    func addEntity(alertTitle: String, placeholder: String, entityType: Entity.Type, nameKey: String, parentKey: String?, parentEntity: NSManagedObject?)
    func appendItem(_ item: Entity)
}

// MARK: - Addable Protocol Extension

extension Addable where Self: UIViewController {
    
    // Displays an alert for adding a new entity to CoreData
    func addEntity<T: NSManagedObject>(
        alertTitle: String,
        placeholder: String,
        entityType: T.Type,
        nameKey: String,
        parentKey: String? = nil,  // Optional key to set the parent
        parentEntity: NSManagedObject? = nil  // Optional parent entity
    ) where T == Entity {
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }

        let action = UIAlertAction(title: "Add", style: .default) { _ in
            guard let userInput = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !userInput.isEmpty else {
                os_log("Invalid input in Addable alert", type: .error)
                return
            }
            
            let entity = entityType.init(context: self.context)
            entity.setValue(userInput, forKey: nameKey)
            
            if entity.entity.attributesByName.keys.contains("done") {
                entity.setValue(false, forKey: "done")
            }
            
            // Ensure parent linking is safe
            if let parentKey = parentKey, let parentEntity = parentEntity {
                entity.setValue(parentEntity, forKey: parentKey)
            }
            
            os_log("Added new entity of type %@", type: .info, String(describing: T.self))
            
            self.appendItem(entity)
            self.saveItems()
            self.didUpdateItems()
          }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }

}

