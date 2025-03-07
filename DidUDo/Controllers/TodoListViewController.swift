// Copyright (c) 2025 Nadezhda Kolesnikova
// TodoListViewController.swift

import UIKit
import CoreData
import os

// Manages the to-do list, allowing users to add, delete, and search for tasks
class TodoListViewController: SwipeableViewController<Item>, Addable, NavBarConfig {
    
    var itemArray = [Item]() // Stores the list of tasks
    
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
    
    weak var delegate: TodoListViewControllerDelegate?
    var shouldShowBackButton: Bool { return true } // Enables the back button for this screen
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
      
        setupPlusButton(action: #selector(addButtonPressed))
        view.backgroundColor = AppColors.backgroundColor
        
        searchBar.backgroundImage = UIImage() // Removes default background
        searchBar.barTintColor = AppColors.backgroundColor

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < itemArray.count else { return UITableViewCell() }
        let item = itemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        // Configures the cell with task title
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        cell.contentConfiguration = content
        cell.backgroundColor = AppColors.backgroundColor

        cell.accessoryType = item.done ? .checkmark : .none
        
        // Custom bold checkmark for completed tasks
        let boldCheckmark = UIImageView(image: UIImage(systemName: "checkmark",
                                                          withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
        boldCheckmark.tintColor = AppColors.checkmarkColor
        boldCheckmark.contentMode = .scaleAspectFit
        boldCheckmark.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        cell.accessoryView = item.done ? boldCheckmark : nil
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done.toggle()
        
        DispatchQueue.main.async {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Adding New Tasks
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addEntity(alertTitle: "Add New Item", placeholder: "Enter item name", entityType: Item.self, nameKey: "title")
    }
    
    // MARK: - Data Management
    
    override func saveItems() {
        DataHelper.save(context: context)
        tableView.reloadData()
        delegate?.didUpdateItems()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let category = selectedCategory else { return }
        
        let categoryPredicate = NSPredicate(format: "parentCategory == %@", category)
        request.predicate = predicate != nil ? NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate!]) : categoryPredicate
        
        items = DataHelper.loadEntities(with: request, using: context)
        tableView.reloadData()
    }
    
    func appendItem(_ item: Item) {
        guard let category = selectedCategory else { return }
        
        item.parentCategory = category
        item.done = false
        
        itemArray.append(item)
        
        let newIndexPath = IndexPath(row: itemArray.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    override func deleteEntity(at indexPath: IndexPath, in tableView: UITableView) {
        os_log("✅ Deleted item at index %d", log: Self.log, type: .info, indexPath.row)

        let itemToDelete = itemArray[indexPath.row]
        
        DataHelper.deleteEntity(itemToDelete, from: &itemArray, at: indexPath.row, using: context)
        delegate?.didUpdateItems()

        DispatchQueue.main.async {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Search Bar Functionality

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}

// MARK: - Update Items Delegate

protocol TodoListViewControllerDelegate: AnyObject {
    func didUpdateItems()
}
