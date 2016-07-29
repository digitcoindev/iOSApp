//
//  AccountAddButton.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AccountAddButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView {
            imageView.frame = CGRect(x: self.frame.width / 2 - 12, y: self.frame.height / 3 - 8, width: 24, height: 24)
        }
        
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            titleLabel.center.x = self.frame.width / 2
            titleLabel.center.y = self.frame.height * 2 / 3
        }
    }
}
