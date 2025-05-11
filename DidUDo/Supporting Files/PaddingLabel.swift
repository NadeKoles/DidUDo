//
//  PaddingLabel.swift
//  DidUDo
//
//  Created by Nadia on 23/04/2025.
//  Copyright © 2025 Nadezhda Kolesnikova. All rights reserved.
//

import UIKit


class PaddingLabel: UILabel {
    private var insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}


