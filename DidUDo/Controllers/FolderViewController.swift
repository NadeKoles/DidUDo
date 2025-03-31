// Copyright (c) 2025 Nadezhda Kolesnikova
// FolderViewController.swift

import UIKit
import CoreData
import os

// Manages folders for categories, allowing users to add, delete, and navigate between them
class FolderViewController: SwipeableViewController<Folder>, SwipeableViewControllerDelegate, Addable, NavBarConfig {
    
    var shouldShowBackButton: Bool { return true }
    
    var folderArray = [Folder]()
    
    override var items: [Folder] {
        get { folderArray }
        set {
            folderArray = newValue
            tableView.reloadData()
        }
    }
    
    func didUpdateItems() {
        loadFolders() // Make sure folders refresh
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFolders()
        setupPlusButton(action: #selector(addButtonPressed))
    }
    
    // MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folder = folderArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        
        // Safely unwrap `categories`
        let categoriesCount = (folder.categories as? Set<Category>)?.count ?? 0
        
        var content = cell.defaultContentConfiguration()
        content.text = folder.name
        content.secondaryText = "(lists: \(categoriesCount))"
        content.textProperties.color = AppColors.Text.primary
        content.secondaryTextProperties.color = AppColors.Text.secondary
        cell.contentConfiguration = content
        cell.backgroundColor = AppColors.Background.main
        
        return cell
    }
    
    // MARK: - Add New Folder
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addEntity(
            alertTitle: "Add New Folder",
            placeholder: "Enter folder name",
            entityType: Folder.self,
            nameKey: "name"
        )
    }
    
    // MARK: - Data Management
    
    func loadFolders() {
        folderArray = DataHelper.fetchEntities(entity: Folder.self, context: context)
        tableView.reloadData()
    }
    
    func appendItem(_ item: Folder) {
        folderArray.append(item)
        let newIndexPath = IndexPath(row: folderArray.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        saveItems()
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCategories", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CategoryViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedFolder = folderArray[indexPath.row]
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Delete Folder
    
    override func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        let folderToDelete = folderArray[indexPath.row]
        DataHelper.deleteEntity(folderToDelete, from: &folderArray, at: indexPath.row, using: context)
        
        // Update the table view
        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

