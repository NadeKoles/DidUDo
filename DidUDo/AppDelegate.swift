// Copyright (c) 2025 Nadezhda Kolesnikova
// AppDelegate.swift

import UIKit
import CoreData
import os

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    var window: UIWindow?

    static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AppLifecycle") // Logging for app events
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = AppColors.Background.navBar
        
        // Customize navigation bar title appearance
        appearance.titleTextAttributes = [
            .foregroundColor: AppColors.Text.title,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PersistenceController.shared.context.performAndWait {
            do {
                try PersistenceController.shared.context.save()
                os_log("Core Data saved on app termination", log: AppDelegate.log, type: .info)
            } catch {
                os_log("Error saving Core Data: %@", log: AppDelegate.log, type: .error, error.localizedDescription)
            }
        }
    }
}
