// Copyright (c) 2025 Nadezhda Kolesnikova
// NavBarConfig.swift

import UIKit

// MARK: - Navigation Bar Configuration Protocol

protocol NavBarConfig: AnyObject {
    
    func setupPlusButton(action: Selector)
    func configureNavigationBar()
    
    var shouldShowBackButton: Bool { get } // Default is false
}

// MARK: - Default Implementation

extension NavBarConfig where Self: UIViewController {
    
    var shouldShowBackButton: Bool { return false }

    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        // Adds back button only if needed
        if shouldShowBackButton {
            addBackButton()
        }
    }

    // Adds a "+" button to the navigation bar
    func setupPlusButton(action: Selector) {
        let plusImage = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .heavy)
        )?.withTintColor(AppColors.Button.plus, renderingMode: .alwaysOriginal)

        let plusButton = UIBarButtonItem(
            image: plusImage,
            style: .plain,
            target: self,
            action: action
        )
        navigationItem.rightBarButtonItem = plusButton
    }
}
