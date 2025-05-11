// Copyright (c) 2025 Nadezhda Kolesnikova
// CategoryViewController.swift

import UIKit
import CoreData
import os

// Manages task categories, allowing users to add, delete, and navigate between them
class CategoryViewController: SwipeableViewController<Category>, SwipeableViewControllerDelegate, Addable, NavBarConfig {
    
    var shouldShowBackButton: Bool { return true }
    private var isSearching = false
    
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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loadCategories()
        setupPlusButton(action: #selector(addButtonPressed))
        configureSearchBar()
        checkEmptyState()
    }
    
    private func configureSearchBar() {
        searchBar.backgroundImage = UIImage()
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Search lists and dodos"
        searchBar.delegate = self
        isSearching = false
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
        
        content.textProperties.font = cellTextFont
        content.secondaryTextProperties.font = cellSecondaryTextFont
        content.textProperties.color = cellTextColor
        content.secondaryTextProperties.color = cellSecondaryTextColor
        
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
            alertTitle: "Add New List",
            placeholder: "enter list name",
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
            checkEmptyState()
            return
        }
        
        let predicate = NSPredicate(format: "parentFolder == %@", folder)
        categoryArray = DataHelper.fetchEntities(entity: Category.self, predicate: predicate, context: context)
        tableView.reloadData()
        checkEmptyState()
    }
    
    func appendItem(_ item: Category) {
        categoryArray.append(item)
        let newIndexPath = IndexPath(row: categoryArray.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        delegate?.didUpdateItems()
        checkEmptyState()
    }
    
    override func saveItems() {
        DataHelper.save(context: context)
        delegate?.didUpdateItems()
        checkEmptyState()
    }
    
    override func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        let categoryToDelete = categoryArray[indexPath.row]
        DataHelper.deleteEntity(categoryToDelete, from: &categoryArray, at: indexPath.row, using: context)
        
        // Update the table view
        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        delegate?.didUpdateItems()
        checkEmptyState()
    }
    
    private func checkEmptyState() {
        if categoryArray.isEmpty {
            let label = UILabel()
            label.text = isSearching ? "no results :c" : "create your first list"
            label.textAlignment = .center
            label.textColor = AppColors.Text.secondary
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Search Bar Filtering Items
    
    private func filterCategories(with searchText: String) {
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            loadCategories() // This already calls reloadData() and checkEmptyState()
            return
        }
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Create and assign the predicate directly
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "name CONTAINS[cd] %@", trimmed),
            NSPredicate(format: "ANY items.name CONTAINS[cd] %@", trimmed)
        ])
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        categoryArray = DataHelper.fetchEntities(
            entity: Category.self,
            predicate: request.predicate,
            context: context
        )
        
        tableView.reloadData()
        checkEmptyState()
    }
}

// MARK: - Search Bar Functionality

extension CategoryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            isSearching = false
            loadCategories()
        } else {
            isSearching = true
            filterCategories(with: trimmed)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.delegate = nil
    }
}
