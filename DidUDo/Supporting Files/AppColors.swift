// Copyright (c) 2025 Nadezhda Kolesnikova
// AppColors.swift

import Foundation
import UIKit

// MARK: - UIColor Extensions

extension UIColor {
    
    // Creates a color that adapts to light/dark mode using hex values
    convenience init(light: Int, dark: Int, alpha: CGFloat = 1.0) {
        self.init { traitCollection in
            let hex = (traitCollection.userInterfaceStyle == .dark) ? dark : light
            return UIColor(hex: hex, alpha: alpha)
        }
    }

    // Converts a HEX Int to UIColor
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - App Theme Colors

struct AppColors {
    
    struct Background {
        static let main = UIColor(light: 0xede5d7, dark: 0x0f1117) // light beige - dark blue
        static let navBar = UIColor(light: 0x7f8f40, dark: 0x263141) // muted olive green - dark blue
        static let divider = UIColor(light: 0xb5ab9e, dark: 0x4a4d57) // soft gray - deep gray
    }
    
    struct Button {
        static let plus = UIColor(light: 0xf9f8f4, dark: 0xf4c15d) // off-white - golden yellow
        static let delete = UIColor(light: 0xe17184, dark: 0xd94f4f) // soft pink - vibrant red
        static let back = UIColor(light: 0xf9f8f4, dark: 0xf4c15d) // off-white - golden yellow
    }
    
    struct Icon {
        static let checkmark = UIColor(light: 0x599ee7, dark: 0xa2dff7) // light blue - pastel blue
        static let folder = UIColor(light: 0x272623, dark: 0xb4c0d4) // dark grayish blue - light blue
    }
    
    struct Text {
        static let primary = UIColor(light: 0x0d1925, dark: 0xf0f0f5) // dark gray - off-white
        static let secondary = UIColor(light: 0x7097b5, dark: 0xa1a6b2) // light blue-gray - muted gray
        static let title = UIColor(light: 0x272623, dark: 0xb4c0d4) // dark blue-gray - light blue
        static let navBarTitle = UIColor(light: 0xf9f8f4, dark: 0xf4c15d) // off-white - golden yellow
    }
}

