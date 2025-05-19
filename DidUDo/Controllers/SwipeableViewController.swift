// Copyright (c) 2025 Nadezhda Kolesnikova
// SwipeableViewController.swift

import Foundation
import CoreData
import UIKit
import os

// Base table view controller with swipe-to-delete and rename functionality
class SwipeableViewController<Entity: NSManagedObject>: UITableViewController {
    
    weak var delegate: SwipeableViewControllerDelegate?
    private var renameObserver: NSObjectProtocol? // For tracking text field changes
    
    static var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "UI")
    }
    
    var cellTextFont: UIFont = AppFonts.primary
    var cellSecondaryTextFont: UIFont = AppFonts.secondary
    var cellTextColor: UIColor = AppColors.Text.primary
    var cellSecondaryTextColor: UIColor = AppColors.Text.secondary
    
    var context: NSManagedObjectContext {
        return PersistenceController.shared.context
    }
    
    var items: [Entity] = []
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply background color
        tableView.backgroundColor = AppColors.Background.main
        tableView.separatorColor = AppColors.Background.divider

        // Adds a long-press gesture for renaming items
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
        tableView.contentInset.bottom = 60  // Add bottom spacing under the last cell
        tableView.alwaysBounceVertical = false  // Prevent bouncy scroll if there's not enough content
    }
    
    
    //MARK: - Cell
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - Core Data
    
    func saveItems() {
        dispatchPrecondition(condition: .onQueue(.main))
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
        deleteAction.backgroundColor = AppColors.Button.delete
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @objc open func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        preconditionFailure("\(Self.self) must override deleteEntity(at:in:) to support swipe-to-delete")
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
        let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        
        var saveAction: UIAlertAction!
        
        alert.addTextField { textField in
            let currentName = entity.value(forKey: key) as? String
            textField.text = currentName
            
            // Dispatch needed to wait for the alert to present fully
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
                let start = textField.beginningOfDocument
                let end = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: start, to: end)
            }
            
            // Observe text changes to enable/disable Save button
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
                let trimmed = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                saveAction.isEnabled = !trimmed.isEmpty
            }
        }
        
        saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.renameObserver = nil // Clear observer
            
            if let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !newName.isEmpty {
                entity.setValue(newName, forKey: key)
                self.saveItems()
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        saveAction.isEnabled = false
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.renameObserver = nil
        })
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
}

protocol SwipeableViewControllerDelegate: AnyObject {
    func didUpdateItems()
}


