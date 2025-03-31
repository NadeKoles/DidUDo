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
        static let main = UIColor(light: 0xffffff, dark: 0x333333) // white - dark gray
        static let navBar = UIColor(light: 0x718dbf, dark: 0x35445e) // blue-gray - dark blue-gray
    }

    struct Button {
        static let plus = UIColor(light: 0x77c298, dark: 0x77c298) // green - green
        static let delete = UIColor(light: 0xe84d60, dark: 0xe84d60) // red - red
    }

    struct Icon {
        static let checkmark = UIColor(light: 0xe84d60, dark: 0xfecd6c) // green - yellow
    }

    struct Text {
        static let primary = UIColor(light: 0x342E37, dark: 0xFFFFFF) // dark gray - white
        static let secondary = UIColor(light: 0x77c298, dark: 0x77c298) // green - green
        static let title = UIColor(light: 0x35445e, dark: 0xFFFFFF) // dark blue-gray - white
    }

}
