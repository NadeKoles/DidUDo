// Copyright (c) 2025 Nadezhda Kolesnikova
// CategoryViewController.swift

import UIKit
import CoreData
import os

// Manages task categories, allowing users to add, delete, and navigate between them
class CategoryViewController: SwipeableViewController<Category>, SwipeableViewControllerDelegate, Addable, NavBarConfig {
    
    var shouldShowBackButton: Bool { return true }
    
    var categoryArray = [Category]()
    var selectedFolder: Folder? {
        didSet {
            loadCategories()
        }
    }
    
    override var items: [Category] {
        get { categoryArray }
        set { categoryArray = newValue }
    }
    
    // Refreshes category list when items change
    func didUpdateItems() {
        tableView.reloadData()
        delegate?.didUpdateItems()  // Notify FolderVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loadCategories()
        setupPlusButton(action: #selector(addButtonPressed))
    }
    
    // MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categoryArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Count completed and pending tasks
        let doneCount = category.items?.filter { ($0 as? Item)?.done == true }.count ?? 0
        let openCount = category.items?.filter { ($0 as? Item)?.done == false }.count ?? 0
        
        // Configure cell with category name and item counts
        var content = cell.defaultContentConfiguration()
        content.text = category.name
        content.secondaryText = "(done: \(doneCount), open: \(openCount))"
        content.secondaryTextProperties.color = AppColors.Text.secondary
        cell.contentConfiguration = content
        cell.backgroundColor = AppColors.Background.main
        

        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TodoListViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]   // Keep category assignment
            destinationVC.delegate = self   // Set the delegate for updates
        }
    }
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addEntity(
            alertTitle: "Add New Category",
            placeholder: "Enter category name",
            entityType: Category.self,
            nameKey: "name",
            parentKey: "parentFolder",
            parentEntity: selectedFolder
        )
    }
    
    // MARK: - Data Management
    
    func loadCategories() {
        guard let folder = selectedFolder else {
            categoryArray = []
            tableView.reloadData()
            return
        }
        
        let predicate = NSPredicate(format: "parentFolder == %@", folder)
        categoryArray = DataHelper.fetchEntities(entity: Category.self, predicate: predicate, context: context)
        tableView.reloadData()
    }
    
    func appendItem(_ item: Category) {
        categoryArray.append(item)
        let newIndexPath = IndexPath(row: categoryArray.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        delegate?.didUpdateItems()
    }
    
    override func saveItems() {
        DataHelper.save(context: context)
        delegate?.didUpdateItems()
    }
    
    override func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        let categoryToDelete = categoryArray[indexPath.row]
        DataHelper.deleteEntity(categoryToDelete, from: &categoryArray, at: indexPath.row, using: context)
        
        // Update the table view
        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        delegate?.didUpdateItems()
    }
    
}

