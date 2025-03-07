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
    
    func saveItems()
    func addEntity(alertTitle: String, placeholder: String, entityType: Entity.Type, nameKey: String)
    func appendItem(_ item: Entity)
}

// MARK: - Addable Protocol Extension

extension Addable where Self: UIViewController {
    
    // Displays an alert for adding a new entity to CoreData
    func addEntity(alertTitle: String, placeholder: String, entityType: Entity.Type, nameKey: String) {
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            if let userInput = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userInput.isEmpty {
                
                let newEntity = entityType.init(context: self.context)
                newEntity.setValue(userInput, forKey: nameKey)
                
                os_log("✅ Added new entity of type %@", log: SwipeableViewController<Entity>.log, type: .info, String(describing: Entity.self))
                
                self.appendItem(newEntity)
                self.saveItems()
                
            } else {
                os_log("⚠️ Invalid input in Addable alert", log: SwipeableViewController.log, type: .error)
            }
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // Saves the CoreData context
    func saveItems() {
        DataHelper.save(context: context)
    }
}
