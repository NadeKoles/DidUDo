// Copyright (c) 2025 Nadezhda Kolesnikova
// ItemCell.swift

import UIKit

// Custom table view cell for displaying a to-do item
class ItemCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Called after the view is loaded from the storyboard
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Updates the appearance when the cell is selected
    }
}
