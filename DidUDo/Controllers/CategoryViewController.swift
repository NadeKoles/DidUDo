// Copyright (c) 2025 Nadezhda Kolesnikova
// CategoryViewController.swift

import UIKit
import CoreData
import os

// Manages task categories, allowing users to add, delete, and navigate between them
class CategoryViewController: SwipeableViewController<Category>, Addable, NavBarConfig, TodoListViewControllerDelegate {
    
    // Refreshes category list when items change
    func didUpdateItems() {
        loadCategories()
    }
    
    var categoryArray = [Category]()
    
    override var items: [Category] {
        get { categoryArray }
        set {
            categoryArray = newValue
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        setupPlusButton(action: #selector(addButtonPressed))
        view.backgroundColor = AppColors.backgroundColor
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
        content.secondaryTextProperties.color = AppColors.secondTextColor

        cell.contentConfiguration = content
        cell.backgroundColor = AppColors.backgroundColor
        
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
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addEntity(alertTitle: "Add New Category", placeholder: "Enter category name", entityType: Category.self, nameKey: "name")
    }
    
    // MARK: - Data Management
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        categoryArray = DataHelper.loadEntities(with: request, using: context)
        tableView.reloadData()
    }
    
    func appendItem(_ item: Category) {
        categoryArray.append(item)
        let newIndexPath = IndexPath(row: categoryArray.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    override func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        os_log("🚀 Deleting category at index %d", log: Self.log, type: .debug, indexPath.row)
        
        let categoryToDelete = categoryArray[indexPath.row]
        DataHelper.deleteEntity(categoryToDelete, from: &categoryArray, at: indexPath.row, using: context)
        
        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
