// Copyright (c) 2025 Nadezhda Kolesnikova
// TodoListViewController.swift

import UIKit
import CoreData
import os

// Manages the to-do list, allowing users to add, delete, and search for tasks
class TodoListViewController: SwipeableViewController<Item>, SwipeableViewControllerDelegate, Addable, NavBarConfig {
    
    var shouldShowBackButton: Bool { return true }  // Enables the back button for this screen
    
    var itemArray = [Item]()  // Stores the list of tasks
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override var items: [Item] {
        get { itemArray }
        set {
            itemArray = newValue
            tableView.reloadData()
        }
    }
    
    func didUpdateItems() {
        tableView.reloadData()
        delegate?.didUpdateItems()
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        configureNavigationBar()
        setupPlusButton(action: #selector(addButtonPressed))
        searchBar.backgroundImage = UIImage()  // Removes default background
        searchBar.autocapitalizationType = .none
    }
    
    // MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < itemArray.count else { return UITableViewCell() }
        let item = itemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        // Configures the cell with task title
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        cell.contentConfiguration = content
        cell.backgroundColor = AppColors.Background.main

        cell.accessoryType = item.done ? .checkmark : .none
        
        // Custom bold checkmark for completed tasks
        let boldCheckmark = UIImageView(image: UIImage(systemName: "checkmark",
                                                       withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
        boldCheckmark.tintColor = AppColors.Icon.checkmark
        boldCheckmark.contentMode = .scaleAspectFit
        boldCheckmark.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        cell.accessoryView = item.done ? boldCheckmark : nil
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done.toggle()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Adding New Tasks
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addEntity(
            alertTitle: "Add New Item",
            placeholder: "Enter item name",
            entityType: Item.self,
            nameKey: "name",
            parentKey: "parentCategory",
            parentEntity: selectedCategory
        )
    }
    
    // MARK: - Data Management
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let category = selectedCategory else {
            itemArray = []
            tableView.reloadData()
            return
        }
        
        let parentPredicate = NSPredicate(format: "parentCategory == %@", category)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate, additionalPredicate])
        } else {
            request.predicate = parentPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            os_log("Failed to fetch items: %@", type: .error, error.localizedDescription)
            itemArray = []
        }
        tableView.reloadData()
    }
    
    func appendItem(_ item: Item) {
        itemArray.append(item)
        let newIndexPath = IndexPath(row: itemArray.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        
        // Scroll to newly added item (with animation)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        
        delegate?.didUpdateItems()  // Reload everything correctly
    }
    
    override func saveItems() {
        DataHelper.save(context: context)
        tableView.reloadData()
        delegate?.didUpdateItems()
    }
    
    override func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        os_log("Deleted item at index %d", log: Self.log, type: .info, indexPath.row)
        let itemToDelete = itemArray[indexPath.row]
        DataHelper.deleteEntity(itemToDelete, from: &itemArray, at: indexPath.row, using: context)
        
        //  Update the table view
        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        delegate?.didUpdateItems()
    }
  
    private func filterItems(with searchText: String) {
        DispatchQueue.main.async {
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                self.loadItems()
                return
            }
            
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@", trimmed)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            self.loadItems(with: request, predicate: searchPredicate)
        }
    }
}

// MARK: - Search Bar Functionality

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            filterItems(with: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterItems(with: searchText)
        
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
