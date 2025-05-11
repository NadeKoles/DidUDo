//// Copyright (c) 2025 Nadezhda Kolesnikova
//// ItemCell.swift
//
//import UIKit
//
//// Custom table view cell for displaying a to-do item
//class ItemCell: UITableViewCell {
//
//    @IBOutlet weak var label: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupAccessoryView()
//        // Called after the view is loaded from the storyboard
//    }
//
//    private func setupAccessoryView() {
//        // Standard system disclosure indicator
//        self.accessoryType = .disclosureIndicator
//        
//        // OR for a custom color (iOS 13+)
//        let indicatorColor = AppColors.Text.title // or your custom color
//        self.tintColor = indicatorColor
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Updates the appearance when the cell is selected
//    }
//}
