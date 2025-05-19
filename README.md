# ✅ DidUDo — iOS Task Manager App

DidUDo is a simple and intuitive task manager app for iOS built using UIKit. The app helps users organize their tasks into folders and categories, mark them as completed, and interact with their todo list using smooth swipe gestures.

---

## 🚀 Features

- 📁 Organize tasks into folders
- 🗂 Categorize tasks for better overview
- ✅ Mark tasks as done or pending
- 🔄 Swipe to complete or delete tasks
- 🎨 Custom UI elements and color labels
- 💾 Persistent storage with Core Data
- 🌙 Light and Dark Mode support

---

## ⚙️ Getting Started

1. Make sure you have Xcode 14 or later installed
2. Clone the repository:
```bash
git clone https://github.com/NadeKoles/DidUDo.git
```
3. Open `DidUDo.xcodeproj`
4. Build and run on a simulator or real device

---

## 📚 Architecture

- UIKit-based modular structure
- Core Data for persistence
- Custom reusable components for UI
- Navigation and appearance managed via helpers

### Main components:

- `FolderViewController` — list of task folders
- `CategoryViewController` — category-based task view
- `TodoListViewController` — list of tasks within a folder
- `SwipeableViewController` — swipe-enabled interactions
- `ItemCell`, `FoldersHeaderView` — custom views
- `DataHelper`, `PersistenceController` — data logic and Core Data stack
- `AppColors`, `AppFonts`, `NavBarConfig` — design system

---

## 💌 Tested

- Task creation, completion, and deletion
- Folder and category navigation
- Swipe gestures
- UI styling in both light and dark modes
- Data persistence across sessions

---

## 🧑🏻 Author

Designed and developed by iOS developer [Nadia K] as a part of personal learning and practice.

---

## 📌 Notes

- The app works fully offline
- All UI is optimized for clean and clutter-free experience
- Code is modular, readable, and easy to extend

Thanks for checking it out! 🙌
