//
//  FoldersHeaderView.swift
//  DidUDo
//
//  Created by Nadia on 26/04/2025.
//  Copyright © 2025 Nadezhda Kolesnikova. All rights reserved.
//


import UIKit

class FoldersHeaderView: UIView {
    
    private let titleLabel = PaddingLabel(insets: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
    private let cornerRadius: CGFloat = 8
    private let baseBackgroundColor = AppColors.Background.main

    init(title: String) {
        super.init(frame: .zero)
        setupView(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(title: String) {
        backgroundColor = .clear
        
        // Configure title label
        titleLabel.text = title
        titleLabel.font = AppFonts.title
        titleLabel.textColor = AppColors.Text.title
        titleLabel.backgroundColor = AppColors.Background.main
        titleLabel.layer.cornerRadius = cornerRadius
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .left
       
        // Add subviews
        addSubview(titleLabel)
        
        // Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - Scroll Effect
    func updateForScroll(offsetY: CGFloat) {
        let maxDarkness: CGFloat = 0.1 // 5% осветление
         let normalizedOffset = min(offsetY / 80, 1.0)
         let darkness = normalizedOffset * maxDarkness
         
         UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
             self.titleLabel.backgroundColor = self.baseBackgroundColor.darker(by: darkness)
         })
     }
}


// MARK: - Color Extension

private extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        
        return UIColor(
            red: max(r * (1 - percentage), 0),
            green: max(g * (1 - percentage), 0),
            blue: max(b * (1 - percentage), 0),
            alpha: a
        )
    }
}


