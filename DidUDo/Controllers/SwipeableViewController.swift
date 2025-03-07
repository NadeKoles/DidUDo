// Copyright (c) 2025 Nadezhda Kolesnikova
// SwipeableViewController.swift

import Foundation
import CoreData
import UIKit
import os

// Base table view controller with swipe-to-delete and rename functionality
class SwipeableViewController<Entity: NSManagedObject>: UITableViewController {
    
    static var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "UI")
    }

    var context: NSManagedObjectContext {
        return PersistenceController.shared.context
    }
    
    var items: [Entity] {
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adds a long-press gesture for renaming items
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Core Data
    
    func saveItems() {
        DataHelper.save(context: context)
        tableView.reloadData()
    }
    
    // MARK: - Swipe Actions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        os_log("Swipe action triggered for row: %d", log: SwipeableViewController.log, type: .debug, indexPath.row)

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            os_log("Delete action selected for row: %d", log: SwipeableViewController.log, type: .debug, indexPath.row)

            self.deleteEntity(at: indexPath, in: tableView)
            completionHandler(true)
        }
        deleteAction.backgroundColor = AppColors.deleteColor
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        fatalError("deleteEntity(at:in:) must be implemented in subclasses")
    }
    
    // MARK: - Rename Functionality
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let touchPoint = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            presentRenameAlert(for: indexPath)
        }
    }
    
    private func presentRenameAlert(for indexPath: IndexPath) {
        guard indexPath.row < items.count else { return }

        let entity = items[indexPath.row]
        let key = entity.entity.attributesByName.keys.contains("name") ? "name" : "title"

        let alert = UIAlertController(title: "Rename", message: "Enter a new name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = entity.value(forKey: key) as? String
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                entity.setValue(newName, forKey: key)
                self.saveItems()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
