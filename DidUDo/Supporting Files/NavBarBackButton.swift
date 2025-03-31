// Copyright (c) 2025 Nadezhda Kolesnikova
// NavBarBackButton.swift

import UIKit

// MARK: - Custom Back Button for Navigation Bar

extension UIViewController {
    
    func addBackButton() {
        let backImage = UIImage(
            systemName: "arrow.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        )?.withTintColor(AppColors.Text.title, renderingMode: .alwaysOriginal)
        
        let backButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    // Handles back button action
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}
